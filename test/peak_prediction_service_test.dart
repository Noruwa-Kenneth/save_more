import 'package:flutter_test/flutter_test.dart';
import 'package:save_more/core/models/demand_forecast.dart';
import 'package:save_more/core/models/weather_data.dart';
import 'package:save_more/core/services/peak_prediction_service.dart';

void main() {
  final service = PeakPredictionService();

  group('PeakPredictionService.buildForecast', () {
    test('Today can recommend a window that starts tomorrow', () {
      final now = DateTime(2025, 1, 6, 23);
      final weather = List.generate(24, (index) {
        final time = now.add(Duration(hours: index));
        return WeatherData(
          temperature: time.day == now.day ? -20 : 10,
          apparentTemperature: time.day == now.day ? -20 : 10,
          weatherCode: 0,
          time: time,
        );
      });

      final forecast = service.buildForecast(
        hourlyWeather: weather,
        range: ForecastRange.today,
        now: now,
      );

      expect(forecast.recommendedStart, DateTime(2025, 1, 7));
      expect(forecast.recommendedEnd, DateTime(2025, 1, 7, 3));
      expect(forecast.recommendedTimeRange, contains('Jan 7'));
    });

    test('does not recommend a window when hours are not consecutive', () {
      final now = DateTime(2025, 1, 6, 9);
      final weather = [
        for (final hour in [9, 11, 13])
          WeatherData(
            temperature: 10,
            apparentTemperature: 10,
            weatherCode: 0,
            time: DateTime(2025, 1, 6, hour),
          ),
      ];

      final forecast = service.buildForecast(
        hourlyWeather: weather,
        range: ForecastRange.today,
        now: now,
      );

      expect(forecast.recommendedTimeRange, isNull);
    });

    test('returns a safe empty-data fallback without an appliance window', () {
      final now = DateTime(2025, 1, 6, 9);

      final forecast = service.buildForecast(
        hourlyWeather: const [],
        range: ForecastRange.today,
        now: now,
      );

      expect(forecast.points, hasLength(1));
      expect(forecast.points.single.score, 20);
      expect(forecast.recommendedTimeRange, isNull);
    });
  });
}
