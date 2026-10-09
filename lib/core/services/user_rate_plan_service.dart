import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_rate_plan.dart';

/// Holds the user's selected electricity rate plan and persists it.
///
/// Uses [SharedPreferences] so the choice survives app restarts.
/// Later we can store location and other preferences the same way.
class UserRatePlanService {
  UserRatePlanService._();

  static final UserRatePlanService instance = UserRatePlanService._();

  static const String _storageKey = 'selected_rate_plan';

  UserRatePlan _selectedPlan = UserRatePlan.standardResidential;

  UserRatePlan get selectedPlan => _selectedPlan;

  /// Loads the saved plan from disk (if any).
  /// Call once during app startup (e.g. from the splash screen).
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);

    if (stored == null) return;

    final match = UserRatePlan.values.where((p) => p.name == stored);
    if (match.isNotEmpty) {
      _selectedPlan = match.first;
    }
  }

  /// Updates the in-memory plan and writes it to disk.
  Future<void> setPlan(UserRatePlan plan) async {
    _selectedPlan = plan;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, plan.name);
  }
}
