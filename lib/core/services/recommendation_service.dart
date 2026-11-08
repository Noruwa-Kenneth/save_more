import '../models/electricity_rate.dart';
import '../models/energy_recommendation.dart';

class RecommendationService {
  const RecommendationService();

  EnergyRecommendation createRecommendation({
    required RatePeriod? currentRate,
    required RatePeriod? recommendedRate,
    required double currentDemandScore,
    double? recommendedDemandScore,
    double? recommendedRateCentsPerKwh,
    bool isForecastWindow = false,
    required String recommendedTimeRange,
  }) {
    final demandScore = recommendedDemandScore ?? currentDemandScore;
    final bool isLowDemand = demandScore <= 40;
    final bool isLowerCost = _isLowerCostComparedWith(
      currentRate: currentRate,
      recommendedRate: recommendedRate,
      recommendedRateCentsPerKwh: recommendedRateCentsPerKwh,
    );

    if (isLowDemand && isLowerCost) {
      return EnergyRecommendation(
        timeRange: recommendedTimeRange,
        subtitle: 'Lower demand • Lower cost',
        demandLabel: 'Low demand',
        isLowerCost: true,
      );
    }

    if (isLowDemand) {
      return EnergyRecommendation(
        timeRange: recommendedTimeRange,
        subtitle: 'Lower demand',
        demandLabel: 'Low demand',
        isLowerCost: false,
      );
    }

    if (isLowerCost) {
      return EnergyRecommendation(
        timeRange: recommendedTimeRange,
        subtitle: 'Lower cost',
        demandLabel: 'Higher demand',
        isLowerCost: true,
      );
    }

    return EnergyRecommendation(
      timeRange: recommendedTimeRange,
      subtitle: isForecastWindow
          ? 'Lowest-demand available window'
          : 'Consider shifting usage',
      demandLabel: 'Higher demand',
      isLowerCost: false,
    );
  }

  /// A recommendation is lower cost only when its actual rate is cheaper
  /// than the rate that applies now. Plan labels can vary, so compare prices.
  bool _isLowerCostComparedWith({
    required RatePeriod? currentRate,
    required RatePeriod? recommendedRate,
    required double? recommendedRateCentsPerKwh,
  }) {
    if (currentRate == null) return false;
    final recommendedPrice =
        recommendedRateCentsPerKwh ?? recommendedRate?.rateCentsPerKwh;
    if (recommendedPrice == null) return false;
    return recommendedPrice < currentRate.rateCentsPerKwh;
  }
}
