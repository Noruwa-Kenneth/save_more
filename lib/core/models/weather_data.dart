class WeatherData {
  final double temperature;
  final double apparentTemperature;
  final int weatherCode;
  final DateTime time;

  const WeatherData({
    required this.temperature,
    required this.apparentTemperature,
    required this.weatherCode,
    required this.time,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'];

    return WeatherData(
      temperature: (current['temperature_2m'] as num).toDouble(),
      apparentTemperature:
          (current['apparent_temperature'] as num).toDouble(),
      weatherCode: current['weather_code'] as int,
      time: DateTime.parse(current['time']),
    );
  }
}