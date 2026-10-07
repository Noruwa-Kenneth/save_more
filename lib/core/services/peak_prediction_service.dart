import '../models/peak_prediction.dart';
import '../models/weather_data.dart';

class PeakPredictionService {
  PeakPrediction calculate({required WeatherData weather, DateTime? dateTime}) {
    final now = dateTime ?? DateTime.now();

    int score = 20;
    final reasons = <String>[];

    final hour = now.hour;

    // -----------------------------------------
    // 1. TEMPERATURE
    // -----------------------------------------

    if (weather.temperature < -10) {
      score += 35;
      reasons.add('very cold weather');
    } else if (weather.temperature < 0) {
      score += 25;
      reasons.add('cold weather');
    } else if (weather.temperature < 5) {
      score += 15;
      reasons.add('cool weather');
    }

    // -----------------------------------------
    // 2. WEEKDAY
    // -----------------------------------------

    final isWeekday =
        now.weekday >= DateTime.monday && now.weekday <= DateTime.friday;

    if (isWeekday) {
      score += 15;
      reasons.add('weekday');
    } else {
      score -= 5;
    }

    // -----------------------------------------
    // 3. EVENING PEAK PERIOD
    // -----------------------------------------

    if (hour >= 16 && hour < 21) {
      score += 30;
      reasons.add('evening peak period');
    }

    // -----------------------------------------
    // 4. MORNING PERIOD
    // -----------------------------------------

    if (hour >= 7 && hour < 10) {
      score += 15;
      reasons.add('morning demand period');
    }

    // Keep score between 0 and 100.
    score = score.clamp(0, 100);

    // -----------------------------------------
    // 5. DETERMINE DEMAND LEVEL
    // -----------------------------------------

    final DemandLevel level;

    if (score >= 70) {
      level = DemandLevel.high;
    } else if (score >= 40) {
      level = DemandLevel.moderate;
    } else {
      level = DemandLevel.low;
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
}
