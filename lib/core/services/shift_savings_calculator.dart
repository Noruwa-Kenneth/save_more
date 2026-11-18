import '../models/appliance_shift_entry.dart';
import '../models/electricity_rate.dart';
import '../models/efficient_habit_entry.dart';
import '../models/shift_savings_summary.dart';
import 'rate_schedule_service.dart';

class ShiftSavingsCalculator {
  const ShiftSavingsCalculator();

  ShiftSavingsSummary calculate({
    required List<ApplianceShiftEntry> shifts,
    List<EfficientHabitEntry> efficientHabits = const [],
    required ElectricityRate rate,
  }) {
    const schedule = RateScheduleService();
    var peakAvoided = 0.0;
    var offPeakUsage = 0.0;
    for (final shift in shifts) {
      final oldPeriod = schedule.getCurrentPeriod(
        rate: rate,
        dateTime: shift.originalUseTime,
      );
      final newPeriod = schedule.getCurrentPeriod(
        rate: rate,
        dateTime: shift.shiftedUseTime,
      );
      if (oldPeriod == null || newPeriod == null) continue;

      final rateDifference =
          oldPeriod.rateCentsPerKwh - newPeriod.rateCentsPerKwh;
      if (rateDifference <= 0) continue;
      final savings = shift.kilowattHours * rateDifference / 100;
      final oldName = oldPeriod.name.toLowerCase();
      final newName = newPeriod.name.toLowerCase();
      final isHighPeak =
          oldName == 'peak' ||
          oldName.contains('on-peak') ||
          oldName.contains('critical');
      if (isHighPeak) {
        peakAvoided += savings;
      } else if (newName.contains('off-peak') ||
          newName.contains('off peak')) {
        offPeakUsage += savings;
      }
    }

    final habitSavings = _calculateHabitSavings(efficientHabits, rate);

    return ShiftSavingsSummary(
      total: peakAvoided + offPeakUsage + habitSavings,
      peakAvoided: peakAvoided,
      offPeakUsage: offPeakUsage,
      efficientHabits: habitSavings,
    );
  }

  double _calculateHabitSavings(
    List<EfficientHabitEntry> entries,
    ElectricityRate rate,
  ) {
    if (!rate.currentlyAvailable) return 0;
    final schedule = const RateScheduleService();
    var total = 0.0;
    for (final entry in entries) {
      final centsPerKwh = rate.rateType == RateType.flat
          ? rate.energyRateCentsPerKwh
          : schedule
                .getCurrentPeriod(rate: rate, dateTime: entry.usualUseTime)
                ?.rateCentsPerKwh;
      if (centsPerKwh != null) {
        total += entry.savedKilowattHours * centsPerKwh / 100;
      }
    }
    return total;
  }
}
