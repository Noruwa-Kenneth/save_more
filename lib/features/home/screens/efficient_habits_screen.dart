import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/theme.dart';
import '../../../core/models/efficient_habit_entry.dart';
import '../../../core/providers/efficient_habit_provider.dart';
import '../../../core/services/efficient_habit_storage.dart';
import '../../../core/services/nova_scotia_time.dart';

class EfficientHabitsScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const EfficientHabitsScreen({super.key, required this.onBack});

  @override
  ConsumerState<EfficientHabitsScreen> createState() =>
      _EfficientHabitsScreenState();
}

class _EfficientHabitsScreenState extends ConsumerState<EfficientHabitsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _habitController = TextEditingController();
  final _baselineController = TextEditingController();
  final _currentController = TextEditingController();
  final _weeksController = TextEditingController(text: '4');
  late DateTime _usualUseTime;

  @override
  void initState() {
    super.initState();
    _usualUseTime = NovaScotiaTime.now();
  }

  @override
  void dispose() {
    _habitController.dispose();
    _baselineController.dispose();
    _currentController.dispose();
    _weeksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(efficientHabitProvider);
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
                      'Efficient Habits',
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
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  children: [
                    const Text(
                      'Record a reduction in use',
                      style: TextStyle(
                        color: AppColors.primaryNavy,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Use measured kWh when available. Otherwise, this is an estimate based on the before-and-after amounts you enter.',
                      style: TextStyle(color: AppColors.textMuted, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _habitController,
                            decoration: const InputDecoration(
                              labelText: 'Habit or change',
                              hintText: 'For example, fewer dryer cycles',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Describe the change'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _numberField(
                            _baselineController,
                            label: 'Usual use before the change',
                            suffix: 'kWh/week',
                          ),
                          const SizedBox(height: 12),
                          _numberField(
                            _currentController,
                            label: 'Use after the change',
                            suffix: 'kWh/week',
                          ),
                          const SizedBox(height: 12),
                          _numberField(
                            _weeksController,
                            label: 'Weeks you kept this up',
                            suffix: 'weeks',
                            wholeNumber: true,
                          ),
                          const SizedBox(height: 4),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Usual time this use happened'),
                            subtitle: Text(_formatDateTime(_usualUseTime)),
                            trailing: const Icon(Icons.edit_calendar_outlined),
                            onTap: _pickUsualUseTime,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _saveHabit,
                              icon: const Icon(Icons.check),
                              label: const Text('Save efficient habit'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Recorded habits',
                      style: TextStyle(
                        color: AppColors.primaryNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    entriesAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, _) => const Text(
                        'Could not load recorded habits.',
                      ),
                      data: (entries) => entries.isEmpty
                          ? const Text(
                              'No efficient habits recorded yet.',
                              style: TextStyle(color: AppColors.textMuted),
                            )
                          : Column(
                              children: entries.map(_entryTile).toList(),
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

  Widget _numberField(
    TextEditingController controller, {
    required String label,
    required String suffix,
    bool wholeNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !wholeNumber),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        final amount = wholeNumber
            ? int.tryParse(value?.trim() ?? '')?.toDouble()
            : double.tryParse(value?.trim() ?? '');
        if (amount == null || amount <= 0 || amount > 100000) {
          return 'Enter a valid amount';
        }
        return null;
      },
    );
  }

  Widget _entryTile(EfficientHabitEntry entry) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.eco_outlined, color: AppColors.secondaryNavy),
        title: Text(entry.habit),
        subtitle: Text(
          '${entry.savedKilowattHours.toStringAsFixed(1)} kWh estimated reduction '
          'over ${entry.weeks} weeks',
        ),
      ),
    );
  }

  Future<void> _pickUsualUseTime() async {
    final now = NovaScotiaTime.now();
    final current = _usualUseTime;
    final date = await showDatePicker(
      context: context,
      initialDate: current.isAfter(now) ? now : current,
      firstDate: NovaScotiaTime.at(now.year - 5, 1, 1),
      lastDate: now,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null || !mounted) return;
    setState(() {
      _usualUseTime = NovaScotiaTime.at(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;
    final baseline = double.parse(_baselineController.text.trim());
    final current = double.parse(_currentController.text.trim());
    final weeks = int.parse(_weeksController.text.trim());
    if (current >= baseline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Use after the change must be lower than your baseline.'),
        ),
      );
      return;
    }

    try {
      await EfficientHabitStorage().saveEntry(
        EfficientHabitEntry(
          habit: _habitController.text.trim(),
          baselineKwhPerWeek: baseline,
          currentKwhPerWeek: current,
          weeks: weeks,
          usualUseTime: _usualUseTime,
          recordedAt: NovaScotiaTime.now(),
        ),
      );
      if (!mounted) return;
      ref.invalidate(efficientHabitProvider);
      _formKey.currentState!.reset();
      _habitController.clear();
      _baselineController.clear();
      _currentController.clear();
      _weeksController.text = '4';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Efficient habit saved.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save efficient habit: $error')),
      );
    }
  }

  String _formatDateTime(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}  '
      '${TimeOfDay.fromDateTime(value).format(context)}';
}
