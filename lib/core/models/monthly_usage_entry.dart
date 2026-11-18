class MonthlyUsageEntry {
  final DateTime periodStart;
  final DateTime periodEnd;
  final double kilowattHours;

  const MonthlyUsageEntry({
    required this.periodStart,
    required this.periodEnd,
    required this.kilowattHours,
  });

  Map<String, Object> toJson() => {
    'periodStart': _dateOnly(periodStart).toIso8601String(),
    'periodEnd': _dateOnly(periodEnd).toIso8601String(),
    'kilowattHours': kilowattHours,
  };

  factory MonthlyUsageEntry.fromJson(Map<String, dynamic> json) {
    return MonthlyUsageEntry(
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      kilowattHours: (json['kilowattHours'] as num).toDouble(),
    );
  }

  String get id => '${_dateOnly(periodStart).toIso8601String()}_'
      '${_dateOnly(periodEnd).toIso8601String()}';

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
