// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  final ValueNotifier<bool> connectionNotifier;
  final ValueNotifier<bool> connectingNotifier;
  final ValueNotifier<String> espIpNotifier;
  final ValueNotifier<String> cameraUrlNotifier;
  final ValueNotifier<bool> cameraConnectedNotifier;
  final ValueNotifier<bool> cameraCheckingNotifier;

  const HomeViewBody({
    super.key,
    required this.connectionNotifier,
    required this.connectingNotifier,
    required this.espIpNotifier,
    required this.cameraUrlNotifier,
    required this.cameraConnectedNotifier,
    required this.cameraCheckingNotifier,
  });

  @override
  State<HomeViewBody> createState() => HomeViewBodyState();
}

class HomeViewBodyState extends State<HomeViewBody> {
  Future<void> reloadSettings() async {
    await _loadPreferences();
  }

  // Structured Telemetry State & Services
  TelemetryModel _telemetry = TelemetryModel.initial();
  final TelemetryService _telemetryService = TelemetryService();

  // Networking variables
  String _esp32Ip = "";
  String _cameraUrl = "";
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _hasEverConnected = false;
  Timer? _pollingTimer;
  Timer? _simulationTimer;
  Timer? _cameraPollingTimer;

  late final AudioPlayer _audioPlayer;
  bool _isAudioPlaying = false;

  bool get _showLiveData =>
      _isConnected ||
      (_esp32Ip.isNotEmpty && !_isConnecting && _hasEverConnected);

  void _notifyListeners() {
    widget.connectionNotifier.value = _isConnected;
    widget.connectingNotifier.value = _isConnecting;
    widget.espIpNotifier.value = _esp32Ip;
    widget.cameraUrlNotifier.value = _cameraUrl;
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadPreferences();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _simulationTimer?.cancel();
    _cameraPollingTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final savedEspIp = await AppPreferences.getEsp32Ip();
    final savedCamUrl = await AppPreferences.getCameraUrl();
    final alarmVol = await AppPreferences.getAlarmVolume();

    await _audioPlayer.setVolume(alarmVol);

    if (mounted) {
      setState(() {
        _cameraUrl = savedCamUrl ?? "";
        _esp32Ip = savedEspIp ?? "";

        if (_esp32Ip.isNotEmpty) {
          _isConnecting = true;
          _startPolling();
        } else {
          _pollingTimer?.cancel();
          _isConnected = false;
          _isConnecting = false;
          _hasEverConnected = false;
          _updateAlarmSound();
        }
      });
      _startCameraPolling();
      _notifyListeners();
    }
  }

  // Poll real-time data from the ESP32 server over WiFi
  void _startPolling() {
    _pollingTimer?.cancel();
    _simulationTimer?.cancel();

    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_esp32Ip.isEmpty) return;

      try {
        final telemetryData = await _telemetryService.fetchTelemetry(_esp32Ip);
        if (mounted) {
          setState(() {
            _telemetry = telemetryData;
            _isConnected = true;
            _isConnecting = false;
            _hasEverConnected = true;
          });
          _notifyListeners();
          _updateAlarmSound();
        }
      } catch (e) {
        // If fetch fails, update connection states but keep last reads in telemetry
        if (mounted) {
          setState(() {
            _isConnected = false;
            _isConnecting = false;
          });
          _notifyListeners();
          _updateAlarmSound();
        }
      }
    });
  }

  void _startCameraPolling() {
    _cameraPollingTimer?.cancel();
    if (_cameraUrl.isEmpty) {
      widget.cameraConnectedNotifier.value = false;
      widget.cameraCheckingNotifier.value = false;
      return;
    }

    // Run first check immediately
    _runCameraCheck();

    // Setup periodic polling check
    _cameraPollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _runCameraCheck();
    });
  }

  Future<void> _runCameraCheck() async {
    if (_cameraUrl.isEmpty) {
      widget.cameraConnectedNotifier.value = false;
      widget.cameraCheckingNotifier.value = false;
      return;
    }
    widget.cameraCheckingNotifier.value = true;
    try {
      String url = _cameraUrl;
      if (!url.startsWith('http')) {
        url = 'http://$url';
      }
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 2));
      widget.cameraConnectedNotifier.value = response.statusCode == 200;
    } catch (_) {
      widget.cameraConnectedNotifier.value = false;
    } finally {
      widget.cameraCheckingNotifier.value = false;
    }
  }

  void _updateAlarmSound() async {
    if (_isConnected && _telemetry.isDanger) {
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
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textLight,
                ),
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
                'Enter your Live Camera Stream IP:',
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cameraUrlController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: 'e.g. 192.168.1.9:8080',
                  labelText: 'Camera IP',
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
              _pollingTimer?.cancel();
              _simulationTimer?.cancel();
              setState(() {
                _esp32Ip = "";
                _cameraUrl = "";
                _isConnected = false;
                _isConnecting = false;
                _hasEverConnected = false;
                _telemetry = TelemetryModel.initial();
              });
              _startCameraPolling();
              _notifyListeners();
              _updateAlarmSound();
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
              _startCameraPolling();
              _notifyListeners();
              AppPreferences.setCameraUrl(newCameraUrl);
              if (newIp.isNotEmpty) {
                setState(() {
                  _esp32Ip = newIp;
                  _isConnecting = true;
                  _hasEverConnected = false;
                });
                AppPreferences.setEsp32Ip(newIp);
                _startPolling();
              } else {
                setState(() {
                  _esp32Ip = "";
                  _isConnected = false;
                  _isConnecting = false;
                  _hasEverConnected = false;
                  _telemetry = TelemetryModel.initial();
                });
                _pollingTimer?.cancel();
                _simulationTimer?.cancel();
                _updateAlarmSound();
                AppPreferences.setEsp32Ip("");
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

    final Color connectedBg = isDark
        ? const Color(0xFF0F5132).withOpacity(0.4)
        : const Color(0xFFE6F4EA);
    final Color connectingBg = isDark
        ? const Color(0xFF664D03).withOpacity(0.4)
        : const Color(0xFFFEF7E0);
    final Color errorBg = isDark
        ? const Color(0xFF842029).withOpacity(0.4)
        : const Color(0xFFFCE8E6);
    final Color inactiveBg = isDark
        ? const Color(0xFF374151)
        : const Color(0xFFF1F3F4);

    final Color connectedBorder = isDark
        ? const Color(0xFF0F5132)
        : const Color(0xFF34A853).withOpacity(0.3);
    final Color connectingBorder = isDark
        ? const Color(0xFF664D03)
        : const Color(0xFFFBBC05).withOpacity(0.3);
    final Color errorBorder = isDark
        ? const Color(0xFF842029)
        : const Color(0xFFD93025).withOpacity(0.3);
    final Color inactiveBorder = isDark
        ? Colors.transparent
        : Colors.transparent;

    final Color connectedText = isDark
        ? const Color(0xFF75B798)
        : const Color(0xFF137333);
    final Color connectingText = isDark
        ? const Color(0xFFFFDA6A)
        : const Color(0xFFB06000);
    final Color errorText = isDark
        ? const Color(0xFFEA868F)
        : const Color(0xFFD93025);
    final Color inactiveText = isDark
        ? const Color(0xFFD1D5DB)
        : AppColors.textSecondary;

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
            child: Image.asset(
              'assets/images/app_logo.png',
              height: 32,
              width: 32,
              fit: BoxFit.contain,
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
                          : (_esp32Ip.isNotEmpty ? errorBg : inactiveBg)),
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
          const SizedBox(width: 48), // Spacer to keep center pill aligned
        ],
      ),
    );
  }

  Widget _buildLargeTabletLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        children: [
          if (!_isConnected && _esp32Ip.isNotEmpty) ...[
            _buildWarningBanner(),
            const SizedBox(height: 16),
          ],
          Expanded(
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
                            _startCameraPolling();
                            _notifyListeners();
                            AppPreferences.setCameraUrl(newUrl);
                          },
                          isConnected: _isConnected,
                        ),
                        const SizedBox(height: 24),
                        BabyTempCard(
                          babyTemp: _telemetry.babyTemp,
                          isDanger: _isConnected ? _telemetry.isDanger : false,
                          isConnected: _isConnected,
                          showValue: _showLiveData,
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
                                value: _showLiveData
                                    ? '${_telemetry.airTemp} °C'
                                    : '--',
                                subtitle: 'Room Temp (25-37)',
                                icon: Icons.thermostat_rounded,
                                progress: _showLiveData
                                    ? (_telemetry.airTemp - 20) / (40 - 20)
                                    : 0.0,
                                isDanger: _showLiveData
                                    ? (_telemetry.airTemp < 25.0 ||
                                          _telemetry.airTemp > 37.0)
                                    : false,
                                isConnected: _isConnected,
                                isConnecting: _isConnecting,
                                isConfigured: _esp32Ip.isNotEmpty,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TelemetryCard(
                                title: 'Humidity',
                                value: _showLiveData
                                    ? '${_telemetry.humidity} %'
                                    : '--',
                                subtitle: 'Humidity (50-70)',
                                icon: Icons.water_drop_rounded,
                                progress: _showLiveData
                                    ? (_telemetry.humidity - 30) / (90 - 30)
                                    : 0.0,
                                isDanger: _showLiveData
                                    ? (_telemetry.humidity < 50.0 ||
                                          _telemetry.humidity > 70.0)
                                    : false,
                                isConnected: _isConnected,
                                isConnecting: _isConnecting,
                                isConfigured: _esp32Ip.isNotEmpty,
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
                                value: _showLiveData
                                    ? '${_telemetry.airQuality}'
                                    : '--',
                                subtitle: 'Air Quality (<500)',
                                icon: Icons.air_rounded,
                                progress: _showLiveData
                                    ? _telemetry.airQuality / 800
                                    : 0.0,
                                isDanger: _showLiveData
                                    ? _telemetry.airQuality > 500
                                    : false,
                                isConnected: _isConnected,
                                isConnecting: _isConnecting,
                                isConfigured: _esp32Ip.isNotEmpty,
                                progressColor: const Color(0xFF34A853),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TelemetryCard(
                                title: 'Noise',
                                value: _showLiveData
                                    ? '${_telemetry.noise} dB'
                                    : '--',
                                subtitle: 'Noise (<600)',
                                icon: Icons.graphic_eq_rounded,
                                progress: _showLiveData
                                    ? _telemetry.noise / 100
                                    : 0.0,
                                isDanger: _showLiveData
                                    ? _telemetry.noise > 600
                                    : false,
                                isConnected: _isConnected,
                                isConnecting: _isConnecting,
                                isConfigured: _esp32Ip.isNotEmpty,
                                progressColor: const Color(0xFF34A853),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        WeightCard(
                          weight: _telemetry.weight,
                          isConnected: _isConnected,
                          showValue: _showLiveData,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
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
          if (!_isConnected && _esp32Ip.isNotEmpty) ...[
            _buildWarningBanner(),
            const SizedBox(height: 16),
          ],
          LiveCameraCard(
            isTablet: true,
            isDanger: _telemetry.isDanger,
            statusMessage: _telemetry.statusMessage,
            cameraUrl: _cameraUrl,
            onCameraUrlChanged: (newUrl) {
              setState(() {
                _cameraUrl = newUrl;
              });
              _startCameraPolling();
              _notifyListeners();
              AppPreferences.setCameraUrl(newUrl);
            },
            isConnected: _isConnected,
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: BabyTempCard(
                  babyTemp: _telemetry.babyTemp,
                  isDanger: _isConnected ? _telemetry.isDanger : false,
                  isConnected: _isConnected,
                  showValue: _showLiveData,
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
                            value: _showLiveData
                                ? '${_telemetry.airTemp} °C'
                                : '--',
                            subtitle: 'Room Temp (25-37)',
                            icon: Icons.thermostat_rounded,
                            progress: _showLiveData
                                ? (_telemetry.airTemp - 20) / (40 - 20)
                                : 0.0,
                            isDanger: _showLiveData
                                ? (_telemetry.airTemp < 25.0 ||
                                      _telemetry.airTemp > 37.0)
                                : false,
                            isConnected: _isConnected,
                            isConnecting: _isConnecting,
                            isConfigured: _esp32Ip.isNotEmpty,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TelemetryCard(
                            title: 'Humidity',
                            value: _showLiveData
                                ? '${_telemetry.humidity} %'
                                : '--',
                            subtitle: 'Humidity (50-70)',
                            icon: Icons.water_drop_rounded,
                            progress: _showLiveData
                                ? (_telemetry.humidity - 30) / (90 - 30)
                                : 0.0,
                            isDanger: _showLiveData
                                ? (_telemetry.humidity < 50.0 ||
                                      _telemetry.humidity > 70.0)
                                : false,
                            isConnected: _isConnected,
                            isConnecting: _isConnecting,
                            isConfigured: _esp32Ip.isNotEmpty,
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
                            value: _showLiveData
                                ? '${_telemetry.airQuality}'
                                : '--',
                            subtitle: 'Air Quality (<500)',
                            icon: Icons.air_rounded,
                            progress: _showLiveData
                                ? _telemetry.airQuality / 800
                                : 0.0,
                            isDanger: _showLiveData
                                ? _telemetry.airQuality > 500
                                : false,
                            isConnected: _isConnected,
                            isConnecting: _isConnecting,
                            isConfigured: _esp32Ip.isNotEmpty,
                            progressColor: const Color(0xFF34A853),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TelemetryCard(
                            title: 'Noise',
                            value: _showLiveData
                                ? '${_telemetry.noise} dB'
                                : '--',
                            subtitle: 'Noise (<600)',
                            icon: Icons.graphic_eq_rounded,
                            progress: _showLiveData
                                ? _telemetry.noise / 100
                                : 0.0,
                            isDanger: _showLiveData
                                ? _telemetry.noise > 600
                                : false,
                            isConnected: _isConnected,
                            isConnecting: _isConnecting,
                            isConfigured: _esp32Ip.isNotEmpty,
                            progressColor: const Color(0xFF34A853),
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
          WeightCard(
            weight: _telemetry.weight,
            isConnected: _isConnected,
            showValue: _showLiveData,
          ),
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
          if (!_isConnected && _esp32Ip.isNotEmpty) ...[
            _buildWarningBanner(),
            const SizedBox(height: 16),
          ],
          LiveCameraCard(
            isTablet: false,
            isDanger: _telemetry.isDanger,
            statusMessage: _telemetry.statusMessage,
            cameraUrl: _cameraUrl,
            onCameraUrlChanged: (newUrl) {
              setState(() {
                _cameraUrl = newUrl;
              });
              _startCameraPolling();
              _notifyListeners();
              AppPreferences.setCameraUrl(newUrl);
            },
            isConnected: _isConnected,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TelemetryCard(
                  title: 'Room Temp',
                  value: _showLiveData ? '${_telemetry.airTemp} °C' : '--',
                  subtitle: 'Room Temp (25-37)',
                  icon: Icons.thermostat_rounded,
                  progress: _showLiveData
                      ? (_telemetry.airTemp - 20) / (40 - 20)
                      : 0.0,
                  isDanger: _showLiveData
                      ? (_telemetry.airTemp < 25.0 || _telemetry.airTemp > 37.0)
                      : false,
                  isConnected: _isConnected,
                  isConnecting: _isConnecting,
                  isConfigured: _esp32Ip.isNotEmpty,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TelemetryCard(
                  title: 'Humidity',
                  value: _showLiveData ? '${_telemetry.humidity} %' : '--',
                  subtitle: 'Humidity (50-70)',
                  icon: Icons.water_drop_rounded,
                  progress: _showLiveData
                      ? (_telemetry.humidity - 30) / (90 - 30)
                      : 0.0,
                  isDanger: _showLiveData
                      ? (_telemetry.humidity < 50.0 ||
                            _telemetry.humidity > 70.0)
                      : false,
                  isConnected: _isConnected,
                  isConnecting: _isConnecting,
                  isConfigured: _esp32Ip.isNotEmpty,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BabyTempCard(
            babyTemp: _telemetry.babyTemp,
            isDanger: _isConnected ? _telemetry.isDanger : false,
            isConnected: _isConnected,
            showValue: _showLiveData,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TelemetryCard(
                  title: 'Air Quality',
                  value: _showLiveData ? '${_telemetry.airQuality}' : '--',
                  subtitle: 'Air Quality (<500)',
                  icon: Icons.air_rounded,
                  progress: _showLiveData ? _telemetry.airQuality / 800 : 0.0,
                  isDanger: _showLiveData ? _telemetry.airQuality > 500 : false,
                  isConnected: _isConnected,
                  isConnecting: _isConnecting,
                  isConfigured: _esp32Ip.isNotEmpty,
                  progressColor: const Color(0xFF34A853),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TelemetryCard(
                  title: 'Noise',
                  value: _showLiveData ? '${_telemetry.noise} dB' : '--',
                  subtitle: 'Noise (<600)',
                  icon: Icons.graphic_eq_rounded,
                  progress: _showLiveData ? _telemetry.noise / 100 : 0.0,
                  isDanger: _showLiveData ? _telemetry.noise > 600 : false,
                  isConnected: _isConnected,
                  isConnecting: _isConnecting,
                  isConfigured: _esp32Ip.isNotEmpty,
                  progressColor: const Color(0xFF34A853),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          WeightCard(
            weight: _telemetry.weight,
            isConnected: _isConnected,
            showValue: _showLiveData,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color warningBg = isDark
        ? const Color(0xFF664D03).withOpacity(0.4)
        : const Color(0xFFFEF7E0);
    final Color warningBorder = isDark
        ? const Color(0xFF664D03)
        : const Color(0xFFFBBC05).withOpacity(0.3);
    final Color warningText = isDark
        ? const Color(0xFFFFDA6A)
        : const Color(0xFFB06000);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: warningBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warningBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "⚠️ Connection lost — showing last known data",
              style: AppStyles.bodyMedium.copyWith(
                color: warningText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
