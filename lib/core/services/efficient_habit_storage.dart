import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/efficient_habit_entry.dart';

class EfficientHabitStorage {
  static const _storageKey = 'efficient_habit_entries';

  Future<List<EfficientHabitEntry>> loadEntries() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) return const [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List) {
      throw const FormatException('Saved efficient habits are not a list.');
    }
    final entries = decoded
        .whereType<Map<String, dynamic>>()
        .map(EfficientHabitEntry.fromJson)
        .toList();
    entries.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return entries;
  }

  Future<void> saveEntry(EfficientHabitEntry entry) async {
    final entries = await loadEntries();
    final updatedEntries = [
      entry,
      for (final saved in entries)
        if (saved.id != entry.id) saved,
    ];
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(updatedEntries.map((saved) => saved.toJson()).toList()),
    );
  }
}
