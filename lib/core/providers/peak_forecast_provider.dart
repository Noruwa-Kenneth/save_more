import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/rate_database.dart';
import '../models/demand_forecast.dart';
import '../services/peak_prediction_service.dart';
import '../services/weather_service.dart';
import 'location_provider.dart';
import 'rate_plan_provider.dart';

/// Weather-based estimated demand forecast for the selected range.
/// This uses weather and schedule heuristics, not measured grid-load data.
final peakForecastProvider =
    FutureProvider.family<DemandForecast, ForecastRange>((ref, range) async {
  final location = ref.watch(locationProvider);
  final plan = ref.watch(ratePlanProvider);
  final weatherService = WeatherService();
  final predictionService = PeakPredictionService();

  final hourly = await weatherService.getHourlyForecast(
    latitude: location.latitude,
    longitude: location.longitude,
    forecastDays: 7,
  );

  return predictionService.buildForecast(
    hourlyWeather: hourly,
    range: range,
    rate: RateDatabase.getRateForPlan(plan),
  );
});
