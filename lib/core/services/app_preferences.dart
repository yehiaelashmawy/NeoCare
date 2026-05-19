import 'package:shared_preferences/shared_preferences.dart';

/// Centralised SharedPreferences wrapper.
/// All preference keys and access methods live here so no feature file
/// needs to know the raw key strings or import SharedPreferences directly.
class AppPreferences {
  AppPreferences._(); // Prevent instantiation

  // ─── Keys ────────────────────────────────────────────────────────────────
  static const String _keyOnboardingSeen = 'onboarding_seen';

  // ─── Onboarding ──────────────────────────────────────────────────────────

  /// Returns true if the user has already completed the onboarding flow.
  static Future<bool> isOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingSeen) ?? false;
  }

  /// Marks onboarding as completed so the splash screen skips it next time.
  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingSeen, true);
  }

  /// Clears the onboarding flag – useful during development / testing.
  static Future<void> clearOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOnboardingSeen);
  }

  // ─── Network Settings ─────────────────────────────────────────────────────
  static const String _keyEsp32Ip = 'esp32_ip';
  static const String _keyCameraUrl = 'camera_url';

  /// Returns the saved ESP32 Local IP address.
  static Future<String?> getEsp32Ip() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEsp32Ip);
  }

  /// Saves the ESP32 Local IP address.
  static Future<void> setEsp32Ip(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEsp32Ip, ip);
  }

  /// Returns the saved Camera URL.
  static Future<String?> getCameraUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCameraUrl);
  }

  /// Saves the Camera URL.
  static Future<void> setCameraUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCameraUrl, url);
  }

  // ─── App Preferences ──────────────────────────────────────────────────────
  static const String _keyAlarmVolume = 'alarmVolume';

  /// Returns the saved Alarm Volume.
  static Future<double> getAlarmVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyAlarmVolume) ?? 0.8;
  }
}
