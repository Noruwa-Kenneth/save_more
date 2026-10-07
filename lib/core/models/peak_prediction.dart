enum DemandLevel {
  low,
  moderate,
  high,
}

class PeakPrediction {
  final int score;
  final DemandLevel level;
  final DateTime calculatedAt;
  final String explanation;
  final String peakStartTime;
  final String peakEndTime;
final String recommendedStartTime;
final String recommendedEndTime;
  const PeakPrediction({
    required this.score,
    required this.level,
    required this.calculatedAt,
    required this.explanation,
    required this.peakStartTime,
    required this.peakEndTime,
     required this.recommendedStartTime,
  required this.recommendedEndTime,
  });

  String get statusText {
    switch (level) {
      case DemandLevel.low:
        return 'LOW';
      case DemandLevel.moderate:
        return 'MODERATE';
      case DemandLevel.high:
        return 'HIGH';
    }
  }

  String get demandText {
    switch (level) {
      case DemandLevel.low:
        return 'Low demand';
      case DemandLevel.moderate:
        return 'Moderate demand';
      case DemandLevel.high:
        return 'High demand';
    }
  }

  String get timeRange {
    return '$peakStartTime – $peakEndTime';
  }


  String get recommendedTimeRange {
  return '$recommendedStartTime – $recommendedEndTime';
}
}