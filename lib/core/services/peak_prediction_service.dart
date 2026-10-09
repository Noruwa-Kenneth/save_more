import '../models/demand_forecast.dart';
import '../models/peak_prediction.dart';
import '../models/weather_data.dart';

class PeakPredictionService {
  PeakPrediction calculate({
    required WeatherData weather,
    DateTime? dateTime,
  }) {
    final now = dateTime ?? weather.time;
    final score = _scoreFor(weather: weather, dateTime: now);
    final level = _levelFor(score);

    final reasons = <String>[];
    if (weather.temperature < -10) {
      reasons.add('very cold weather');
    } else if (weather.temperature < 0) {
      reasons.add('cold weather');
    } else if (weather.temperature < 5) {
      reasons.add('cool weather');
    }

    final isWeekday =
        now.weekday >= DateTime.monday && now.weekday <= DateTime.friday;
    if (isWeekday) {
      reasons.add('weekday');
    }

    if (now.hour >= 16 && now.hour < 21) {
      reasons.add('evening peak period');
    } else if (now.hour >= 7 && now.hour < 10) {
      reasons.add('morning demand period');
    }

    final explanation = reasons.isEmpty
        ? 'Normal electricity demand conditions.'
        : reasons.join(', ');

    // Default evening peak window used on the Home summary card.
    return PeakPrediction(
      score: score,
      level: level,
      calculatedAt: now,
      explanation: explanation,
      peakStartTime: '5:00 PM',
      peakEndTime: '9:00 PM',
      recommendedStartTime: '9:00 PM',
      recommendedEndTime: '7:00 AM',
    );
  }

  /// Builds a multi-hour (or multi-day) demand forecast from hourly weather.
  DemandForecast buildForecast({
    required List<WeatherData> hourlyWeather,
    required ForecastRange range,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final filtered = _filterForRange(hourlyWeather, range, reference);

    if (filtered.isEmpty) {
      final fallbackTime = reference;
      return DemandForecast(
        range: range,
        points: [
          DemandForecastPoint(
            time: fallbackTime,
            score: 20,
            level: DemandLevel.low,
          ),
        ],
        peakStart: fallbackTime,
        peakEnd: fallbackTime.add(const Duration(hours: 1)),
        peakScore: 20,
        peakLevel: DemandLevel.low,
      );
    }

    final points = <DemandForecastPoint>[];

    if (range == ForecastRange.next7Days) {
      // One point per day: max score that day.
      final byDay = <DateTime, List<WeatherData>>{};
      for (final w in filtered) {
        final dayKey = DateTime(w.time.year, w.time.month, w.time.day);
        byDay.putIfAbsent(dayKey, () => []).add(w);
      }

      final sortedDays = byDay.keys.toList()..sort();
      for (final day in sortedDays) {
        final samples = byDay[day]!;
        var maxScore = 0;
        late WeatherData maxWeather;
        for (final w in samples) {
          final s = _scoreFor(weather: w, dateTime: w.time);
          if (s >= maxScore) {
            maxScore = s;
            maxWeather = w;
          }
        }
        points.add(
          DemandForecastPoint(
            time: day,
            score: maxScore,
            level: _levelFor(maxScore),
          ),
        );
        // keep analyzer happy if loop empty (shouldn't happen)
        maxWeather;
      }
    } else {
      // Hourly points for today / tomorrow.
      for (final w in filtered) {
        final score = _scoreFor(weather: w, dateTime: w.time);
        points.add(
          DemandForecastPoint(
            time: w.time,
            score: score,
            level: _levelFor(score),
          ),
        );
      }
    }

    final peakWindow = _findPeakWindow(points);

    return DemandForecast(
      range: range,
      points: points,
      peakStart: peakWindow.$1,
      peakEnd: peakWindow.$2,
      peakScore: peakWindow.$3,
      peakLevel: _levelFor(peakWindow.$3),
    );
  }

  List<WeatherData> _filterForRange(
    List<WeatherData> hourly,
    ForecastRange range,
    DateTime reference,
  ) {
    final startOfToday = DateTime(
      reference.year,
      reference.month,
      reference.day,
    );
    final startOfTomorrow = startOfToday.add(const Duration(days: 1));
    final startOfDayAfter = startOfToday.add(const Duration(days: 2));
    final endOfWeek = startOfToday.add(const Duration(days: 7));

    switch (range) {
      case ForecastRange.today:
        return hourly
            .where(
              (w) =>
                  !w.time.isBefore(startOfToday) &&
                  w.time.isBefore(startOfTomorrow),
            )
            .toList();
      case ForecastRange.tomorrow:
        return hourly
            .where(
              (w) =>
                  !w.time.isBefore(startOfTomorrow) &&
                  w.time.isBefore(startOfDayAfter),
            )
            .toList();
      case ForecastRange.next7Days:
        return hourly
            .where(
              (w) =>
                  !w.time.isBefore(startOfToday) && w.time.isBefore(endOfWeek),
            )
            .toList();
    }
  }

  /// Returns (start, end, peakScore) for the highest-demand window.
  (DateTime, DateTime, int) _findPeakWindow(List<DemandForecastPoint> points) {
    if (points.isEmpty) {
      final now = DateTime.now();
      return (now, now.add(const Duration(hours: 1)), 20);
    }

    // Prefer consecutive high hours (>= 70).
    var bestStart = 0;
    var bestEnd = 0;
    var bestSum = -1;

    var i = 0;
    while (i < points.length) {
      if (points[i].score < 70) {
        i++;
        continue;
      }
      var j = i;
      var sum = 0;
      while (j < points.length && points[j].score >= 70) {
        sum += points[j].score;
        j++;
      }
      if (sum > bestSum) {
        bestSum = sum;
        bestStart = i;
        bestEnd = j - 1;
      }
      i = j;
    }

    if (bestSum >= 0) {
      final start = points[bestStart].time;
      final endPoint = points[bestEnd];
      final end = endPoint.time.add(
        points.length > 24 ? const Duration(hours: 23) : const Duration(hours: 1),
      );
      final avg = (bestSum / (bestEnd - bestStart + 1)).round();
      return (start, end, avg);
    }

    // Fallback: single highest score hour/day.
    var maxIndex = 0;
    for (var k = 1; k < points.length; k++) {
      if (points[k].score > points[maxIndex].score) {
        maxIndex = k;
      }
    }
    final peak = points[maxIndex];
    return (
      peak.time,
      peak.time.add(
        points.length > 24 ? const Duration(hours: 23) : const Duration(hours: 1),
      ),
      peak.score,
    );
  }

  int _scoreFor({required WeatherData weather, required DateTime dateTime}) {
    var score = 20;
    final hour = dateTime.hour;

    if (weather.temperature < -10) {
      score += 35;
    } else if (weather.temperature < 0) {
      score += 25;
    } else if (weather.temperature < 5) {
      score += 15;
    }

    final isWeekday =
        dateTime.weekday >= DateTime.monday &&
        dateTime.weekday <= DateTime.friday;
    if (isWeekday) {
      score += 15;
    } else {
      score -= 5;
    }

    if (hour >= 16 && hour < 21) {
      score += 30;
    }

    if (hour >= 7 && hour < 10) {
      score += 15;
    }

    return score.clamp(0, 100);
  }

  DemandLevel _levelFor(int score) {
    if (score >= 70) return DemandLevel.high;
    if (score >= 40) return DemandLevel.moderate;
    return DemandLevel.low;
  }
}
