import '../services/nova_scotia_time.dart';

enum ShiftSavingsCategory { peakAvoided, offPeakUsage }

class ApplianceShiftEntry {
  final String appliance;
  final double kilowattHours;
  final DateTime originalUseTime;
  final DateTime shiftedUseTime;

  const ApplianceShiftEntry({
    required this.appliance,
    required this.kilowattHours,
    required this.originalUseTime,
    required this.shiftedUseTime,
  });

  String get id => '${appliance}_${originalUseTime.toIso8601String()}_'
      '${shiftedUseTime.toIso8601String()}';

  String get duplicateKey =>
      '${appliance.trim().toLowerCase()}_'
      '${originalUseTime.toIso8601String()}_'
      '${shiftedUseTime.toIso8601String()}';

  Map<String, Object> toJson() => {
    'appliance': appliance,
    'kilowattHours': kilowattHours,
    'originalUseTime': originalUseTime.toIso8601String(),
    'shiftedUseTime': shiftedUseTime.toIso8601String(),
  };

  factory ApplianceShiftEntry.fromJson(Map<String, dynamic> json) {
    return ApplianceShiftEntry(
      appliance: json['appliance'] as String,
      kilowattHours: (json['kilowattHours'] as num).toDouble(),
      originalUseTime: NovaScotiaTime.parseLocal(
        json['originalUseTime'] as String,
      ),
      shiftedUseTime: NovaScotiaTime.parseLocal(
        json['shiftedUseTime'] as String,
      ),
    );
  }
}
