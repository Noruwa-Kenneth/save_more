import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_location.dart';

/// Currently selected location (persisted).
final locationProvider =
    NotifierProvider<LocationNotifier, AppLocation>(LocationNotifier.new);

class LocationNotifier extends Notifier<AppLocation> {
  static const String _storageKey = 'selected_location_id';

  @override
  AppLocation build() => AppLocation.defaultLocation;

  /// Load the saved location from disk. Call once at app startup.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getString(_storageKey);
    if (storedId == null) return;
    state = AppLocation.byId(storedId);
  }

  /// Update location and persist the choice.
  Future<void> setLocation(AppLocation location) async {
    state = location;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, location.id);
  }
}
