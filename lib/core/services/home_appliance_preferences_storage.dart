import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/home_appliance_preferences.dart';

class HomeAppliancePreferencesStorage {
  static const _storageKey = 'home_appliance_preferences';

  Future<HomeAppliancePreferences> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) return const HomeAppliancePreferences();
    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Saved appliance preferences are invalid.');
    }
    return HomeAppliancePreferences.fromJson(decoded);
  }

  Future<void> save(HomeAppliancePreferences value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(value.toJson()));
  }
}
