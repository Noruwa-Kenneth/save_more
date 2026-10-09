import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/rate_database.dart';
import '../models/app_location.dart';
import '../models/energy_recommendation.dart';
import '../models/peak_prediction.dart';
import '../models/user_rate_plan.dart';
import '../services/peak_prediction_service.dart';
import '../services/rate_schedule_service.dart';
import '../services/recommendation_service.dart';
import '../services/weather_service.dart';
import 'location_provider.dart';
import 'rate_plan_provider.dart';

/// Combined data shown on the Home dashboard.
class HomeDashboardData {
  final AppLocation location;
  final UserRatePlan plan;
  final PeakPrediction prediction;
  final EnergyRecommendation recommendation;

  const HomeDashboardData({
    required this.location,
    required this.plan,
    required this.prediction,
    required this.recommendation,
  });
}

/// Fetches weather and builds prediction + recommendation.
///
/// Automatically re-runs when [locationProvider] or [ratePlanProvider] change.
final homeDashboardProvider = FutureProvider<HomeDashboardData>((ref) async {
  final location = ref.watch(locationProvider);
  final plan = ref.watch(ratePlanProvider);

  final weatherService = WeatherService();
  final predictionService = PeakPredictionService();
  const recommendationService = RecommendationService();
  const rateScheduleService = RateScheduleService();

  final weather = await weatherService.getCurrentWeather(
    latitude: location.latitude,
    longitude: location.longitude,
  );

  final prediction = predictionService.calculate(weather: weather);

  final electricityRate = RateDatabase.getRateForPlan(plan);

  final currentRate = rateScheduleService.getCurrentPeriod(
    rate: electricityRate,
    dateTime: DateTime.now(),
  );

  final bestTime = rateScheduleService.getBestTimeToUse(
    rate: electricityRate,
    dateTime: DateTime.now(),
  );

  final recommendedTimeRange =
      bestTime != null
          ? '${bestTime.startTime} – ${bestTime.endTime}'
          : prediction.recommendedTimeRange;

  final recommendation = recommendationService.createRecommendation(
    currentRate: currentRate,
    currentDemandScore: prediction.score.toDouble(),
    recommendedTimeRange: recommendedTimeRange,
  );

  return HomeDashboardData(
    location: location,
    plan: plan,
    prediction: prediction,
    recommendation: recommendation,
  );
});
