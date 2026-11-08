import '../models/grid_demand_sample.dart';

typedef _MonthHourWeekend = (int, int, bool);
typedef _MonthHour = (int, int);

/// Builds a historical profile from measured hourly grid-demand samples.
class GridDemandProfileService {
  const GridDemandProfileService();

  GridDemandProfile buildProfile(List<GridDemandSample> history) {
    final byMonthHourWeekend = <_MonthHourWeekend, _AverageAccumulator>{};
    final byMonthHour = <_MonthHour, _AverageAccumulator>{};
    final byHour = <int, _AverageAccumulator>{};
    final allLoads = <double>[];

    for (final sample in history) {
      final time = sample.time;
      final isWeekend = _isWeekend(time);
      byMonthHourWeekend
          .putIfAbsent(
            (time.month, time.hour, isWeekend),
            _AverageAccumulator.new,
          )
          .add(sample.demandMw);
      byMonthHour
          .putIfAbsent((time.month, time.hour), _AverageAccumulator.new)
          .add(sample.demandMw);
      byHour
          .putIfAbsent(time.hour, _AverageAccumulator.new)
          .add(sample.demandMw);
      allLoads.add(sample.demandMw);
    }

    allLoads.sort();
    return GridDemandProfile._(
      byMonthHourWeekend: {
        for (final entry in byMonthHourWeekend.entries)
          entry.key: entry.value.average,
      },
      byMonthHour: {
        for (final entry in byMonthHour.entries)
          entry.key: entry.value.average,
      },
      byHour: {
        for (final entry in byHour.entries) entry.key: entry.value.average,
      },
      sortedLoads: List.unmodifiable(allLoads),
    );
  }

  bool _isWeekend(DateTime dateTime) =>
      dateTime.weekday == DateTime.saturday ||
      dateTime.weekday == DateTime.sunday;
}

/// Looks up typical measured load and its percentile in the supplied history.
class GridDemandProfile {
  final Map<_MonthHourWeekend, double> _byMonthHourWeekend;
  final Map<_MonthHour, double> _byMonthHour;
  final Map<int, double> _byHour;
  final List<double> _sortedLoads;

  const GridDemandProfile._({
    required this._byMonthHourWeekend,
    required this._byMonthHour,
    required this._byHour,
    required this._sortedLoads,
  });

  /// Maps a measured load to its percentile across the historical readings.
  /// A score near 50 means the load is around the middle of the dataset;
  /// higher scores mean it is unusually high compared with that history.
  int? scoreForMeasuredLoad(double demandMw) {
    if (_sortedLoads.isEmpty) return null;

    var low = 0;
    var high = _sortedLoads.length;
    while (low < high) {
      final middle = (low + high) ~/ 2;
      if (_sortedLoads[middle] <= demandMw) {
        low = middle + 1;
      } else {
        high = middle;
      }
    }
    return (low * 100 / _sortedLoads.length).round().clamp(0, 100).toInt();
  }

  /// Returns the historical percentile for a future hour, or null if the
  /// supplied data has no readings to compare.
  int? scoreFor(DateTime forecastTime) {
    if (_sortedLoads.isEmpty) return null;

    final isWeekend =
        forecastTime.weekday == DateTime.saturday ||
        forecastTime.weekday == DateTime.sunday;
    final expectedMw =
        _byMonthHourWeekend[(forecastTime.month, forecastTime.hour, isWeekend)] ??
        _byMonthHour[(forecastTime.month, forecastTime.hour)] ??
        _byHour[forecastTime.hour];
    if (expectedMw == null) return null;

    // Binary search for the number of observed values at or below the expected
    // load. This avoids scanning the full history for every forecast hour.
    var low = 0;
    var high = _sortedLoads.length;
    while (low < high) {
      final middle = (low + high) ~/ 2;
      if (_sortedLoads[middle] <= expectedMw) {
        low = middle + 1;
      } else {
        high = middle;
      }
    }
    return (low * 100 / _sortedLoads.length).round().clamp(0, 100).toInt();
  }
}

class _AverageAccumulator {
  double _sum = 0;
  int _count = 0;

  void add(double value) {
    _sum += value;
    _count++;
  }

  double get average => _sum / _count;
}
