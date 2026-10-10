import '../models/electricity_rate.dart';
import '../models/energy_recommendation.dart';

class RecommendationService {
  const RecommendationService();

  EnergyRecommendation createRecommendation({
    required RatePeriod? currentRate,
    required RatePeriod? recommendedRate,
    required double currentDemandScore,
    required String recommendedTimeRange,
  }) {
    final bool isLowDemand = currentDemandScore <= 40;
    final bool isLowerCost = _isLowerCostComparedWith(
      currentRate: currentRate,
      recommendedRate: recommendedRate,
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
        demandLabel: 'Lower demand period',
        isLowerCost: true,
      );
    }

    return EnergyRecommendation(
      timeRange: recommendedTimeRange,
      subtitle: 'Consider shifting usage',
      demandLabel: 'Higher demand',
      isLowerCost: false,
    );
  }

  /// A recommendation is lower cost only when its actual rate is cheaper
  /// than the rate that applies now. Plan labels can vary, so compare prices.
  bool _isLowerCostComparedWith({
    required RatePeriod? currentRate,
    required RatePeriod? recommendedRate,
  }) {
    if (currentRate == null || recommendedRate == null) return false;
    return recommendedRate.rateCentsPerKwh < currentRate.rateCentsPerKwh;
  }
}
