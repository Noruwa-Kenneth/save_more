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
enum ForecastRange {
  today,
  tomorrow,
  next7Days,
}

/// Full forecast payload for the Peak Forecast UI.
class DemandForecast {
  final ForecastRange range;
  final List<DemandForecastPoint> points;
  final DateTime peakStart;
  final DateTime peakEnd;
  final int peakScore;
  final DemandLevel peakLevel;

  const DemandForecast({
    required this.range,
    required this.points,
    required this.peakStart,
    required this.peakEnd,
    required this.peakScore,
    required this.peakLevel,
  });

  String get peakTimeRange {
    return '${_formatTime(peakStart)} – ${_formatTime(peakEnd)}';
  }

  String get dateLabel {
    switch (range) {
      case ForecastRange.today:
        return _formatFullDate(points.isEmpty ? DateTime.now() : points.first.time);
      case ForecastRange.tomorrow:
        return _formatFullDate(
          points.isEmpty ? DateTime.now().add(const Duration(days: 1)) : points.first.time,
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
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  static String _formatShortDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}
