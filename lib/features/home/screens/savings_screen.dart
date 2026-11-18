import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/theme.dart';
import '../../../core/data/rate_database.dart';
import '../../../core/models/appliance_shift_entry.dart';
import '../../../core/models/electricity_rate.dart';
import '../../../core/models/efficient_habit_entry.dart';
import '../../../core/models/shift_savings_summary.dart';
import '../../../core/providers/appliance_shift_provider.dart';
import '../../../core/providers/efficient_habit_provider.dart';
import '../../../core/providers/rate_plan_provider.dart';
import '../../../core/services/shift_savings_calculator.dart';
import '../../../core/services/nova_scotia_time.dart';

class SavingsScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const SavingsScreen({super.key, required this.onBack});

  @override
  ConsumerState<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends ConsumerState<SavingsScreen> {
  String _selectedPeriod = 'This Month';

  @override
  Widget build(BuildContext context) {
    final shiftAsync = ref.watch(applianceShiftProvider);
    final habitAsync = ref.watch(efficientHabitProvider);
    final rate = RateDatabase.getRateForPlan(ref.watch(ratePlanProvider));
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              width: double.infinity,
              color: AppColors.primaryNavy,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  const Text(
                    'Your Savings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFF7F7F7),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedPeriod,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              style: const TextStyle(
                                color: AppColors.primaryNavy,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'This Month',
                                  child: Text('This Month'),
                                ),
                                DropdownMenuItem(
                                  value: 'Last Month',
                                  child: Text('Last Month'),
                                ),
                                DropdownMenuItem(
                                  value: 'Last 3 Months',
                                  child: Text('Last 3 Months'),
                                ),
                                DropdownMenuItem(
                                  value: 'All Time',
                                  child: Text('All Time'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedPeriod = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          shiftAsync.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (error, _) => const Text(
                              'Could not load recorded appliance shifts.',
                            ),
                            data: (allShifts) => habitAsync.when(
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (error, _) => const Text(
                                'Could not load recorded efficient habits.',
                              ),
                              data: (allHabits) => _buildSavingsContent(
                                allShifts,
                                allHabits,
                                rate,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsContent(
    List<ApplianceShiftEntry> allShifts,
    List<EfficientHabitEntry> allHabits,
    ElectricityRate rate,
  ) {
    final shifts = _filterShifts(allShifts);
    final habits = _filterHabits(allHabits);
    final summary = const ShiftSavingsCalculator().calculate(
      shifts: shifts,
      efficientHabits: habits,
      rate: rate,
    );
    final hasEntries = shifts.isNotEmpty || habits.isNotEmpty;

    return Column(
      children: [
        _estimatedSavingsCard(
          summary,
          hasEntries: hasEntries,
          flatRateShiftOnly:
              rate.rateType == RateType.flat && shifts.isNotEmpty && habits.isEmpty,
        ),
        const SizedBox(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Savings Breakdown',
            style: TextStyle(
              color: AppColors.primaryNavy,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              _SavingsBreakdownRow(
                title: 'Peak Avoided',
                amount: shifts.isEmpty ? '—' : _money(summary.peakAvoided),
              ),
              _SavingsBreakdownRow(
                title: 'Off-Peak Usage',
                amount: shifts.isEmpty ? '—' : _money(summary.offPeakUsage),
              ),
              _SavingsBreakdownRow(
                title: 'Efficient Habits',
                amount: habits.isEmpty || !rate.currentlyAvailable
                    ? '—'
                    : _money(summary.efficientHabits),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Efficient-habit savings use the before-and-after weekly kWh and weeks entered. They are estimates; use measured energy values when available.',
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  List<ApplianceShiftEntry> _filterShifts(List<ApplianceShiftEntry> shifts) {
    final now = NovaScotiaTime.now();
    if (_selectedPeriod == 'All Time') return shifts;
    if (_selectedPeriod == 'This Month') {
      return shifts.where((shift) =>
          shift.shiftedUseTime.year == now.year &&
          shift.shiftedUseTime.month == now.month).toList();
    }
    if (_selectedPeriod == 'Last Month') {
      final previous = NovaScotiaTime.at(now.year, now.month - 1, 1);
      return shifts.where((shift) =>
          shift.shiftedUseTime.year == previous.year &&
          shift.shiftedUseTime.month == previous.month).toList();
    }
    final cutoff = NovaScotiaTime.at(now.year, now.month - 2, 1);
    return shifts.where((shift) => !shift.shiftedUseTime.isBefore(cutoff)).toList();
  }

  List<EfficientHabitEntry> _filterHabits(List<EfficientHabitEntry> entries) {
    final now = NovaScotiaTime.now();
    if (_selectedPeriod == 'All Time') return entries;
    if (_selectedPeriod == 'This Month') {
      return entries.where((entry) =>
          entry.recordedAt.year == now.year &&
          entry.recordedAt.month == now.month).toList();
    }
    if (_selectedPeriod == 'Last Month') {
      final previous = NovaScotiaTime.at(now.year, now.month - 1, 1);
      return entries.where((entry) =>
          entry.recordedAt.year == previous.year &&
          entry.recordedAt.month == previous.month).toList();
    }
    final cutoff = NovaScotiaTime.at(now.year, now.month - 2, 1);
    return entries.where((entry) => !entry.recordedAt.isBefore(cutoff)).toList();
  }

  Widget _estimatedSavingsCard(
    ShiftSavingsSummary summary, {
    required bool hasEntries,
    required bool flatRateShiftOnly,
  }) {
    final detail = !hasEntries
        ? 'Savings from logged shifts and efficient habits will show here.'
        : flatRateShiftOnly
        ? 'Your selected plan has a flat energy rate, so shifting time does not change the estimated energy charge.'
        : 'Estimated savings from logged appliance shifts and efficient habits.';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const RadialGradient(
          center: Alignment(-0.6, -0.2),
          radius: 1.4,
          colors: [Color(0xFF0A362A), Color(0xFF031A15)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimated Savings',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  hasEntries ? _money(summary.total) : '—',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  detail,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: const BoxDecoration(
              color: Color(0xFFFFA726),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.savings_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _money(double amount) => '\$${amount.toStringAsFixed(2)}';
}

class _SavingsBreakdownRow extends StatelessWidget {
  final String title;
  final String amount;

  const _SavingsBreakdownRow({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 7,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
