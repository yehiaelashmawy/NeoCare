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
    return TelemetryModel(
      airTemp: (json['airTemp'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      babyTemp: (json['babyTemp'] as num).toDouble(),
      airQuality: (json['gas'] as num).toInt(),
      noise: (json['sound'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      isDanger: json['danger'] as bool,
      statusMessage: json['message'] as String,
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
