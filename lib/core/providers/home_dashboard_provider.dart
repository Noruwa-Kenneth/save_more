import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/rate_database.dart';
import '../models/app_location.dart';
import '../models/demand_forecast.dart';
import '../models/energy_recommendation.dart';
import '../models/peak_prediction.dart';
import '../models/user_rate_plan.dart';
import '../services/peak_prediction_service.dart';
import '../services/rate_schedule_service.dart';
import '../services/recommendation_service.dart';
import '../services/weather_service.dart';
import 'location_provider.dart';
import 'peak_forecast_provider.dart';
import 'rate_plan_provider.dart';

/// Combined data shown on the Home dashboard.
class HomeDashboardData {
  final AppLocation location;
  final UserRatePlan plan;

  /// Current grid demand (drives the demand meter).
  final PeakPrediction prediction;

  /// Rate-aware appliance timing advice.
  final EnergyRecommendation recommendation;

  /// Today's forecast peak window (drives Today's Outlook card).
  /// Same source as Peak Forecast → Today tab.
  final DemandForecast todayForecast;

  const HomeDashboardData({
    required this.location,
    required this.plan,
    required this.prediction,
    required this.recommendation,
    required this.todayForecast,
  });

  /// Outlook time range — matches Peak Forecast peak period for today.
  String get outlookTimeRange => todayForecast.peakTimeRange;

  /// Outlook demand level — level of today's peak window, not current hour.
  String get outlookDemandLevel => todayForecast.peakDemandText;
}

/// Fetches current demand + today's forecast peak + rate recommendation.
///
/// Automatically re-runs when location or rate plan change.
final homeDashboardProvider = FutureProvider<HomeDashboardData>((ref) async {
  final location = ref.watch(locationProvider);
  final plan = ref.watch(ratePlanProvider);

  // Reuse the same today forecast provider as the Peak Forecast page
  // so Home Outlook and Peak Forecast stay in sync (and share the cache).
  final todayForecast = await ref.watch(
    peakForecastProvider(ForecastRange.today).future,
  );

  final weatherService = WeatherService();
  final predictionService = PeakPredictionService();
  const recommendationService = RecommendationService();
  const rateScheduleService = RateScheduleService();

  final weather = await weatherService.getCurrentWeather(
    latitude: location.latitude,
    longitude: location.longitude,
  );

  // Meter = demand right now (current conditions).
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

  final recommendedTimeRange = bestTime != null
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
    todayForecast: todayForecast,
  );
});
