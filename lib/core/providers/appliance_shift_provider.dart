import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/appliance_shift_entry.dart';
import '../services/appliance_shift_storage.dart';

final applianceShiftProvider =
    FutureProvider<List<ApplianceShiftEntry>>((ref) {
      return ApplianceShiftStorage().loadEntries();
    });
