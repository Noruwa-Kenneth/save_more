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
          'current':
              'temperature_2m,apparent_temperature,weather_code',
          'timezone': 'auto',
        },
      );

      return WeatherData.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Unable to fetch weather data: ${e.message}',
      );
    } catch (e) {
      throw Exception(
        'Unexpected weather error: $e',
      );
    }
  }
}