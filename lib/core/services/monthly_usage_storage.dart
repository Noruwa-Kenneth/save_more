import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/monthly_usage_entry.dart';

class MonthlyUsageStorage {
  static const _storageKey = 'monthly_household_usage_entries';

  Future<List<MonthlyUsageEntry>> loadEntries() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedEntries = preferences.getString(_storageKey);
    if (encodedEntries == null) return const [];

    final decoded = jsonDecode(encodedEntries);
    if (decoded is! List) {
      throw const FormatException('Saved electricity usage is not a list.');
    }

    final entries = decoded
        .whereType<Map<String, dynamic>>()
        .map(MonthlyUsageEntry.fromJson)
        .toList();
    entries.sort((a, b) => b.periodEnd.compareTo(a.periodEnd));
    return entries;
  }

  Future<void> saveEntry(MonthlyUsageEntry entry) async {
    final entries = await loadEntries();
    final updatedEntries = [
      for (final saved in entries)
        if (saved.id != entry.id) saved,
      entry,
    ]..sort((a, b) => b.periodEnd.compareTo(a.periodEnd));

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(updatedEntries.map((saved) => saved.toJson()).toList()),
    );
  }
}
