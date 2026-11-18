import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

/// Date and time helpers for Nova Scotia's local clock.
class NovaScotiaTime {
  NovaScotiaTime._();

  static const String zoneName = 'America/Halifax';
  static bool _isInitialized = false;

  static tz.Location get location {
    if (!_isInitialized) {
      timezone_data.initializeTimeZones();
      _isInitialized = true;
    }
    return tz.getLocation(zoneName);
  }

  static tz.TZDateTime now() => tz.TZDateTime.now(location);

  static tz.TZDateTime at(
    int year,
    int month,
    int day, [
    int hour = 0,
    int minute = 0,
    int second = 0,
  ]) => tz.TZDateTime(location, year, month, day, hour, minute, second);

  /// Parses a timezone-free date-time string as Nova Scotia wall-clock time.
  static tz.TZDateTime parseLocal(String value) {
    final parsed = DateTime.parse(value);
    return at(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
    );
  }

  static tz.TZDateTime calendarDay(DateTime value, int dayOffset) {
    // Use UTC only to normalize calendar dates without the device timezone.
    final normalized = DateTime.utc(value.year, value.month, value.day + dayOffset);
    return at(normalized.year, normalized.month, normalized.day);
  }
}
