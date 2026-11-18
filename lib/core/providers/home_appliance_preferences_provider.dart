import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/home_appliance_preferences.dart';
import '../services/home_appliance_preferences_storage.dart';

final homeAppliancePreferencesProvider =
    FutureProvider<HomeAppliancePreferences>((ref) {
      return HomeAppliancePreferencesStorage().load();
    });
