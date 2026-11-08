import 'package:timezone/timezone.dart' as tz;

/// A measured province-wide net-load value from Nova Scotia Power.
class GridDemandReading {
  final double netLoadMw;
  final DateTime reportedAtUtc;
  final DateTime fetchedAtUtc;

  const GridDemandReading({
    required this.netLoadMw,
    required this.reportedAtUtc,
    required this.fetchedAtUtc,
  });

  Duration get age => DateTime.now().toUtc().difference(reportedAtUtc);

  /// The utility report's current-condition values are near-real-time while
  /// the report timestamp is no more than 30 minutes old.
  bool get isFresh =>
      age >= Duration.zero && age <= const Duration(minutes: 30);

  String get reportedAtLabel {
    final atlantic = tz.TZDateTime.from(
      reportedAtUtc,
      tz.getLocation('America/Halifax'),
    );
    final hour = atlantic.hour % 12 == 0 ? 12 : atlantic.hour % 12;
    final minute = atlantic.minute.toString().padLeft(2, '0');
    final period = atlantic.hour >= 12 ? 'PM' : 'AM';
    return '${_monthName(atlantic.month)} ${atlantic.day}, $hour:$minute '
        '$period AT';
  }

  String get ageLabel {
    final minutes = age.inMinutes;
    if (minutes < 60) return '$minutes min ago';
    final hours = age.inHours;
    if (hours < 48) return '$hours hr ago';
    return '${age.inDays} days ago';
  }

  static String _monthName(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];
}

/// Latest reading plus a non-fatal refresh message, if one occurred.
class GridDemandStatus {
  final GridDemandReading? reading;
  final String? refreshMessage;

  const GridDemandStatus({this.reading, this.refreshMessage});
}
