enum RateType {
  flat,
  timeOfDay,
  timeOfUse,
  criticalPeak,
}

class RatePeriod {
  final String name;
  final double rateCentsPerKwh;
  final String startTime;
  final String endTime;

  const RatePeriod({
    required this.name,
    required this.rateCentsPerKwh,
    required this.startTime,
    required this.endTime,
  });
}

class ElectricityRate {
  final String provider;
  final String planName;
  final RateType rateType;

  final double? energyRateCentsPerKwh;
  final double? customerChargeMonthly;

  final List<RatePeriod> periods;

  final String schedule;
  final DateTime effectiveDate;
  final String source;

  final bool currentlyAvailable;

  const ElectricityRate({
    required this.provider,
    required this.planName,
    required this.rateType,
    this.energyRateCentsPerKwh,
    this.customerChargeMonthly,
    this.periods = const [],
    this.schedule = '',
    required this.effectiveDate,
    required this.source,
    required this.currentlyAvailable,
  });
}