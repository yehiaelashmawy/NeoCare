import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/telemetry_model.dart';

class TelemetryService {
  final http.Client _client;

  TelemetryService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches real-time baby telemetry from the local ESP32 server
  Future<TelemetryModel> fetchTelemetry(String ip) async {
    if (ip.isEmpty) {
      throw ArgumentError('IP address cannot be empty');
    }

    final url = Uri.parse('http://$ip/data');
    final response = await _client.get(url).timeout(const Duration(seconds: 2));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return TelemetryModel.fromJson(data);
    } else {
      throw Exception(
        'Failed to load telemetry data: HTTP Status ${response.statusCode}',
      );
    }
  }
}
