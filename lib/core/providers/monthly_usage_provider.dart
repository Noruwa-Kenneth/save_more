import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/monthly_usage_entry.dart';
import '../services/monthly_usage_storage.dart';

final monthlyUsageProvider = FutureProvider<List<MonthlyUsageEntry>>((ref) {
  return MonthlyUsageStorage().loadEntries();
});
