// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:neocare/core/utils/app_colors.dart';
import 'package:neocare/core/utils/app_styles.dart';

import 'package:neocare/features/home/widgets/baby_temp_card.dart';
import 'package:neocare/features/home/widgets/live_camera_card.dart';
import 'package:neocare/features/home/widgets/telemetry_card.dart';
import 'package:neocare/features/home/widgets/weight_card.dart';

class HomeViewBody extends StatefulWidget {
  const HomeViewBody({super.key});

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {
  // Telemetry variables
  double _airTemp = 28.0;
  double _humidity = 60.0;
  double _babyTemp = 36.8;
  int _airQuality = 42;
  int _noise = 35;
  double _weight = 3.2;

  bool _isDanger = false;
  String _statusMessage = "Normal";

  // Networking variables
  String _esp32Ip = "";
  bool _isConnected = false;
  bool _isConnecting = false;
  Timer? _pollingTimer;
  Timer? _simulationTimer;

  @override
  void initState() {
    super.initState();
    // Default to simulation mode until ESP32 IP is supplied
    _startSimulation();
  }

  // Poll real-time data from the ESP32 server over WiFi
  void _startPolling() {
    _pollingTimer?.cancel();
    _simulationTimer?.cancel();

    double factor = 0.0;
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_esp32Ip.isEmpty) return;
      factor += 0.2;

      final url = Uri.parse('http://$_esp32Ip/data');
      try {
        final response = await http.get(url).timeout(const Duration(seconds: 2));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (mounted) {
            setState(() {
              _airTemp = (data['airTemp'] as num).toDouble();
              _humidity = (data['humidity'] as num).toDouble();
              _babyTemp = (data['babyTemp'] as num).toDouble();
              _airQuality = (data['gas'] as num).toInt();
              _noise = (data['sound'] as num).toInt();
              _weight = (data['weight'] as num).toDouble();
              _isDanger = data['danger'] as bool;
              _statusMessage = data['message'] as String;
              _isConnected = true;
              _isConnecting = false;
            });
          }
        } else {
          // If status code is not 200, fallback to simulation
          if (mounted) {
            setState(() {
              _isConnected = false;
              _isConnecting = false;
            });
            _applySimulatedTick(factor);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isConnected = false;
            _isConnecting = false;
          });
          _applySimulatedTick(factor);
        }
      }
    });
  }

  // Extracted helper method so both simulation timer and network fallback loops can use it!
  void _applySimulatedTick(double factor) {
    setState(() {
      // Slow realistic oscillations
      _airTemp = double.parse((28.0 + 0.3 * (factor % 2 * 0.5 - 0.25)).toStringAsFixed(1));
      _humidity = double.parse((60.0 + 1.2 * (factor % 3 * 0.4 - 0.2)).toStringAsFixed(0));
      _babyTemp = double.parse((36.8 + 0.08 * (factor % 1.5 * 0.6 - 0.3)).toStringAsFixed(1));
      _airQuality = (42 + 2 * (factor % 4 - 2).toInt()).toInt();
      _noise = (35 + 3 * (factor % 5 - 2.5).toInt()).toInt();
      _weight = double.parse((3.2 + 0.02 * (factor % 2.5 * 0.4 - 0.2)).toStringAsFixed(1));

      // Evaluate simulator safety thresholds matching ESP32 logic
      _isDanger = false;
      _statusMessage = "Normal";

      if (_airTemp < 25.0 || _airTemp > 37.0) {
        _isDanger = true;
        _statusMessage = "Air Temp Error";
      } else if (_humidity < 50.0 || _humidity > 70.0) {
        _isDanger = true;
        _statusMessage = "Humidity Error";
      } else if (_babyTemp < 36.5 || _babyTemp > 37.5) {
        _isDanger = true;
        _statusMessage = "Baby Temp Error";
      } else if (_airQuality > 500) {
        _isDanger = true;
        _statusMessage = "Gas Detected";
      } else if (_noise > 600) {
        _isDanger = true;
        _statusMessage = "Baby Crying";
      }
    });
  }

  // Fallback high-fidelity simulator
  void _startSimulation() {
    _pollingTimer?.cancel();
    _simulationTimer?.cancel();

    double factor = 0.0;
    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      factor += 0.1;
      _applySimulatedTick(factor);
    });
  }

  // Display beautiful dialog to connect real-time ESP32 local server
  void _showConnectionDialog() {
    final TextEditingController ipController = TextEditingController(text: _esp32Ip);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.wifi_tethering_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(
              'ESP32 Configuration',
              style: AppStyles.headingMedium.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your local ESP32 IP Address to link live telemetry parameters:',
              style: AppStyles.bodyMedium.copyWith(color: AppColors.textLight),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ipController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: 'e.g. 192.168.1.100',
                labelText: 'ESP32 Local IP',
                prefixIcon: const Icon(Icons.settings_ethernet_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startSimulation();
              setState(() {
                _esp32Ip = "";
                _isConnected = false;
                _isConnecting = false;
              });
            },
            child: Text('Clear / Simulate', style: TextStyle(color: Colors.red[700])),
          ),
          ElevatedButton(
            onPressed: () {
              final newIp = ipController.text.trim();
              if (newIp.isNotEmpty) {
                setState(() {
                  _esp32Ip = newIp;
                  _isConnecting = true;
                });
                _startPolling();
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save & Connect', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC), // Ultra-clean hospital dashboard background
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderBar(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isTablet = constraints.maxWidth > 800;
                  final bool isSmallTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 800;

                  if (isTablet) {
                    return _buildLargeTabletLayout();
                  } else if (isSmallTablet) {
                    return _buildSmallTabletLayout();
                  } else {
                    return _buildMobileLayout();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.assignment_ind_rounded,
                color: AppColors.primary,
              ),
            ),
          ),
          GestureDetector(
            onTap: _showConnectionDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _isConnected
                    ? const Color(0xFFE6F4EA)
                    : (_isConnecting
                        ? const Color(0xFFFEF7E0)
                        : (_esp32Ip.isNotEmpty ? const Color(0xFFFCE8E6) : const Color(0xFFF1F3F4))),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isConnected
                      ? const Color(0xFF34A853).withOpacity(0.3)
                      : (_isConnecting
                          ? const Color(0xFFFBBC05).withOpacity(0.3)
                          : (_esp32Ip.isNotEmpty ? const Color(0xFFD93025).withOpacity(0.3) : Colors.transparent)),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isConnected
                        ? Icons.wifi_tethering_rounded
                        : (_isConnecting
                            ? Icons.wifi_tethering_off_rounded
                            : (_esp32Ip.isNotEmpty ? Icons.warning_amber_rounded : Icons.cell_tower_rounded)),
                    size: 14,
                    color: _isConnected
                        ? const Color(0xFF137333)
                        : (_isConnecting
                            ? const Color(0xFFB06000)
                            : (_esp32Ip.isNotEmpty ? const Color(0xFFD93025) : AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isConnected
                        ? 'ESP32 Connected'
                        : (_isConnecting
                            ? 'Connecting...'
                            : (_esp32Ip.isNotEmpty ? 'Reconnecting...' : 'Simulator Active')),
                    style: AppStyles.bodyMedium.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _isConnected
                          ? const Color(0xFF137333)
                          : (_isConnecting
                              ? const Color(0xFFB06000)
                              : (_esp32Ip.isNotEmpty ? const Color(0xFFD93025) : AppColors.textSecondary)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _showConnectionDialog,
              icon: const Icon(
                Icons.settings_rounded,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeTabletLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Camera and Baby Temp
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  LiveCameraCard(
                    isTablet: true,
                    isDanger: _isDanger,
                    statusMessage: _statusMessage,
                  ),
                  const SizedBox(height: 24),
                  BabyTempCard(
                    babyTemp: _babyTemp,
                    isDanger: _isDanger,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Right side: Telemetry Grid
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TelemetryCard(
                          title: 'Room Temp',
                          value: '$_airTemp °C',
                          subtitle: 'Room Temp (25-37)',
                          icon: Icons.thermostat_rounded,
                          progress: (_airTemp - 20) / (40 - 20),
                          isDanger: _airTemp < 25.0 || _airTemp > 37.0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TelemetryCard(
                          title: 'Humidity',
                          value: '$_humidity %',
                          subtitle: 'Humidity (50-70)',
                          icon: Icons.water_drop_rounded,
                          progress: (_humidity - 30) / (90 - 30),
                          isDanger: _humidity < 50.0 || _humidity > 70.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TelemetryCard(
                          title: 'Air Quality',
                          value: '$_airQuality',
                          subtitle: 'Air Quality (<500)',
                          icon: Icons.air_rounded,
                          progress: _airQuality / 800,
                          isDanger: _airQuality > 500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TelemetryCard(
                          title: 'Noise',
                          value: '$_noise dB',
                          subtitle: 'Noise (<60)',
                          icon: Icons.graphic_eq_rounded,
                          progress: _noise / 100,
                          isDanger: _noise > 600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  WeightCard(weight: _weight),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTabletLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        children: [
          LiveCameraCard(
            isTablet: true,
            isDanger: _isDanger,
            statusMessage: _statusMessage,
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: BabyTempCard(
                  babyTemp: _babyTemp,
                  isDanger: _isDanger,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TelemetryCard(
                            title: 'Room Temp',
                            value: '$_airTemp °C',
                            subtitle: 'Room Temp (25-37)',
                            icon: Icons.thermostat_rounded,
                            progress: (_airTemp - 20) / (40 - 20),
                            isDanger: _airTemp < 25.0 || _airTemp > 37.0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TelemetryCard(
                            title: 'Humidity',
                            value: '$_humidity %',
                            subtitle: 'Humidity (50-70)',
                            icon: Icons.water_drop_rounded,
                            progress: (_humidity - 30) / (90 - 30),
                            isDanger: _humidity < 50.0 || _humidity > 70.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TelemetryCard(
                            title: 'Air Quality',
                            value: '$_airQuality',
                            subtitle: 'Air Quality (<500)',
                            icon: Icons.air_rounded,
                            progress: _airQuality / 800,
                            isDanger: _airQuality > 500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TelemetryCard(
                            title: 'Noise',
                            value: '$_noise dB',
                            subtitle: 'Noise (<60)',
                            icon: Icons.graphic_eq_rounded,
                            progress: _noise / 100,
                            isDanger: _noise > 600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          WeightCard(weight: _weight),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          LiveCameraCard(
            isTablet: false,
            isDanger: _isDanger,
            statusMessage: _statusMessage,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TelemetryCard(
                  title: 'Room Temp',
                  value: '$_airTemp °C',
                  subtitle: 'Room Temp (25-37)',
                  icon: Icons.thermostat_rounded,
                  progress: (_airTemp - 20) / (40 - 20),
                  isDanger: _airTemp < 25.0 || _airTemp > 37.0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TelemetryCard(
                  title: 'Humidity',
                  value: '$_humidity %',
                  subtitle: 'Humidity (50-70)',
                  icon: Icons.water_drop_rounded,
                  progress: (_humidity - 30) / (90 - 30),
                  isDanger: _humidity < 50.0 || _humidity > 70.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BabyTempCard(
            babyTemp: _babyTemp,
            isDanger: _isDanger,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TelemetryCard(
                  title: 'Air Quality',
                  value: '$_airQuality',
                  subtitle: 'Air Quality (<500)',
                  icon: Icons.air_rounded,
                  progress: _airQuality / 800,
                  isDanger: _airQuality > 500,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TelemetryCard(
                  title: 'Noise',
                  value: '$_noise dB',
                  subtitle: 'Noise (<60)',
                  icon: Icons.graphic_eq_rounded,
                  progress: _noise / 100,
                  isDanger: _noise > 600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          WeightCard(weight: _weight),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
