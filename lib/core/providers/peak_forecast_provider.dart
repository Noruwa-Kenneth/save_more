import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/demand_forecast.dart';
import '../services/peak_prediction_service.dart';
import '../services/weather_service.dart';
import 'location_provider.dart';

/// Real demand forecast for the selected range, driven by location weather.
final peakForecastProvider =
    FutureProvider.family<DemandForecast, ForecastRange>((ref, range) async {
  final location = ref.watch(locationProvider);
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
  );
});
