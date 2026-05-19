// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:neocare/main.dart';
import 'package:neocare/core/services/app_preferences.dart';
import 'package:neocare/core/utils/app_colors.dart';
import 'package:neocare/core/utils/app_styles.dart';

import 'package:neocare/features/home/widgets/settings/settings_components.dart';
import 'package:neocare/features/home/widgets/settings/settings_top_bar.dart';
import 'package:neocare/features/home/widgets/settings/alarm_volume_row.dart';

class SettingsView extends StatefulWidget {
  final VoidCallback onSettingsSaved;

  const SettingsView({super.key, required this.onSettingsSaved});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _isDarkMode = false;
  double _alarmVolume = 0.8;
  String _esp32Ip = 'Not set';
  String _cameraIp = 'Not set';

  bool _isCheckingEsp = false;
  bool _isEspConnected = false;
  bool _isCheckingCamera = false;
  bool _isCameraConnected = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final esp32Ip = await AppPreferences.getEsp32Ip() ?? 'Not set';
    final cameraIp = await AppPreferences.getCameraUrl() ?? 'Not set';

    setState(() {
      _alarmVolume = prefs.getDouble('alarmVolume') ?? 0.8;
      _esp32Ip = esp32Ip.isEmpty ? 'Not set' : esp32Ip;
      _cameraIp = cameraIp.isEmpty ? 'Not set' : cameraIp;
      if (themeNotifier.value == ThemeMode.system) {
        _isDarkMode =
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
      } else {
        _isDarkMode = themeNotifier.value == ThemeMode.dark;
      }
    });
    _checkConnections();
  }

  Future<void> _checkConnections() async {
    _checkEspConnection();
    _checkCameraConnection();
  }

  Future<void> _checkEspConnection() async {
    if (_esp32Ip == 'Not set' || _esp32Ip.isEmpty) {
      if (mounted) {
        setState(() {
          _isEspConnected = false;
          _isCheckingEsp = false;
        });
      }
      return;
    }
    if (mounted) {
      setState(() => _isCheckingEsp = true);
    }
    try {
      final response = await http
          .get(Uri.parse('http://$_esp32Ip/data'))
          .timeout(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isEspConnected = response.statusCode == 200;
          _isCheckingEsp = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isEspConnected = false;
          _isCheckingEsp = false;
        });
      }
    }
  }

  Future<void> _checkCameraConnection() async {
    if (_cameraIp == 'Not set' || _cameraIp.isEmpty) {
      if (mounted) {
        setState(() {
          _isCameraConnected = false;
          _isCheckingCamera = false;
        });
      }
      return;
    }
    if (mounted) {
      setState(() => _isCheckingCamera = true);
    }
    try {
      String url = _cameraIp;
      if (!url.startsWith('http')) {
        url = 'http://$url';
      }
      // ignore: unused_local_variable
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isCameraConnected = true;
          _isCheckingCamera = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCameraConnected = false;
          _isCheckingCamera = false;
        });
      }
    }
  }

  Future<void> _showEditIpDialog(
    String title,
    String key,
    String currentIp,
  ) async {
    final controller = TextEditingController(
      text: currentIp == 'Not set' ? '' : currentIp,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark
              ? const Color(0xFF1F2937)
              : AppColors.cardBackground,
          title: Text(
            'Edit $title IP',
            style: AppStyles.headingMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          content: TextField(
            controller: controller,
            style: AppStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. 192.168.1.100',
              hintStyle: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            keyboardType: TextInputType.url,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () async {
                final newIp = controller.text.trim();

                if (key == 'esp32Ip') {
                  await AppPreferences.setEsp32Ip(newIp);
                  setState(() => _esp32Ip = newIp.isEmpty ? 'Not set' : newIp);
                  _checkEspConnection();
                } else if (key == 'cameraIp') {
                  await AppPreferences.setCameraUrl(newIp);
                  setState(() => _cameraIp = newIp.isEmpty ? 'Not set' : newIp);
                  _checkCameraConnection();
                }

                if (context.mounted) Navigator.pop(context);
                widget.onSettingsSaved();
              },
              child: Text(
                'Save',
                style: AppStyles.bodyMedium.copyWith(color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SettingsTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: AppStyles.headingLarge.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configure device connectivity, alerts, and\npreferences.',
                      style: AppStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // CONNECTIVITY SECTION
                    const SettingsSectionTitle(title: 'CONNECTIVITY'),
                    const SizedBox(height: 12),
                    SettingsCardWrapper(
                      child: Column(
                        children: [
                          SettingsRow(
                            icon: Icons.wifi_tethering_rounded,
                            iconBg: isDark
                                ? const Color(0xFF1E3A8A)
                                : const Color(0xFFE8F0FE),
                            iconColor: AppColors.primary, // Yellow
                            title: 'ESP32',
                            subtitle: _esp32Ip,
                            onTap: () =>
                                _showEditIpDialog('ESP32', 'esp32Ip', _esp32Ip),
                            trailing: _isCheckingEsp
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : SettingsDotIndicator(
                                    text: _esp32Ip == 'Not set'
                                        ? 'Not Configured'
                                        : (_isEspConnected
                                              ? 'Connected'
                                              : 'Disconnected'),
                                    color: _esp32Ip == 'Not set'
                                        ? const Color(0xFF6B7280)
                                        : (_isEspConnected
                                              ? const Color(0xFF137333)
                                              : const Color(0xFFD93025)),
                                    isDark: isDark,
                                  ),
                          ),
                          const SettingsDivider(),
                          SettingsRow(
                            icon: Icons.wifi_rounded,
                            iconBg: isDark
                                ? const Color(0xFF1E3A8A)
                                : const Color(0xFFE8F0FE),
                            iconColor: AppColors.primary,
                            title: 'WiFi (Camera)',
                            subtitle: _cameraIp,
                            onTap: () => _showEditIpDialog(
                              'Camera',
                              'cameraIp',
                              _cameraIp,
                            ),
                            trailing: _isCheckingCamera
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : SettingsDotIndicator(
                                    text: _cameraIp == 'Not set'
                                        ? 'Not Configured'
                                        : (_isCameraConnected
                                              ? 'Connected'
                                              : 'Disconnected'),
                                    color: _cameraIp == 'Not set'
                                        ? const Color(0xFF6B7280)
                                        : (_isCameraConnected
                                              ? const Color(0xFF137333)
                                              : const Color(0xFFD93025)),
                                    isDark: isDark,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ALERTS & PREFERENCES SECTION
                    const SettingsSectionTitle(title: 'ALERTS & PREFERENCES'),
                    const SizedBox(height: 12),
                    SettingsCardWrapper(
                      child: Column(
                        children: [
                          AlarmVolumeRow(
                            alarmVolume: _alarmVolume,
                            isDark: isDark,
                            onChanged: (val) async {
                              setState(() {
                                _alarmVolume = val;
                              });
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setDouble('alarmVolume', val);
                              widget.onSettingsSaved();
                            },
                          ),
                          const SettingsDivider(),
                          SettingsRow(
                            icon: Icons.dark_mode_outlined,
                            iconBg: isDark
                                ? const Color(0xFF374151)
                                : const Color(0xFFF1F5F9),
                            iconColor: isDark
                                ? const Color(0xFFD1D5DB)
                                : const Color(0xFF475569),
                            title: 'Dark Mode',
                            trailing: Switch(
                              value: _isDarkMode,
                              onChanged: (val) async {
                                setState(() {
                                  _isDarkMode = val;
                                });
                                themeNotifier.value = val
                                    ? ThemeMode.dark
                                    : ThemeMode.light;
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool('isDarkMode', val);
                                widget.onSettingsSaved();
                              },
                              activeColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SYSTEM SECTION
                    const SettingsSectionTitle(title: 'SYSTEM'),
                    const SizedBox(height: 12),
                    SettingsCardWrapper(
                      child: Column(
                        children: [
                          SettingsRow(
                            icon: Icons.sensors_rounded,
                            iconBg: isDark
                                ? const Color(0xFF0F5132).withOpacity(0.4)
                                : const Color(0xFFE6F4EA),
                            iconColor: const Color(0xFF137333),
                            title: 'Sensor Status',
                            trailing: SettingsPillIndicator(
                              text: 'All Active',
                              color: const Color(0xFF137333),
                              isDark: isDark,
                            ),
                          ),
                          const SettingsDivider(),
                          SettingsRow(
                            icon: Icons.info_outline_rounded,
                            iconBg: isDark
                                ? const Color(0xFF374151)
                                : const Color(0xFFF1F5F9),
                            iconColor: isDark
                                ? const Color(0xFFD1D5DB)
                                : const Color(0xFF475569),
                            title: 'About Project',
                            subtitle: 'Version 2.4.1 • Team Members',
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Footer
                    Center(
                      child: Text(
                        'Neonatal Monitoring System • Property of NICU Dept.',
                        style: AppStyles.bodyMedium.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFF6B7280)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
