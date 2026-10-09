import '../models/electricity_rate.dart';
import '../models/user_rate_plan.dart';

class RateDatabase {
  static ElectricityRate standardResidential = ElectricityRate(
    provider: 'Nova Scotia Power',
    planName: 'Standard Residential Service',
    rateType: RateType.flat,
    energyRateCentsPerKwh: 19.128,
    customerChargeMonthly: 20.08,
    effectiveDate: DateTime(2026, 5, 1),
    source: 'Nova Scotia Power',
    currentlyAvailable: true,
  );

  static ElectricityRate timeOfDay = ElectricityRate(
    provider: 'Nova Scotia Power',
    planName: 'Time-of-Day',
    rateType: RateType.timeOfDay,
    schedule: 'Seasonal',
    effectiveDate: DateTime(2026, 5, 1),
    source: 'Nova Scotia Power',
    currentlyAvailable: true,
    periods: [
      RatePeriod(
        name: 'On-Peak',
        rateCentsPerKwh: 25.188,
        startTime: '7:00 AM',
        endTime: '12:00 PM',
      ),
      RatePeriod(
        name: 'Mid-Peak',
        rateCentsPerKwh: 20.263,
        startTime: '12:00 PM',
        endTime: '4:00 PM',
      ),
      RatePeriod(
        name: 'On-Peak',
        rateCentsPerKwh: 25.188,
        startTime: '4:00 PM',
        endTime: '11:00 PM',
      ),
      RatePeriod(
        name: 'Off-Peak',
        rateCentsPerKwh: 12.436,
        startTime: '11:00 PM',
        endTime: '7:00 AM',
      ),
    ],
  );

  /// Time-of-Use pilot schedule (Nova Scotia Power style).
  /// Rates are approximate placeholders for the pilot structure.
  static ElectricityRate timeOfUse = ElectricityRate(
    provider: 'Nova Scotia Power',
    planName: 'Time-of-Use',
    rateType: RateType.timeOfUse,
    schedule: 'Winter peak/off-peak pilot schedule',
    effectiveDate: DateTime(2026, 5, 1),
    source: 'Nova Scotia Power',
    currentlyAvailable: true,
    periods: [
      RatePeriod(
        name: 'Peak',
        rateCentsPerKwh: 25.188,
        startTime: '7:00 AM',
        endTime: '11:00 AM',
      ),
      RatePeriod(
        name: 'Off-Peak',
        rateCentsPerKwh: 12.436,
        startTime: '11:00 AM',
        endTime: '5:00 PM',
      ),
      RatePeriod(
        name: 'Peak',
        rateCentsPerKwh: 25.188,
        startTime: '5:00 PM',
        endTime: '9:00 PM',
      ),
      RatePeriod(
        name: 'Off-Peak',
        rateCentsPerKwh: 12.436,
        startTime: '9:00 PM',
        endTime: '7:00 AM',
      ),
      RatePeriod(
        name: 'Reduced',
        rateCentsPerKwh: 12.436,
        startTime: '12:00 AM',
        endTime: '11:59 PM',
      ),
    ],
  );

  /// Critical Peak is not fully modeled yet; treated as flat for safety.
  static ElectricityRate criticalPeak = ElectricityRate(
    provider: 'Nova Scotia Power',
    planName: 'Critical Peak',
    rateType: RateType.flat,
    energyRateCentsPerKwh: 19.128,
    customerChargeMonthly: 20.08,
    effectiveDate: DateTime(2026, 5, 1),
    source: 'Nova Scotia Power',
    currentlyAvailable: false,
  );

  static ElectricityRate getRateForPlan(UserRatePlan plan) {
    switch (plan) {
      case UserRatePlan.standardResidential:
        return standardResidential;

      case UserRatePlan.timeOfDay:
        return timeOfDay;

      case UserRatePlan.timeOfUse:
        return timeOfUse;

      case UserRatePlan.criticalPeak:
        return criticalPeak;
    }
  }
}
