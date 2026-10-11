/// One hourly measurement of Nova Scotia's total grid demand.
///
/// [time] is the wall-clock time printed in Nova Scotia Power's historical
/// report. The report does not attach a UTC offset to each row, so callers
/// should not treat this value as a UTC timestamp.
class GridDemandSample {
  final DateTime time;
  final double demandMw;

  const GridDemandSample({required this.time, required this.demandMw});
}
