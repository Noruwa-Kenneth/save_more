import '../models/electricity_rate.dart';
import '../models/energy_recommendation.dart';

class RecommendationService {
  const RecommendationService();

  EnergyRecommendation createRecommendation({
    required RatePeriod? currentRate,
    required double currentDemandScore,
    required String recommendedTimeRange,
  }) {
    final bool isLowDemand = currentDemandScore <= 40;
    final bool isLowerCost = _isLowerCostPeriod(currentRate);

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

  /// Off-Peak and Reduced periods are treated as lower-cost windows.
  bool _isLowerCostPeriod(RatePeriod? currentRate) {
    if (currentRate == null) return false;
    final name = currentRate.name.toLowerCase();
    return name == 'off-peak' || name == 'reduced';
  }
}
