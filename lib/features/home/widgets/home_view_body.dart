// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:neocare/core/utils/app_colors.dart';
import 'package:neocare/core/utils/app_styles.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:neocare/features/home/widgets/baby_temp_card.dart';
import 'package:neocare/features/home/widgets/live_camera_card.dart';
import 'package:neocare/features/home/widgets/telemetry_card.dart';
import 'package:neocare/features/home/widgets/weight_card.dart';
import 'package:neocare/features/home/models/telemetry_model.dart';
import 'package:neocare/features/home/services/telemetry_service.dart';
import 'package:neocare/core/services/app_preferences.dart';

class HomeViewBody extends StatefulWidget {
  const HomeViewBody({super.key});

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {
  // Structured Telemetry State & Services
  TelemetryModel _telemetry = TelemetryModel.initial();
  final TelemetryService _telemetryService = TelemetryService();

  // Networking variables
  String _esp32Ip = "";
  String _cameraUrl = "http://192.168.1.9:8080";
  bool _isConnected = false;
  bool _isConnecting = false;
  Timer? _pollingTimer;
  Timer? _simulationTimer;

  late final AudioPlayer _audioPlayer;
  bool _isAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadPreferences();
    // Default to simulation mode until ESP32 IP is supplied
    _startSimulation();
  }

  Future<void> _loadPreferences() async {
    final savedEspIp = await AppPreferences.getEsp32Ip();
    final savedCamUrl = await AppPreferences.getCameraUrl();
    if (mounted) {
      setState(() {
        if (savedCamUrl.isNotEmpty) {
          _cameraUrl = savedCamUrl;
        }
        if (savedEspIp.isNotEmpty) {
          _esp32Ip = savedEspIp;
          _isConnecting = true;
          _startPolling();
        }
      });
    }
  }

  // Poll real-time data from the ESP32 server over WiFi
  void _startPolling() {
    _pollingTimer?.cancel();
    _simulationTimer?.cancel();

    double factor = 0.0;
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_esp32Ip.isEmpty) return;
      factor += 0.2;

      try {
        final telemetryData = await _telemetryService.fetchTelemetry(_esp32Ip);
        if (mounted) {
          setState(() {
            _telemetry = telemetryData;
            _isConnected = true;
            _isConnecting = false;
          });
          _updateAlarmSound();
        }
      } catch (e) {
        // If fetch fails, fallback to simulation
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

  // Helper method so both simulation timer and network fallback loops can use it!
  void _applySimulatedTick(double factor) {
    if (mounted) {
      setState(() {
        _telemetry = TelemetryModel.generateSimulated(factor);
      });
      _updateAlarmSound();
    }
  }

  void _updateAlarmSound() async {
    if (_telemetry.isDanger) {
      if (!_isAudioPlaying) {
        _isAudioPlaying = true;
        try {
          await _audioPlayer.setReleaseMode(ReleaseMode.loop);
          await _audioPlayer.play(AssetSource('audio/alarm.mp3'));
        } catch (e) {
          debugPrint("Error playing emergency sound: $e");
        }
      }
    } else {
      if (_isAudioPlaying) {
        _isAudioPlaying = false;
        try {
          await _audioPlayer.stop();
        } catch (e) {
          debugPrint("Error stopping emergency sound: $e");
        }
      }
    }
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
    final TextEditingController ipController = TextEditingController(
      text: _esp32Ip,
    );
    final TextEditingController cameraUrlController = TextEditingController(
      text: _cameraUrl,
    );
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
              style: AppStyles.headingMedium.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your local ESP32 IP Address to link live telemetry parameters:',
                style: AppStyles.bodyMedium.copyWith(color: AppColors.textLight),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ipController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: 'e.g. 192.168.1.100',
                  labelText: 'ESP32 Local IP',
                  prefixIcon: const Icon(Icons.settings_ethernet_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Enter your Live Camera Stream IP/URL:',
                style: AppStyles.bodyMedium.copyWith(color: AppColors.textLight),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cameraUrlController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: 'e.g. http://192.168.1.9:8080',
                  labelText: 'Live Camera URL',
                  prefixIcon: const Icon(Icons.videocam_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startSimulation();
              setState(() {
                _esp32Ip = "";
                _cameraUrl = "";
                _isConnected = false;
                _isConnecting = false;
              });
              AppPreferences.setEsp32Ip("");
              AppPreferences.setCameraUrl("");
            },
            child: Text(
              'Clear / Simulate',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newIp = ipController.text.trim();
              final newCameraUrl = cameraUrlController.text.trim();
              setState(() {
                _cameraUrl = newCameraUrl;
              });
              AppPreferences.setCameraUrl(newCameraUrl);
              if (newIp.isNotEmpty) {
                setState(() {
                  _esp32Ip = newIp;
                  _isConnecting = true;
                });
                AppPreferences.setEsp32Ip(newIp);
                _startPolling();
              } else {
                setState(() {
                  _esp32Ip = "";
                  _isConnected = false;
                  _isConnecting = false;
                });
                AppPreferences.setEsp32Ip("");
                _startSimulation();
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save & Connect',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _simulationTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderBar(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isTablet = constraints.maxWidth > 800;
                  final bool isSmallTablet =
                      constraints.maxWidth > 600 && constraints.maxWidth <= 800;

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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final Color connectedBg = isDark ? const Color(0xFF0F5132).withOpacity(0.4) : const Color(0xFFE6F4EA);
    final Color connectingBg = isDark ? const Color(0xFF664D03).withOpacity(0.4) : const Color(0xFFFEF7E0);
    final Color errorBg = isDark ? const Color(0xFF842029).withOpacity(0.4) : const Color(0xFFFCE8E6);
    final Color inactiveBg = isDark ? const Color(0xFF374151) : const Color(0xFFF1F3F4);

    final Color connectedBorder = isDark ? const Color(0xFF0F5132) : const Color(0xFF34A853).withOpacity(0.3);
    final Color connectingBorder = isDark ? const Color(0xFF664D03) : const Color(0xFFFBBC05).withOpacity(0.3);
    final Color errorBorder = isDark ? const Color(0xFF842029) : const Color(0xFFD93025).withOpacity(0.3);
    final Color inactiveBorder = isDark ? Colors.transparent : Colors.transparent;

    final Color connectedText = isDark ? const Color(0xFF75B798) : const Color(0xFF137333);
    final Color connectingText = isDark ? const Color(0xFFFFDA6A) : const Color(0xFFB06000);
    final Color errorText = isDark ? const Color(0xFFEA868F) : const Color(0xFFD93025);
    final Color inactiveText = isDark ? const Color(0xFFD1D5DB) : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
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
                    ? connectedBg
                    : (_isConnecting
                          ? connectingBg
                          : (_esp32Ip.isNotEmpty
                                ? errorBg
                                : inactiveBg)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isConnected
                      ? connectedBorder
                      : (_isConnecting
                            ? connectingBorder
                            : (_esp32Ip.isNotEmpty
                                  ? errorBorder
                                  : inactiveBorder)),
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
                              : (_esp32Ip.isNotEmpty
                                    ? Icons.warning_amber_rounded
                                    : Icons.cell_tower_rounded)),
                    size: 14,
                    color: _isConnected
                        ? connectedText
                        : (_isConnecting
                              ? connectingText
                              : (_esp32Ip.isNotEmpty
                                    ? errorText
                                    : inactiveText)),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isConnected
                        ? 'ESP32 Connected'
                        : (_isConnecting
                              ? 'Connecting...'
                              : (_esp32Ip.isNotEmpty
                                    ? 'Reconnecting...'
                                    : 'Simulator Active')),
                    style: AppStyles.bodyMedium.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _isConnected
                          ? connectedText
                          : (_isConnecting
                                ? connectingText
                                : (_esp32Ip.isNotEmpty
                                      ? errorText
                                      : inactiveText)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
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
              icon: Icon(
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
                    isDanger: _telemetry.isDanger,
                    statusMessage: _telemetry.statusMessage,
                    cameraUrl: _cameraUrl,
                    onCameraUrlChanged: (newUrl) {
                      setState(() {
                        _cameraUrl = newUrl;
                      });
                      AppPreferences.setCameraUrl(newUrl);
                    },
                  ),
                  const SizedBox(height: 24),
                  BabyTempCard(babyTemp: _telemetry.babyTemp, isDanger: _telemetry.isDanger),
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
                          value: '${_telemetry.airTemp} °C',
                          subtitle: 'Room Temp (25-37)',
                          icon: Icons.thermostat_rounded,
                          progress: (_telemetry.airTemp - 20) / (40 - 20),
                          isDanger: _telemetry.airTemp < 25.0 || _telemetry.airTemp > 37.0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TelemetryCard(
                          title: 'Humidity',
                          value: '${_telemetry.humidity} %',
                          subtitle: 'Humidity (50-70)',
                          icon: Icons.water_drop_rounded,
                          progress: (_telemetry.humidity - 30) / (90 - 30),
                          isDanger: _telemetry.humidity < 50.0 || _telemetry.humidity > 70.0,
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
                          value: '${_telemetry.airQuality}',
                          subtitle: 'Air Quality (<500)',
                          icon: Icons.air_rounded,
                          progress: _telemetry.airQuality / 800,
                          isDanger: _telemetry.airQuality > 500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TelemetryCard(
                          title: 'Noise',
                          value: '${_telemetry.noise} dB',
                          subtitle: 'Noise (<60)',
                          icon: Icons.graphic_eq_rounded,
                          progress: _telemetry.noise / 100,
                          isDanger: _telemetry.noise > 600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  WeightCard(weight: _telemetry.weight),
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
            isDanger: _telemetry.isDanger,
            statusMessage: _telemetry.statusMessage,
            cameraUrl: _cameraUrl,
            onCameraUrlChanged: (newUrl) {
              setState(() {
                _cameraUrl = newUrl;
              });
              AppPreferences.setCameraUrl(newUrl);
            },
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: BabyTempCard(babyTemp: _telemetry.babyTemp, isDanger: _telemetry.isDanger),
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
                            value: '${_telemetry.airTemp} °C',
                            subtitle: 'Room Temp (25-37)',
                            icon: Icons.thermostat_rounded,
                            progress: (_telemetry.airTemp - 20) / (40 - 20),
                            isDanger: _telemetry.airTemp < 25.0 || _telemetry.airTemp > 37.0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TelemetryCard(
                            title: 'Humidity',
                            value: '${_telemetry.humidity} %',
                            subtitle: 'Humidity (50-70)',
                            icon: Icons.water_drop_rounded,
                            progress: (_telemetry.humidity - 30) / (90 - 30),
                            isDanger: _telemetry.humidity < 50.0 || _telemetry.humidity > 70.0,
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
                            value: '${_telemetry.airQuality}',
                            subtitle: 'Air Quality (<500)',
                            icon: Icons.air_rounded,
                            progress: _telemetry.airQuality / 800,
                            isDanger: _telemetry.airQuality > 500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TelemetryCard(
                            title: 'Noise',
                            value: '${_telemetry.noise} dB',
                            subtitle: 'Noise (<60)',
                            icon: Icons.graphic_eq_rounded,
                            progress: _telemetry.noise / 100,
                            isDanger: _telemetry.noise > 600,
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
          WeightCard(weight: _telemetry.weight),
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
            isDanger: _telemetry.isDanger,
            statusMessage: _telemetry.statusMessage,
            cameraUrl: _cameraUrl,
            onCameraUrlChanged: (newUrl) {
              setState(() {
                _cameraUrl = newUrl;
              });
              AppPreferences.setCameraUrl(newUrl);
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TelemetryCard(
                  title: 'Room Temp',
                  value: '${_telemetry.airTemp} °C',
                  subtitle: 'Room Temp (25-37)',
                  icon: Icons.thermostat_rounded,
                  progress: (_telemetry.airTemp - 20) / (40 - 20),
                  isDanger: _telemetry.airTemp < 25.0 || _telemetry.airTemp > 37.0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TelemetryCard(
                  title: 'Humidity',
                  value: '${_telemetry.humidity} %',
                  subtitle: 'Humidity (50-70)',
                  icon: Icons.water_drop_rounded,
                  progress: (_telemetry.humidity - 30) / (90 - 30),
                  isDanger: _telemetry.humidity < 50.0 || _telemetry.humidity > 70.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BabyTempCard(babyTemp: _telemetry.babyTemp, isDanger: _telemetry.isDanger),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TelemetryCard(
                  title: 'Air Quality',
                  value: '${_telemetry.airQuality}',
                  subtitle: 'Air Quality (<500)',
                  icon: Icons.air_rounded,
                  progress: _telemetry.airQuality / 800,
                  isDanger: _telemetry.airQuality > 500,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TelemetryCard(
                  title: 'Noise',
                  value: '${_telemetry.noise} dB',
                  subtitle: 'Noise (<60)',
                  icon: Icons.graphic_eq_rounded,
                  progress: _telemetry.noise / 100,
                  isDanger: _telemetry.noise > 600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          WeightCard(weight: _telemetry.weight),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
