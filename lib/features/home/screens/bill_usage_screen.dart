import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/theme.dart';
import '../../../core/data/rate_database.dart';
import '../../../core/models/electricity_rate.dart';
import '../../../core/models/monthly_usage_entry.dart';
import '../../../core/providers/monthly_usage_provider.dart';
import '../../../core/providers/rate_plan_provider.dart';
import '../../../core/services/monthly_usage_storage.dart';

class BillUsageScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const BillUsageScreen({super.key, required this.onBack});

  @override
  ConsumerState<BillUsageScreen> createState() => _BillUsageScreenState();
}

class _BillUsageScreenState extends ConsumerState<BillUsageScreen> {
  String _selectedMonth = 'This Month';

  @override
  Widget build(BuildContext context) {
    final usageAsync = ref.watch(monthlyUsageProvider);
    final plan = ref.watch(ratePlanProvider);
    final rate = RateDatabase.getRateForPlan(plan);

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
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Text(
                    'Bill Usage',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Add bill usage',
                    onPressed: () => _addUsageEntry(context),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
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
                    child: usageAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      error: (error, _) => _MessageCard(
                        icon: Icons.error_outline,
                        title: 'Could not load saved usage',
                        body: 'Please try again.',
                        actionLabel: 'Retry',
                        onAction: () => ref.invalidate(monthlyUsageProvider),
                      ),
                      data: (entries) => _buildUsageContent(entries, rate),
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

  Widget _buildUsageContent(
    List<MonthlyUsageEntry> allEntries,
    ElectricityRate rate,
  ) {
    final entries = _filterEntries(allEntries);
    final totalKwh = entries.fold<double>(
      0,
      (total, entry) => total + entry.kilowattHours,
    );
    final unitRate = rate.currentlyAvailable && rate.rateType == RateType.flat
        ? rate.energyRateCentsPerKwh
        : null;
    final estimatedEnergyCharge = unitRate == null
        ? null
        : totalKwh * unitRate / 100;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMonth,
                    icon: const Icon(Icons.keyboard_arrow_down),
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
                      DropdownMenuItem(value: 'All Bills', child: Text('All Bills')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedMonth = value);
                    },
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _addUsageEntry(context),
                icon: const Icon(Icons.add),
                label: const Text('Add bill'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            _MessageCard(
              icon: Icons.receipt_long_outlined,
              title: 'No bill usage for $_selectedMonth',
              body:
                  'Enter the billing dates and total kWh from your electricity bill. Your entries are saved on this device.',
              actionLabel: 'Enter bill usage',
              onAction: () => _addUsageEntry(context),
            )
          else ...[
            _summaryCard(
              totalKwh: totalKwh,
              estimatedEnergyCharge: estimatedEnergyCharge,
              rate: rate,
            ),
            const SizedBox(height: 22),
            const Text(
              'Bill history',
              style: TextStyle(
                color: AppColors.primaryNavy,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            for (final entry in entries) ...[
              _entryCard(entry),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            Text(
              estimatedEnergyCharge == null
                  ? 'A bill-cost estimate needs usage broken down by time for your ${rate.planName} plan. Monthly kWh alone is not enough.'
                  : 'Energy-charge estimate only. It excludes fixed charges, taxes, and other bill adjustments. It is not a savings calculation.',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<MonthlyUsageEntry> _filterEntries(List<MonthlyUsageEntry> entries) {
    final now = DateTime.now();
    if (_selectedMonth == 'All Bills') return entries;
    if (_selectedMonth == 'This Month') {
      return entries
          .where((entry) =>
              entry.periodEnd.year == now.year &&
              entry.periodEnd.month == now.month)
          .toList();
    }
    if (_selectedMonth == 'Last Month') {
      final lastMonth = DateTime(now.year, now.month - 1);
      return entries
          .where((entry) =>
              entry.periodEnd.year == lastMonth.year &&
              entry.periodEnd.month == lastMonth.month)
          .toList();
    }
    final cutoff = DateTime(now.year, now.month - 2, 1);
    return entries
        .where((entry) => !entry.periodEnd.isBefore(cutoff))
        .toList();
  }

  Widget _summaryCard({
    required double totalKwh,
    required double? estimatedEnergyCharge,
    required ElectricityRate rate,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0A362A), Color(0xFF031A15)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recorded electricity use',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            '${totalKwh.toStringAsFixed(1)} kWh',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (estimatedEnergyCharge != null) ...[
            const SizedBox(height: 14),
            Text(
              'Estimated energy charge: \$${estimatedEnergyCharge.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF9BE7C0),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Using ${rate.energyRateCentsPerKwh!.toStringAsFixed(3)}¢/kWh',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _entryCard(MonthlyUsageEntry entry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_outlined, color: AppColors.secondaryNavy),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatDate(entry.periodStart)} – ${_formatDate(entry.periodEnd)}',
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.kilowattHours.toStringAsFixed(1)} kWh',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addUsageEntry(BuildContext context) async {
    final entry = await showDialog<MonthlyUsageEntry>(
      context: context,
      builder: (_) => const _AddBillUsageDialog(),
    );

    if (entry == null || !mounted) return;
    try {
      await MonthlyUsageStorage().saveEntry(entry);
      ref.invalidate(monthlyUsageProvider);
      setState(() => _selectedMonth = 'All Bills');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save bill usage: $error')),
      );
    }
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

}

class _AddBillUsageDialog extends StatefulWidget {
  const _AddBillUsageDialog();

  @override
  State<_AddBillUsageDialog> createState() => _AddBillUsageDialogState();
}

class _AddBillUsageDialogState extends State<_AddBillUsageDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late DateTime _periodStart;
  late DateTime _periodEnd;

  @override
  void initState() {
    super.initState();
    _periodEnd = DateTime.now();
    _periodStart = DateTime(_periodEnd.year, _periodEnd.month - 1, _periodEnd.day);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add bill usage'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Total usage',
                suffixText: 'kWh',
              ),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                if (amount == null || amount <= 0 || amount > 100000) {
                  return 'Enter a valid kWh amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _dateButton('Bill starts', _periodStart, () => _selectDate(true)),
            _dateButton('Bill ends', _periodEnd, () => _selectDate(false)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  Widget _dateButton(String label, DateTime date, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.calendar_month_outlined),
      label: Text('$label: ${_formatDate(date)}'),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final now = DateTime.now();
    final initial = isStart ? _periodStart : _periodEnd;
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (isStart) {
        _periodStart = selected;
      } else {
        _periodEnd = selected;
      }
    });
  }

  void _save() {
    final amount = double.tryParse(_controller.text.trim());
    if (!_formKey.currentState!.validate()) return;
    if (!_periodEnd.isAfter(_periodStart)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must follow start date.')),
      );
      return;
    }
    Navigator.pop(
      context,
      MonthlyUsageEntry(
        periodStart: _periodStart,
        periodEnd: _periodEnd,
        kilowattHours: amount!,
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageCard({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.secondaryNavy, size: 36),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primaryNavy,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
