import 'package:flutter_test/flutter_test.dart';
import 'package:save_more/core/data/rate_database.dart';
import 'package:save_more/core/services/rate_schedule_service.dart';

void main() {
  const service = RateScheduleService();

  group('Time-of-Use rate schedule', () {
    test('Winter weekday at 8 AM should be Peak', () {
      final result = service.getCurrentPeriod(
        rate: RateDatabase.timeOfUse,
        dateTime: DateTime(2026, 1, 12, 8, 0),
      );

      expect(result?.name, 'Peak');
      expect(result?.startTime, '7:00 AM');
      expect(result?.endTime, '11:00 AM');
    });

    test('Winter weekday at 11 AM should be Off-Peak', () {
      final result = service.getCurrentPeriod(
        rate: RateDatabase.timeOfUse,
        dateTime: DateTime(2026, 1, 12, 11, 0),
      );

      expect(result?.name, 'Off-Peak');
    });

    test('Winter weekday at 2 PM should be Off-Peak', () {
      final result = service.getCurrentPeriod(
        rate: RateDatabase.timeOfUse,
        dateTime: DateTime(2026, 1, 12, 14, 0),
      );

      expect(result?.name, 'Off-Peak');
    });

    test('Winter weekday at 5 PM should be Peak', () {
      final result = service.getCurrentPeriod(
        rate: RateDatabase.timeOfUse,
        dateTime: DateTime(2026, 1, 12, 17, 0),
      );

      expect(result?.name, 'Peak');
      expect(result?.startTime, '5:00 PM');
      expect(result?.endTime, '9:00 PM');
    });

    test('Winter weekday at 9 PM should be Off-Peak', () {
      final result = service.getCurrentPeriod(
        rate: RateDatabase.timeOfUse,
        dateTime: DateTime(2026, 1, 12, 21, 0),
      );

      expect(result?.name, 'Off-Peak');
    });

    test('Winter weekday at 6 AM should be Off-Peak', () {
      final result = service.getCurrentPeriod(
        rate: RateDatabase.timeOfUse,
        dateTime: DateTime(2026, 1, 12, 6, 0),
      );

      expect(result?.name, 'Off-Peak');
    });

    test('Winter weekend should be Off-Peak all day', () {
      final result = service.getCurrentPeriod(
        rate: RateDatabase.timeOfUse,
        dateTime: DateTime(2026, 1, 17, 14, 0),
      );

      expect(result?.name, 'Off-Peak');
      expect(result?.startTime, '12:00 AM');
      expect(result?.endTime, '11:59 PM');
    });

    test('Summer weekday should be Reduced all day', () {
      final result = service.getCurrentPeriod(
        rate: RateDatabase.timeOfUse,
        dateTime: DateTime(2026, 7, 13, 14, 0),
      );

      expect(result?.name, 'Reduced');
      expect(result?.startTime, '12:00 AM');
      expect(result?.endTime, '11:59 PM');
    });

    test('Summer weekend should be Reduced all day', () {
      final result = service.getCurrentPeriod(
        rate: RateDatabase.timeOfUse,
        dateTime: DateTime(2026, 7, 18, 20, 0),
      );

      expect(result?.name, 'Reduced');
    });
  });
}