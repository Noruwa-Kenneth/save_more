import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/theme.dart';
import '../../../core/data/rate_database.dart';
import '../../../core/models/appliance_shift_entry.dart';
import '../../../core/providers/appliance_shift_provider.dart';
import '../../../core/providers/rate_plan_provider.dart';
import '../../../core/services/appliance_shift_storage.dart';
import '../../../core/services/nova_scotia_time.dart';

class ApplianceShiftScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const ApplianceShiftScreen({super.key, required this.onBack});

  @override
  ConsumerState<ApplianceShiftScreen> createState() =>
      _ApplianceShiftScreenState();
}

class _ApplianceShiftScreenState extends ConsumerState<ApplianceShiftScreen> {
  final _formKey = GlobalKey<FormState>();
  String _appliance = '';
  String _kwhText = '';
  late DateTime _originalTime;
  late DateTime _shiftedTime;

  @override
  void initState() {
    super.initState();
    final now = NovaScotiaTime.now();
    _originalTime = NovaScotiaTime.at(now.year, now.month, now.day - 2, 17);
    _shiftedTime = NovaScotiaTime.at(now.year, now.month, now.day - 1, 21);
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(applianceShiftProvider);
    final rate = RateDatabase.getRateForPlan(ref.watch(ratePlanProvider));

    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              color: AppColors.primaryNavy,
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Appliance Shifts',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  children: [
                    const Text(
                      'Record a completed shift',
                      style: TextStyle(
                        color: AppColors.primaryNavy,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Enter the appliance energy and when you would have used it versus when you actually used it.',
                      style: TextStyle(color: AppColors.textMuted, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Appliance',
                              hintText: 'For example, dishwasher',
                              border: OutlineInputBorder(),
                            ),
                            onSaved: (value) => _appliance = value!.trim(),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Enter an appliance name'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Energy for this use',
                              suffixText: 'kWh',
                              border: OutlineInputBorder(),
                            ),
                            onSaved: (value) => _kwhText = value!.trim(),
                            validator: (value) {
                              final kwh = double.tryParse(value?.trim() ?? '');
                              return kwh == null || kwh <= 0 || kwh > 1000
                                  ? 'Enter a valid kWh amount'
                                  : null;
                            },
                          ),
                          const SizedBox(height: 8),
                          _dateTimeButton(
                            'Original planned use',
                            _originalTime,
                            (value) => setState(() => _originalTime = value),
                          ),
                          _dateTimeButton(
                            'Actual shifted use',
                            _shiftedTime,
                            (value) => setState(() => _shiftedTime = value),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _saveShift,
                              icon: const Icon(Icons.check),
                              label: const Text('Save completed shift'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Recorded shifts',
                      style: TextStyle(
                        color: AppColors.primaryNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    entriesAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, _) => Text('Could not load shifts: $error'),
                      data: (entries) => entries.isEmpty
                          ? const Text(
                              'No completed shifts recorded yet.',
                              style: TextStyle(color: AppColors.textMuted),
                            )
                          : Column(
                              children: entries
                                  .map(_entryTile)
                                  .toList(),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTimeButton(
    String title,
    DateTime value,
    ValueChanged<DateTime> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(_formatDateTime(value)),
      trailing: const Icon(Icons.edit_calendar_outlined),
      onTap: () async {
        final now = NovaScotiaTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: value.isAfter(now) ? now : value,
          firstDate: NovaScotiaTime.at(now.year - 5, 1, 1),
          lastDate: now,
        );
        if (date == null || !mounted) return;
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value),
        );
        if (time == null || !mounted) return;
        onChanged(
          NovaScotiaTime.at(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          ),
        );
      },
    );
  }

  Widget _entryTile(ApplianceShiftEntry entry) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.electric_bolt_outlined),
        title: Text('${entry.appliance} · ${entry.kilowattHours} kWh'),
        subtitle: Text(
          '${_formatDateTime(entry.originalUseTime)} → '
          '${_formatDateTime(entry.shiftedUseTime)}',
        ),
        trailing: IconButton(
          tooltip: 'Delete this shift',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _deleteShift(entry),
        ),
      ),
    );
  }

  Future<void> _deleteShift(ApplianceShiftEntry entry) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this shift?'),
        content: Text('Remove the ${entry.appliance} shift from your records?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;
    await ApplianceShiftStorage().deleteEntry(entry);
    ref.invalidate(applianceShiftProvider);
  }

  Future<void> _saveShift() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final kwh = double.parse(_kwhText);
    if (!_shiftedTime.isAfter(_originalTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shifted use must be after planned use.')),
      );
      return;
    }
    try {
      await ApplianceShiftStorage().saveEntry(
        ApplianceShiftEntry(
          appliance: _appliance,
          kilowattHours: kwh,
          originalUseTime: _originalTime,
          shiftedUseTime: _shiftedTime,
        ),
      );
      if (!mounted) return;
      ref.invalidate(applianceShiftProvider);
      _formKey.currentState!.reset();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appliance shift saved.')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save appliance shift: $error')),
      );
    }
  }

  String _formatDateTime(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}  '
      '${TimeOfDay.fromDateTime(value).format(context)}';
}
