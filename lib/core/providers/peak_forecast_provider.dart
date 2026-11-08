import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/rate_database.dart';
import '../models/demand_forecast.dart';
import '../models/grid_demand_sample.dart';
import '../services/grid_demand_csv_parser.dart';
import '../services/peak_prediction_service.dart';
import '../services/weather_service.dart';
import 'location_provider.dart';
import 'rate_plan_provider.dart';

/// Loads the bundled 2024 hourly measurements from Nova Scotia Power OASIS.
/// This asset is historical data, not live grid demand.
final gridDemandHistoryProvider = FutureProvider<GridDemandHistory>((
  ref,
) async {
  const csvParser = GridDemandCsvParser();
  try {
    final csv = await rootBundle.loadString('assets/data/ns_load_history.csv');
    final samples = csvParser.parse(csv);
    final metadataJson = await rootBundle.loadString(
      'assets/data/ns_load_history_metadata.json',
    );
    final decoded = jsonDecode(metadataJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Grid history metadata is not an object.');
    }
    final declaredCount = decoded['sample_count'];
    final latestObservation = decoded['latest_observation'];
    final actualLatest = samples.isEmpty
        ? null
        : samples
              .map((sample) => sample.time)
              .reduce((a, b) => a.isAfter(b) ? a : b)
              .toIso8601String()
              .substring(0, 16);
    if (declaredCount != samples.length ||
        latestObservation != actualLatest ||
        samples.isEmpty) {
      throw const FormatException(
        'Grid history CSV does not match its update metadata.',
      );
    }

    final warnings = decoded['quality_warnings'];
    final warningParts = <String>[];
    if (warnings is List) {
      warningParts.addAll(warnings.whereType<String>());
    }
    final latestTime = samples
        .map((sample) => sample.time)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    if (DateTime.now().difference(latestTime).inDays > 75) {
      warningParts.add(
        'The newest published grid reading is more than 75 days old.',
      );
    }
    return GridDemandHistory(
      samples: samples,
      warning: warningParts.isEmpty ? null : warningParts.join(' '),
    );
  } catch (_) {
    // Keep the existing 2024 profile usable if the updated CSV or its
    // metadata is missing, incomplete, or out of sync.
    try {
      final previousCsv = await rootBundle.loadString(
        'assets/data/ns_load_2024.csv',
      );
      return GridDemandHistory(
        samples: csvParser.parse(previousCsv),
        warning:
            'The refreshed grid dataset was unavailable or failed its '
            'integrity check; using the older bundled profile.',
      );
    } catch (_) {
      rethrow;
    }
  }
});

/// Estimated demand outlook using historical grid load with a cold-weather
/// adjustment. Falls back to the existing weather heuristic without history.
final peakForecastProvider = FutureProvider.family<DemandForecast, ForecastRange>((
  ref,
  range,
) async {
  final location = ref.watch(locationProvider);
  final plan = ref.watch(ratePlanProvider);
  var historicalGridDemand = <GridDemandSample>[];
  DateTime? historicalDemandThrough;
  String? historicalDemandWarning;
  try {
    final gridHistory = await ref.watch(gridDemandHistoryProvider.future);
    historicalGridDemand = gridHistory.samples;
    historicalDemandWarning = gridHistory.warning;
    if (historicalGridDemand.isEmpty) {
      historicalDemandWarning =
          'The historical grid-demand file contained no readings. This '
          'forecast is using weather and schedule patterns only.';
    } else {
      historicalDemandThrough = historicalGridDemand
          .map((sample) => sample.time)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    }
  } catch (_) {
    // Weather still provides a usable fallback if the bundled history is
    // missing or malformed. The forecast model will use its weather heuristic.
    historicalDemandWarning =
        'Historical grid-demand data could not be loaded. This forecast is '
        'using weather and schedule patterns only.';
  }
  final weatherService = WeatherService();
  final predictionService = PeakPredictionService();

  final hourly = await weatherService.getHourlyForecast(
    latitude: location.latitude,
    longitude: location.longitude,
    forecastDays: 7,
  );
  final weatherRetrievedAt = DateTime.now();

  return predictionService.buildForecast(
    hourlyWeather: hourly,
    range: range,
    rate: RateDatabase.getRateForPlan(plan),
    historicalGridDemand: historicalGridDemand,
    historicalDemandThrough: historicalDemandThrough,
    historicalDemandWarning: historicalDemandWarning,
    weatherRetrievedAt: weatherRetrievedAt,
  );
});
