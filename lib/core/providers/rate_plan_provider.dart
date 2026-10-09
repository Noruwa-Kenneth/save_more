import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_rate_plan.dart';

/// Currently selected electricity rate plan (persisted).
final ratePlanProvider =
    NotifierProvider<RatePlanNotifier, UserRatePlan>(RatePlanNotifier.new);

class RatePlanNotifier extends Notifier<UserRatePlan> {
  static const String _storageKey = 'selected_rate_plan';

  @override
  UserRatePlan build() => UserRatePlan.standardResidential;

  /// Load the saved plan from disk. Call once at app startup.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored == null) return;

    final match = UserRatePlan.values.where((p) => p.name == stored);
    if (match.isNotEmpty) {
      state = match.first;
    }
  }

  /// Update plan and persist the choice.
  Future<void> setPlan(UserRatePlan plan) async {
    state = plan;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, plan.name);
  }
}
