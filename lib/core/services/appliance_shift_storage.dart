import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/appliance_shift_entry.dart';

class ApplianceShiftStorage {
  static const _storageKey = 'completed_appliance_shifts';

  Future<List<ApplianceShiftEntry>> loadEntries() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) return const [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List) {
      throw const FormatException('Saved appliance shifts are not a list.');
    }
    final entries = decoded
        .whereType<Map<String, dynamic>>()
        .map(ApplianceShiftEntry.fromJson)
        .toList();
    entries.sort((a, b) => b.shiftedUseTime.compareTo(a.shiftedUseTime));
    return entries;
  }

  Future<void> saveEntry(ApplianceShiftEntry entry) async {
    final entries = await loadEntries();
    final updated = [
      for (final saved in entries)
        if (saved.duplicateKey != entry.duplicateKey) saved,
      entry,
    ]..sort((a, b) => b.shiftedUseTime.compareTo(a.shiftedUseTime));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(updated.map((saved) => saved.toJson()).toList()),
    );
  }

  Future<void> deleteEntry(ApplianceShiftEntry entry) async {
    final entries = await loadEntries();
    entries.removeWhere((saved) => saved.id == entry.id);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(entries.map((saved) => saved.toJson()).toList()),
    );
  }
}
