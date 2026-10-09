import 'package:dio/dio.dart';

import '../models/weather_data.dart';

class WeatherService {
  final Dio _dio;

  WeatherService({Dio? dio}) : _dio = dio ?? Dio();

  Future<WeatherData> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current': 'temperature_2m,apparent_temperature,weather_code',
          'timezone': 'auto',
        },
      );

      return WeatherData.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Unable to fetch weather data: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected weather error: $e');
    }
  }

  /// Hourly temperature forecast for the next [forecastDays] days.
  Future<List<WeatherData>> getHourlyForecast({
    required double latitude,
    required double longitude,
    int forecastDays = 7,
  }) async {
    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'hourly': 'temperature_2m,apparent_temperature,weather_code',
          'forecast_days': forecastDays,
          'timezone': 'auto',
        },
      );

      final hourly = response.data['hourly'] as Map<String, dynamic>;
      final times = (hourly['time'] as List).cast<String>();
      final temps = (hourly['temperature_2m'] as List).cast<num>();
      final apparent = (hourly['apparent_temperature'] as List).cast<num>();
      final codes = (hourly['weather_code'] as List).cast<num>();

      final points = <WeatherData>[];
      for (var i = 0; i < times.length; i++) {
        points.add(
          WeatherData(
            temperature: temps[i].toDouble(),
            apparentTemperature: apparent[i].toDouble(),
            weatherCode: codes[i].toInt(),
            time: DateTime.parse(times[i]),
          ),
        );
      }
      return points;
    } on DioException catch (e) {
      throw Exception('Unable to fetch hourly forecast: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected forecast error: $e');
    }
  }
}
