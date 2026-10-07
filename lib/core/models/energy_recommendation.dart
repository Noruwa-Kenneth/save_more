class EnergyRecommendation {
  final String timeRange;
  final String subtitle;
  final String demandLabel;
  final bool isLowerCost;

  const EnergyRecommendation({
    required this.timeRange,
    required this.subtitle,
    required this.demandLabel,
    required this.isLowerCost,
  });
}