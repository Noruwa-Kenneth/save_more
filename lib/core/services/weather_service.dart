import 'package:dio/dio.dart';

import '../models/weather_data.dart';

class WeatherService {
  final Dio _dio;

  WeatherService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 25),
              sendTimeout: const Duration(seconds: 15),
            ),
          );

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

      final payload = response.data;
      if (payload is! Map || payload['hourly'] is! Map) {
        throw const FormatException(
          'Weather service returned no hourly forecast data.',
        );
      }
      final hourly = Map<String, dynamic>.from(payload['hourly'] as Map);
      final times = hourly['time'];
      final temps = hourly['temperature_2m'];
      final apparent = hourly['apparent_temperature'];
      final codes = hourly['weather_code'];
      if (times is! List || temps is! List) {
        throw const FormatException(
          'Weather service returned incomplete hourly forecast data.',
        );
      }

      final points = <WeatherData>[];
      final availableHours = times.length < temps.length
          ? times.length
          : temps.length;
      for (var i = 0; i < availableHours; i++) {
        final temperature = temps[i];
        if (times[i] is! String ||
            temperature is! num ||
            !temperature.isFinite) {
          continue;
        }
        final time = DateTime.tryParse(times[i] as String);
        if (time == null) continue;

        final apparentTemperature =
            apparent is List &&
                i < apparent.length &&
                apparent[i] is num &&
                (apparent[i] as num).isFinite
            ? (apparent[i] as num).toDouble()
            : temperature.toDouble();
        final weatherCode =
            codes is List &&
                i < codes.length &&
                codes[i] is num &&
                (codes[i] as num).isFinite
            ? (codes[i] as num).toInt()
            : 0;
        points.add(
          WeatherData(
            temperature: temperature.toDouble(),
            apparentTemperature: apparentTemperature,
            weatherCode: weatherCode,
            time: time,
          ),
        );
      }
      if (points.isEmpty) {
        throw const FormatException(
          'Weather service returned no usable forecast hours.',
        );
      }
      return points;
    } on DioException catch (e) {
      throw Exception('Unable to fetch hourly forecast: ${e.message}');
    } on FormatException {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected forecast error: $e');
    }
  }
}
