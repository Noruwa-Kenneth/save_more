import '../models/electricity_rate.dart';

class RateScheduleService {
  const RateScheduleService();

  RatePeriod? getCurrentPeriod({
    required ElectricityRate rate,
    DateTime? dateTime,
  }) {
    final now = dateTime ?? DateTime.now();

    // Standard Residential / flat rate.
    if (rate.rateType == RateType.flat) {
      return null;
    }

    // Time-of-Day plan.
    if (rate.rateType == RateType.timeOfDay) {
      return _getTimeOfDayPeriod(now);
    }

    // Time-of-Use plan.
    if (rate.rateType == RateType.timeOfUse) {
      return _getTimeOfUsePeriod(now);
    }

    return null;
  }

  // ============================================================
  // TIME-OF-DAY
  // ============================================================

  RatePeriod _getTimeOfDayPeriod(DateTime now) {
    final isWeekend =
        now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;

    final isWinter =
        now.month == DateTime.december ||
        now.month == DateTime.january ||
        now.month == DateTime.february;

    // Weekends are off-peak all day.
    if (isWeekend) {
      return const RatePeriod(
        name: 'Off-Peak',
        rateCentsPerKwh: 12.436,
        startTime: '12:00 AM',
        endTime: '11:59 PM',
      );
    }

    // Winter weekday schedule.
    if (isWinter) {
      return _getWinterWeekdayPeriod(now);
    }

    // March through November weekday schedule.
    return _getMarchToNovemberWeekdayPeriod(now);
  }

  RatePeriod _getWinterWeekdayPeriod(DateTime now) {
    final minutes = now.hour * 60 + now.minute;

    if (minutes >= 7 * 60 && minutes < 12 * 60) {
      return const RatePeriod(
        name: 'On-Peak',
        rateCentsPerKwh: 25.188,
        startTime: '7:00 AM',
        endTime: '12:00 PM',
      );
    }

    if (minutes >= 12 * 60 && minutes < 16 * 60) {
      return const RatePeriod(
        name: 'Mid-Peak',
        rateCentsPerKwh: 20.263,
        startTime: '12:00 PM',
        endTime: '4:00 PM',
      );
    }

    if (minutes >= 16 * 60 && minutes < 23 * 60) {
      return const RatePeriod(
        name: 'On-Peak',
        rateCentsPerKwh: 25.188,
        startTime: '4:00 PM',
        endTime: '11:00 PM',
      );
    }

    return const RatePeriod(
      name: 'Off-Peak',
      rateCentsPerKwh: 12.436,
      startTime: '11:00 PM',
      endTime: '7:00 AM',
    );
  }

  RatePeriod _getMarchToNovemberWeekdayPeriod(DateTime now) {
    final minutes = now.hour * 60 + now.minute;

    if (minutes >= 7 * 60 && minutes < 23 * 60) {
      return const RatePeriod(
        name: 'Mid-Peak',
        rateCentsPerKwh: 20.263,
        startTime: '7:00 AM',
        endTime: '11:00 PM',
      );
    }

    return const RatePeriod(
      name: 'Off-Peak',
      rateCentsPerKwh: 12.436,
      startTime: '11:00 PM',
      endTime: '7:00 AM',
    );
  }

  // ============================================================
  // TIME-OF-USE
  // ============================================================

  RatePeriod _getTimeOfUsePeriod(DateTime now) {
    final isWeekend =
        now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;

    final isWinter =
        now.month == DateTime.november ||
        now.month == DateTime.december ||
        now.month == DateTime.january ||
        now.month == DateTime.february ||
        now.month == DateTime.march;

    final minutes = now.hour * 60 + now.minute;

    // Summer (April–October): Reduced all day, including weekends.
    if (!isWinter) {
      return const RatePeriod(
        name: 'Reduced',
        rateCentsPerKwh: 12.436,
        startTime: '12:00 AM',
        endTime: '11:59 PM',
      );
    }

    // Winter weekends are off-peak all day.
    if (isWeekend) {
      return const RatePeriod(
        name: 'Off-Peak',
        rateCentsPerKwh: 12.436,
        startTime: '12:00 AM',
        endTime: '11:59 PM',
      );
    }

    // Winter weekday:
    // 7 AM–11 AM  → Peak
    // 11 AM–5 PM  → Off-Peak
    // 5 PM–9 PM   → Peak
    // 9 PM–7 AM   → Off-Peak
    if (minutes >= 7 * 60 && minutes < 11 * 60) {
      return const RatePeriod(
        name: 'Peak',
        rateCentsPerKwh: 25.188,
        startTime: '7:00 AM',
        endTime: '11:00 AM',
      );
    }

    if (minutes >= 17 * 60 && minutes < 21 * 60) {
      return const RatePeriod(
        name: 'Peak',
        rateCentsPerKwh: 25.188,
        startTime: '5:00 PM',
        endTime: '9:00 PM',
      );
    }

    if (minutes >= 11 * 60 && minutes < 17 * 60) {
      return const RatePeriod(
        name: 'Off-Peak',
        rateCentsPerKwh: 12.436,
        startTime: '11:00 AM',
        endTime: '5:00 PM',
      );
    }

    // Overnight off-peak (9 PM – 7 AM)
    return const RatePeriod(
      name: 'Off-Peak',
      rateCentsPerKwh: 12.436,
      startTime: '9:00 PM',
      endTime: '7:00 AM',
    );
  }

  RatePeriod? getBestTimeToUse({
    required ElectricityRate rate,
    DateTime? dateTime,
  }) {
    final now = dateTime ?? DateTime.now();

    // Standard Residential has a flat rate.
    if (rate.rateType == RateType.flat) {
      return null;
    }

    // Time-of-Day
    if (rate.rateType == RateType.timeOfDay) {
      return const RatePeriod(
        name: 'Off-Peak',
        rateCentsPerKwh: 12.436,
        startTime: '11:00 PM',
        endTime: '7:00 AM',
      );
    }

    // Time-of-Use
    if (rate.rateType == RateType.timeOfUse) {
      final isWeekend =
          now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;

      final isWinter =
          now.month == DateTime.november ||
          now.month == DateTime.december ||
          now.month == DateTime.january ||
          now.month == DateTime.february ||
          now.month == DateTime.march;

      // Summer: Reduced all day.
      if (!isWinter) {
        return const RatePeriod(
          name: 'Reduced',
          rateCentsPerKwh: 12.436,
          startTime: '12:00 AM',
          endTime: '11:59 PM',
        );
      }

      // Winter weekend: Off-Peak all day.
      if (isWeekend) {
        return const RatePeriod(
          name: 'Off-Peak',
          rateCentsPerKwh: 12.436,
          startTime: '12:00 AM',
          endTime: '11:59 PM',
        );
      }

      // Winter weekday: best period is 9 PM – 7 AM.
      return const RatePeriod(
        name: 'Off-Peak',
        rateCentsPerKwh: 12.436,
        startTime: '9:00 PM',
        endTime: '7:00 AM',
      );
    }

    return null;
  }
}
