import '../models/electricity_rate.dart';
import '../models/user_rate_plan.dart';

class RateDatabase {
  static ElectricityRate standardResidential =
      ElectricityRate(
    provider: 'Nova Scotia Power',
    planName: 'Standard Residential Service',
    rateType: RateType.flat,
    energyRateCentsPerKwh: 19.128,
    customerChargeMonthly: 20.08,
    effectiveDate: DateTime(2026, 5, 1),
    source: 'Nova Scotia Power',
    currentlyAvailable: true,
  );

  static  ElectricityRate timeOfDay =
      ElectricityRate(
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

 static ElectricityRate timeOfUse = ElectricityRate(
    provider: 'Nova Scotia Power',
    planName: 'Time-of-Use',
    rateType: RateType.timeOfUse,
    schedule: 'Winter peak/off-peak pilot schedule',
    effectiveDate: DateTime(2026, 5, 1),
    source: 'Nova Scotia Power',
    currentlyAvailable: false,
    periods: [
      RatePeriod(
        name: 'Peak',
        rateCentsPerKwh: 0,
        startTime: '7:00 AM',
        endTime: '11:00 AM',
      ),
      RatePeriod(
        name: 'Off-Peak',
        rateCentsPerKwh: 0,
        startTime: '11:00 AM',
        endTime: '5:00 PM',
      ),
      RatePeriod(
        name: 'Peak',
        rateCentsPerKwh: 0,
        startTime: '5:00 PM',
        endTime: '9:00 PM',
      ),
      RatePeriod(
        name: 'Off-Peak',
        rateCentsPerKwh: 0,
        startTime: '9:00 PM',
        endTime: '7:00 AM',
      ),
    ],
  );


  static ElectricityRate getRateForPlan(UserRatePlan plan) {
  switch (plan) {
    case UserRatePlan.standardResidential:
      return standardResidential;

    case UserRatePlan.timeOfDay:
      return timeOfDay;

    case UserRatePlan.timeOfUse:
      throw UnimplementedError(
        'Time-of-Use rate has not been added yet.',
      );

    case UserRatePlan.criticalPeak:
      throw UnimplementedError(
        'Critical Peak rate has not been added yet.',
      );
  }
}
}