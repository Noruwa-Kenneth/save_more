import 'package:flutter_test/flutter_test.dart';
import 'package:save_more/core/data/rate_database.dart';
import 'package:save_more/core/services/rate_schedule_service.dart';

void main() {
  const service = RateScheduleService();

  group('Time-of-Day rate schedule', () {
    test('Winter weekday morning should be On-Peak', () {
      final result = service.getCurrentPeriod(
        rate: RateDatabase.timeOfDay,
        dateTime: DateTime(2026, 1, 13, 8, 0),
      );

      expect(result?.name, 'On-Peak');
      expect(result?.rateCentsPerKwh, 25.188);
    });

    test('Winter weekday afternoon should be Mid-Peak', () {
      final result = service.getCurrentPeriod(
        rate: RateDatabase.timeOfDay,
        dateTime: DateTime(2026, 1, 13, 14, 0),
      );

      expect(result?.name, 'Mid-Peak');
      expect(result?.rateCentsPerKwh, 20.263);
    });

    test('Winter weekday evening should be On-Peak', () {
      final result = service.getCurrentPeriod(
        rate: RateDatabase.timeOfDay,
        dateTime: DateTime(2026, 1, 13, 19, 0),
      );

      expect(result?.name, 'On-Peak');
      expect(result?.rateCentsPerKwh, 25.188);
    });

    test('Winter weekday late night should be Off-Peak', () {
      final result = service.getCurrentPeriod(
        rate: RateDatabase.timeOfDay,
        dateTime: DateTime(2026, 1, 13, 23, 30),
      );

      expect(result?.name, 'Off-Peak');
      expect(result?.rateCentsPerKwh, 12.436);
    });

    test('Weekend should be Off-Peak all day', () {
      final weekend = DateTime(2026, 1, 17, 15, 0);
      final result = service.getCurrentPeriod(
        rate: RateDatabase.timeOfDay,
        dateTime: weekend,
      );
      final bestTime = service.getBestTimeToUse(
        rate: RateDatabase.timeOfDay,
        dateTime: weekend,
      );

      expect(result?.name, 'Off-Peak');
      expect(result?.rateCentsPerKwh, 12.436);
      expect(bestTime?.name, 'Off-Peak');
      expect(bestTime?.startTime, '12:00 AM');
      expect(bestTime?.endTime, '11:59 PM');
    });

    test('Summer weekday daytime should be Mid-Peak', () {
      final result = service.getCurrentPeriod(
        rate: RateDatabase.timeOfDay,
        dateTime: DateTime(2026, 7, 14, 15, 0),
      );

      expect(result?.name, 'Mid-Peak');
      expect(result?.rateCentsPerKwh, 20.263);
    });

    test('Summer weekday late night should be Off-Peak', () {
      final result = service.getCurrentPeriod(
        rate: RateDatabase.timeOfDay,
        dateTime: DateTime(2026, 7, 14, 23, 30),
      );

      expect(result?.name, 'Off-Peak');
      expect(result?.rateCentsPerKwh, 12.436);
    });
  });
}
