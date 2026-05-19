class TelemetryModel {
  final double airTemp;
  final double humidity;
  final double babyTemp;
  final int airQuality;
  final int noise;
  final double weight;
  final bool isDanger;
  final String statusMessage;

  const TelemetryModel({
    required this.airTemp,
    required this.humidity,
    required this.babyTemp,
    required this.airQuality,
    required this.noise,
    required this.weight,
    required this.isDanger,
    required this.statusMessage,
  });

  /// Factory constructor to parse JSON telemetry from the ESP32 server
  factory TelemetryModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value, double fallback) {
      if (value == null) return fallback;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? fallback;
      return fallback;
    }

    int parseInt(dynamic value, int fallback) {
      if (value == null) return fallback;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    bool parseBool(dynamic value, bool fallback) {
      if (value == null) return fallback;
      if (value is bool) return value;
      if (value is String) {
        final lower = value.toLowerCase();
        return lower == 'true' || lower == '1';
      }
      if (value is num) return value != 0;
      return fallback;
    }

    return TelemetryModel(
      airTemp: parseDouble(json['airTemp'] ?? json['air_temp'] ?? json['temp'], 28.0),
      humidity: parseDouble(json['humidity'] ?? json['hum'], 60.0),
      babyTemp: parseDouble(json['babyTemp'] ?? json['baby_temp'] ?? json['btemp'], 36.8),
      airQuality: parseInt(json['gas'] ?? json['airQuality'] ?? json['air_quality'] ?? json['mq135'], 42),
      noise: parseInt(json['sound'] ?? json['noise'] ?? json['soundVal'], 35),
      weight: parseDouble(json['weight'] ?? json['w'], 3.2),
      isDanger: parseBool(json['danger'] ?? json['isDanger'] ?? json['is_danger'], false),
      statusMessage: (json['message'] ?? json['statusMessage'] ?? json['status_message'] ?? json['errorMsg'] ?? 'Normal').toString(),
    );
  }

  /// Initial/Baseline model
  factory TelemetryModel.initial() {
    return const TelemetryModel(
      airTemp: 28.0,
      humidity: 60.0,
      babyTemp: 36.8,
      airQuality: 42,
      noise: 35,
      weight: 3.2,
      isDanger: false,
      statusMessage: 'Normal',
    );
  }

  /// High-Fidelity Simulated telemetry tick data
  factory TelemetryModel.generateSimulated(double factor) {
    final double airTemp = double.parse(
      (28.0 + 0.3 * (factor % 2 * 0.5 - 0.25)).toStringAsFixed(1),
    );
    final double humidity = double.parse(
      (60.0 + 1.2 * (factor % 3 * 0.4 - 0.2)).toStringAsFixed(0),
    );
    final double babyTemp = double.parse(
      (36.8 + 0.08 * (factor % 1.5 * 0.6 - 0.3)).toStringAsFixed(1),
    );
    final int airQuality = (42 + 2 * (factor % 4 - 2).toInt()).toInt();
    final int noise = (35 + 3 * (factor % 5 - 2.5).toInt()).toInt();
    final double weight = double.parse(
      (3.2 + 0.02 * (factor % 2.5 * 0.4 - 0.2)).toStringAsFixed(1),
    );

    // Evaluate simulator safety thresholds matching ESP32 hardware firmware logic
    bool isDanger = false;
    String statusMessage = "Normal";

    if (airTemp < 25.0 || airTemp > 37.0) {
      isDanger = true;
      statusMessage = "Air Temp Error";
    } else if (humidity < 50.0 || humidity > 70.0) {
      isDanger = true;
      statusMessage = "Humidity Error";
    } else if (babyTemp < 36.5 || babyTemp > 37.5) {
      isDanger = true;
      statusMessage = "Baby Temp Error";
    } else if (airQuality > 500) {
      isDanger = true;
      statusMessage = "Gas Detected";
    } else if (noise > 600) {
      isDanger = true;
      statusMessage = "Baby Crying";
    }

    return TelemetryModel(
      airTemp: airTemp,
      humidity: humidity,
      babyTemp: babyTemp,
      airQuality: airQuality,
      noise: noise,
      weight: weight,
      isDanger: isDanger,
      statusMessage: statusMessage,
    );
  }
}
