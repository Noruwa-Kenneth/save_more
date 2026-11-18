import '../services/nova_scotia_time.dart';

class EfficientHabitEntry {
  final String habit;
  final double baselineKwhPerWeek;
  final double currentKwhPerWeek;
  final int weeks;
  final DateTime usualUseTime;
  final DateTime recordedAt;

  const EfficientHabitEntry({
    required this.habit,
    required this.baselineKwhPerWeek,
    required this.currentKwhPerWeek,
    required this.weeks,
    required this.usualUseTime,
    required this.recordedAt,
  });

  String get id => '${habit.trim().toLowerCase()}_${recordedAt.toIso8601String()}';

  Map<String, Object> toJson() => {
    'habit': habit,
    'baselineKwhPerWeek': baselineKwhPerWeek,
    'currentKwhPerWeek': currentKwhPerWeek,
    'weeks': weeks,
    'usualUseTime': usualUseTime.toIso8601String(),
    'recordedAt': recordedAt.toIso8601String(),
  };

  factory EfficientHabitEntry.fromJson(Map<String, dynamic> json) {
    return EfficientHabitEntry(
      habit: json['habit'] as String,
      baselineKwhPerWeek: (json['baselineKwhPerWeek'] as num).toDouble(),
      currentKwhPerWeek: (json['currentKwhPerWeek'] as num).toDouble(),
      weeks: (json['weeks'] as num).toInt(),
      usualUseTime: NovaScotiaTime.parseLocal(json['usualUseTime'] as String),
      recordedAt: NovaScotiaTime.parseLocal(json['recordedAt'] as String),
    );
  }

  double get savedKilowattHours =>
      (baselineKwhPerWeek - currentKwhPerWeek)
          .clamp(0, double.infinity)
          .toDouble() *
      weeks;
}
