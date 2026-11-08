import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/rate_database.dart';
import '../models/app_location.dart';
import '../models/demand_forecast.dart';
import '../models/energy_recommendation.dart';
import '../models/peak_prediction.dart';
import '../models/user_rate_plan.dart';
import '../services/grid_demand_profile_service.dart';
import '../services/peak_prediction_service.dart';
import '../services/rate_schedule_service.dart';
import '../services/recommendation_service.dart';
import '../services/weather_service.dart';
import 'location_provider.dart';
import 'grid_demand_provider.dart';
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
  final bool usesMeasuredGridDemand;

  const HomeDashboardData({
    required this.location,
    required this.plan,
    required this.prediction,
    required this.recommendation,
    required this.todayForecast,
    this.usesMeasuredGridDemand = false,
  });

  /// Outlook time range — matches Peak Forecast peak period for today.
  String get outlookTimeRange => todayForecast.peakTimeRange;

  /// Outlook demand level — level of today's peak window, not current hour.
  String get outlookDemandLevel => todayForecast.peakDemandText;
}

/// Fetches current demand + today's forecast peak + rate recommendation.
///
/// Re-runs when location, rate plan, or the latest grid report changes.
final homeDashboardProvider = FutureProvider<HomeDashboardData>((ref) async {
  final location = ref.watch(locationProvider);
  final plan = ref.watch(ratePlanProvider);
  final gridStatusAsync = ref.watch(liveGridDemandProvider);
  // Riverpod 3 exposes the previous/current data through `value` (the
  // Riverpod 2 `valueOrNull` getter was removed).
  final reading = gridStatusAsync.value?.reading;
  final gridHistoryFuture = reading != null && reading.isFresh
      ? ref.watch(gridDemandHistoryProvider.future)
      : null;

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

  // Use a fresh utility reading as the meter's current score, ranked against
  // bundled historical grid loads. The raw MW value stays internal.
  int? measuredScore;
  if (gridHistoryFuture != null && reading != null) {
    try {
      final history = await gridHistoryFuture;
      measuredScore = const GridDemandProfileService()
          .buildProfile(history.samples)
          .scoreForMeasuredLoad(reading.netLoadMw);
    } catch (_) {
      // Fall back to the weather estimate when historical comparison fails.
    }
  }

  // Meter = demand right now (current conditions).
  final prediction = predictionService.calculate(
    weather: weather,
    measuredGridDemandScore: measuredScore,
  );

  final electricityRate = RateDatabase.getRateForPlan(plan);

  final currentRate = rateScheduleService.getCurrentPeriod(
    rate: electricityRate,
    dateTime: DateTime.now(),
  );

  final recommendedTimeRange = todayForecast.recommendedTimeRange;
  final recommendedDemandScore = todayForecast.recommendedDemandScore;
  final recommendedAverageRate = todayForecast.recommendedAverageRate;
  final recommendation = recommendedTimeRange == null ||
          recommendedDemandScore == null
      ? const EnergyRecommendation(
          timeRange: 'No suitable window found',
          subtitle:
              'No suitable hourly forecast window is available in the next 24 hours.',
          demandLabel: 'Unavailable',
          isLowerCost: false,
        )
      : recommendationService.createRecommendation(
          currentRate: currentRate,
          recommendedRate: null,
          currentDemandScore: prediction.score.toDouble(),
          recommendedDemandScore: recommendedDemandScore.toDouble(),
          recommendedRateCentsPerKwh: recommendedAverageRate,
          isForecastWindow: true,
          recommendedTimeRange: recommendedTimeRange,
        );

  return HomeDashboardData(
    location: location,
    plan: plan,
    prediction: prediction,
    recommendation: recommendation,
    todayForecast: todayForecast,
    usesMeasuredGridDemand: prediction.usesMeasuredGridDemand,
  );
});
