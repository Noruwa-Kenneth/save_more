enum UserRatePlan {
  standardResidential,
  timeOfDay,
  timeOfUse,
  criticalPeak,
}

extension UserRatePlanExtension on UserRatePlan {
  String get displayName {
    switch (this) {
      case UserRatePlan.standardResidential:
        return 'Standard Residential';

      case UserRatePlan.timeOfDay:
        return 'Time-of-Day';

      case UserRatePlan.timeOfUse:
        return 'Time-of-Use';

      case UserRatePlan.criticalPeak:
        return 'Critical Peak';
    }
  }
}