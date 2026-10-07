import '../models/user_rate_plan.dart';

class UserRatePlanService {
  UserRatePlanService._();

  static final UserRatePlanService instance =
      UserRatePlanService._();

  UserRatePlan _selectedPlan =
      UserRatePlan.standardResidential;

  UserRatePlan get selectedPlan => _selectedPlan;

  void setPlan(UserRatePlan plan) {
    _selectedPlan = plan;
  }
}