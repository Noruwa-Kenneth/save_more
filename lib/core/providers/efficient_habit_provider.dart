import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/efficient_habit_entry.dart';
import '../services/efficient_habit_storage.dart';

final efficientHabitProvider = FutureProvider<List<EfficientHabitEntry>>((ref) {
  return EfficientHabitStorage().loadEntries();
});
