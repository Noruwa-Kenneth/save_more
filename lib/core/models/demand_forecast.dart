import 'peak_prediction.dart';

/// One point on the demand forecast chart.
class DemandForecastPoint {
  final DateTime time;
  final int score;
  final DemandLevel level;

  const DemandForecastPoint({
    required this.time,
    required this.score,
    required this.level,
  });

  double get normalizedScore => (score / 100).clamp(0.0, 1.0);
}

/// Forecast range selected on the Peak Forecast page.
enum ForecastRange { today, tomorrow, next7Days }

/// Full forecast payload for the Peak Forecast UI.
class DemandForecast {
  final ForecastRange range;
  final List<DemandForecastPoint> points;
  final DateTime peakStart;
  final DateTime peakEnd;
  final int peakScore;
  final DemandLevel peakLevel;
  final DateTime? recommendedStart;
  final DateTime? recommendedEnd;
  final double? recommendedAverageRate;
  final int? recommendedDemandScore;
  final DateTime? historicalDemandThrough;
  final String? historicalDemandWarning;
  final DateTime? weatherRetrievedAt;

  const DemandForecast({
    required this.range,
    required this.points,
    required this.peakStart,
    required this.peakEnd,
    required this.peakScore,
    required this.peakLevel,
    this.recommendedStart,
    this.recommendedEnd,
    this.recommendedAverageRate,
    this.recommendedDemandScore,
    this.historicalDemandThrough,
    this.historicalDemandWarning,
    this.weatherRetrievedAt,
  });

  /// Explains the age and limits of the grid-demand profile used by this
  /// forecast. The profile is historical, never a real-time grid reading.
  String get gridDemandDataNote {
    final through = historicalDemandThrough;
    final base = through == null
        ? 'Historical grid-demand data is unavailable. This forecast uses '
              'weather and schedule patterns only.'
        : _historicalDateNote(through);
    final warning = historicalDemandWarning;
    return warning == null ? base : '$base $warning';
  }

  String _historicalDateNote(DateTime through) {
    final date =
        '${_monthAbbreviation(through.month)} ${through.day}, ${through.year}';
    final age = DateTime.now().difference(through).inDays;
    final freshness = age > 365
        ? ' This profile is over a year old.'
        : age > 45
        ? ' The newest reading is $age days old, so the published grid data '
              'may be delayed.'
        : '';
    return 'Historical Nova Scotia grid data through $date; it is not live '
        'grid demand.$freshness';
  }

  String get dataFreshnessNote {
    final retrievedAt = weatherRetrievedAt;
    final weatherNote = retrievedAt == null
        ? 'Weather forecast retrieval time is unavailable.'
        : DateTime.now().difference(retrievedAt).inHours >= 6
        ? 'Weather forecast was last retrieved over 6 hours ago; refresh it '
              'before relying on these estimates.'
        : 'Weather forecast retrieved at ${_formatClockTime(retrievedAt)}.';
    return '$gridDemandDataNote $weatherNote';
  }

  static String _formatClockTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  static String _monthAbbreviation(int month) => const [
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

  String get peakTimeRange {
    final startLabel = _formatTime(peakStart);
    final endLabel = _formatTime(peakEnd);
    final spansDays =
        peakStart.year != peakEnd.year ||
        peakStart.month != peakEnd.month ||
        peakStart.day != peakEnd.day;
    if (range == ForecastRange.next7Days || spansDays) {
      return '${_formatShortDate(peakStart)} $startLabel – '
          '${_formatShortDate(peakEnd)} $endLabel';
    }
    return '$startLabel – $endLabel';
  }

  /// Best forecast window to run flexible, high-load appliances.
  String? get recommendedTimeRange {
    final start = recommendedStart;
    final end = recommendedEnd;
    if (start == null || end == null) return null;

    final startLabel = _formatTime(start);
    final endLabel = _formatTime(end);
    final chartDate = points.isEmpty ? null : points.first.time;
    final startsOnAnotherDay =
        range == ForecastRange.today &&
        chartDate != null &&
        (start.year != chartDate.year ||
            start.month != chartDate.month ||
            start.day != chartDate.day);
    if (range == ForecastRange.next7Days ||
        startsOnAnotherDay ||
        start.year != end.year ||
        start.month != end.month ||
        start.day != end.day) {
      return '${_formatShortDate(start)} $startLabel – ${_formatShortDate(end)} $endLabel';
    }
    return '$startLabel – $endLabel';
  }

  /// Human-readable level for the peak window (used on Home Outlook).
  String get peakDemandText {
    switch (peakLevel) {
      case DemandLevel.high:
        return 'High demand';
      case DemandLevel.moderate:
        return 'Moderate demand';
      case DemandLevel.low:
        return 'Low demand';
    }
  }

  String get dateLabel {
    switch (range) {
      case ForecastRange.today:
        return _formatFullDate(
          points.isEmpty ? DateTime.now() : points.first.time,
        );
      case ForecastRange.tomorrow:
        return _formatFullDate(
          points.isEmpty
              ? DateTime.now().add(const Duration(days: 1))
              : points.first.time,
        );
      case ForecastRange.next7Days:
        if (points.isEmpty) return 'Next 7 days';
        final start = points.first.time;
        final end = points.last.time;
        return '${_formatShortDate(start)} – ${_formatShortDate(end)}';
    }
  }

  String get peakAdvice {
    switch (peakLevel) {
      case DemandLevel.high:
        return 'Avoid heavy appliance use\nduring this time.';
      case DemandLevel.moderate:
        return 'Try to shift high-load appliances\naway from this window if you can.';
      case DemandLevel.low:
        return 'Demand is expected to stay\nrelatively low.';
    }
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    if (dt.minute == 0) {
      return '$h12:00 $period';
    }
    return '$h12:$minute $period';
  }

  static String _formatFullDate(DateTime dt) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  static String _formatShortDate(DateTime dt) {
    const months = [
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
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}
