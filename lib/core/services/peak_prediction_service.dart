import '../models/demand_forecast.dart';
import '../models/electricity_rate.dart';
import '../models/grid_demand_sample.dart';
import '../models/peak_prediction.dart';
import '../models/weather_data.dart';
import 'grid_demand_profile_service.dart';
import 'rate_schedule_service.dart';

class PeakPredictionService {
  static const _gridDemandProfileService = GridDemandProfileService();
  static const _peakWindowHours = 3;

  PeakPrediction calculate({required WeatherData weather, DateTime? dateTime}) {
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
    ElectricityRate? rate,
    List<GridDemandSample> historicalGridDemand = const [],
    DateTime? historicalDemandThrough,
    String? historicalDemandWarning,
    DateTime? weatherRetrievedAt,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final filtered = _filterForRange(hourlyWeather, range, reference);
    final historicalProfile = historicalGridDemand.isEmpty
        ? null
        : _gridDemandProfileService.buildProfile(historicalGridDemand);
    final applianceHours = range == ForecastRange.today
        ? _filterForNext24Hours(hourlyWeather, reference)
        : filtered;
    final applianceWindow = _findApplianceWindow(
      applianceHours,
      rate: rate,
      after: reference,
      historicalProfile: historicalProfile,
    );

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
        recommendedStart: applianceWindow?.$1,
        recommendedEnd: applianceWindow?.$2,
        recommendedAverageRate: applianceWindow?.$3,
        recommendedDemandScore: applianceWindow?.$4,
        historicalDemandThrough: historicalDemandThrough,
        historicalDemandWarning: historicalDemandWarning,
        weatherRetrievedAt: weatherRetrievedAt,
      );
    }

    final hourlyPoints = filtered.map((weather) {
      final score = _scoreForForecast(
        weather: weather,
        dateTime: weather.time,
        historicalProfile: historicalProfile,
      );
      return DemandForecastPoint(
        time: weather.time,
        score: score,
        level: _levelFor(score),
      );
    }).toList()..sort((a, b) => a.time.compareTo(b.time));
    final points = <DemandForecastPoint>[];

    if (range == ForecastRange.next7Days) {
      // Keep the chart readable with one point per day, but retain hourly
      // scores separately for the Peak period card and appliance advice.
      final byDay = <DateTime, List<DemandForecastPoint>>{};
      for (final point in hourlyPoints) {
        final dayKey = DateTime(
          point.time.year,
          point.time.month,
          point.time.day,
        );
        byDay.putIfAbsent(dayKey, () => []).add(point);
      }

      final sortedDays = byDay.keys.toList()..sort();
      for (final day in sortedDays) {
        final maxScore = byDay[day]!
            .map((point) => point.score)
            .reduce((a, b) => a > b ? a : b);
        points.add(
          DemandForecastPoint(
            time: day,
            score: maxScore,
            level: _levelFor(maxScore),
          ),
        );
      }
    } else {
      points.addAll(hourlyPoints);
    }

    final peakWindow = _findPeakWindow(hourlyPoints);

    return DemandForecast(
      range: range,
      points: points,
      peakStart: peakWindow.$1,
      peakEnd: peakWindow.$2,
      peakScore: peakWindow.$3,
      peakLevel: _levelFor(peakWindow.$3),
      recommendedStart: applianceWindow?.$1,
      recommendedEnd: applianceWindow?.$2,
      recommendedAverageRate: applianceWindow?.$3,
      recommendedDemandScore: applianceWindow?.$4,
      historicalDemandThrough: historicalDemandThrough,
      historicalDemandWarning: historicalDemandWarning,
      weatherRetrievedAt: weatherRetrievedAt,
    );
  }

  /// Keeps Today's chart data unchanged while searching appliance timing over
  /// the next 24 hours, which may include tomorrow's forecast hours.
  List<WeatherData> _filterForNext24Hours(
    List<WeatherData> hourly,
    DateTime reference,
  ) {
    final end = reference.add(const Duration(hours: 24));
    return hourly
        .where(
          (sample) =>
              !sample.time.isBefore(reference) && sample.time.isBefore(end),
        )
        .toList();
  }

  /// Selects the lowest-demand consecutive window for flexible appliances.
  /// When demand scores tie, a lower rate from the selected plan wins.
  (DateTime, DateTime, double?, int)? _findApplianceWindow(
    List<WeatherData> hourly, {
    required ElectricityRate? rate,
    required DateTime after,
    required GridDemandProfile? historicalProfile,
  }) {
    final samples =
        hourly.where((sample) => !sample.time.isBefore(after)).toList()
          ..sort((a, b) => a.time.compareTo(b.time));
    if (samples.isEmpty) return null;
    final windowLength = samples.length < 3 ? samples.length : 3;
    var bestStart = -1;
    var bestDemandScore = double.infinity;
    var bestRate = double.infinity;
    const rateSchedule = RateScheduleService();

    for (var start = 0; start <= samples.length - windowLength; start++) {
      var isConsecutive = true;
      var demandTotal = 0;
      var rateTotal = 0.0;
      for (var offset = 0; offset < windowLength; offset++) {
        final sample = samples[start + offset];
        if (offset > 0 &&
            sample.time
                    .difference(samples[start + offset - 1].time)
                    .inMinutes !=
                60) {
          isConsecutive = false;
          break;
        }
        demandTotal += _scoreForForecast(
          weather: sample,
          dateTime: sample.time,
          historicalProfile: historicalProfile,
        );
        if (rate != null && rate.rateType != RateType.flat) {
          rateTotal +=
              rateSchedule
                  .getCurrentPeriod(rate: rate, dateTime: sample.time)
                  ?.rateCentsPerKwh ??
              0;
        }
      }
      if (!isConsecutive) continue;

      final averageDemand = demandTotal / windowLength;
      final averageRate = rate == null || rate.rateType == RateType.flat
          ? 0.0
          : rateTotal / windowLength;
      if (averageDemand < bestDemandScore ||
          (averageDemand == bestDemandScore && averageRate < bestRate)) {
        bestStart = start;
        bestDemandScore = averageDemand;
        bestRate = averageRate;
      }
    }

    if (bestStart < 0) return null;
    final start = samples[bestStart].time;
    final end = samples[bestStart + windowLength - 1].time.add(
      const Duration(hours: 1),
    );
    final averageRate = rate == null || rate.rateType == RateType.flat
        ? null
        : bestRate;
    return (start, end, averageRate, bestDemandScore.round());
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

  /// Returns (start, end, peakScore) for the highest-scoring 3-hour block.
  (DateTime, DateTime, int) _findPeakWindow(List<DemandForecastPoint> points) {
    if (points.isEmpty) {
      final now = DateTime.now();
      return (now, now.add(const Duration(hours: 1)), 20);
    }

    // Find the highest average score over a bounded, consecutive 3-hour block.
    // Consider all scores so the card still identifies the busiest forecast
    // window when no hour reaches the high-demand threshold.
    var bestStart = -1;
    var bestAverage = -1.0;
    for (var start = 0; start <= points.length - _peakWindowHours; start++) {
      var consecutive = true;
      var total = 0;
      for (var offset = 0; offset < _peakWindowHours; offset++) {
        final point = points[start + offset];
        if (offset > 0 &&
            point.time.difference(points[start + offset - 1].time).inMinutes !=
                60) {
          consecutive = false;
          break;
        }
        total += point.score;
      }
      if (!consecutive) continue;

      final average = total / _peakWindowHours;
      if (average > bestAverage) {
        bestStart = start;
        bestAverage = average;
      }
    }

    if (bestStart >= 0) {
      final start = points[bestStart].time;
      final end = points[bestStart + _peakWindowHours - 1].time.add(
        const Duration(hours: 1),
      );
      return (start, end, bestAverage.round());
    }

    // If the data has gaps or fewer than three consecutive hours, use the
    // highest-scoring available hour rather than presenting a false interval.
    var maxIndex = 0;
    for (var k = 1; k < points.length; k++) {
      if (points[k].score > points[maxIndex].score) {
        maxIndex = k;
      }
    }
    final peak = points[maxIndex];
    return (peak.time, peak.time.add(const Duration(hours: 1)), peak.score);
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

  int _scoreForForecast({
    required WeatherData weather,
    required DateTime dateTime,
    required GridDemandProfile? historicalProfile,
  }) {
    final historicalScore = historicalProfile?.scoreFor(dateTime);
    if (historicalScore == null) {
      return _scoreFor(weather: weather, dateTime: dateTime);
    }

    // The 2024 profile supplies the usual seasonal and hourly demand pattern.
    // Apply a modest cold-weather uplift because electric heating can add load
    // in Nova Scotia. These hand-set values are a heuristic, not a coefficient
    // learned from paired historical weather and demand data.
    final coldWeatherAdjustment = switch (weather.temperature) {
      < -10 => 12,
      < 0 => 8,
      < 5 => 4,
      _ => 0,
    };
    return (historicalScore + coldWeatherAdjustment).clamp(0, 100);
  }

  DemandLevel _levelFor(int score) {
    if (score >= 70) return DemandLevel.high;
    if (score >= 40) return DemandLevel.moderate;
    return DemandLevel.low;
  }
}
