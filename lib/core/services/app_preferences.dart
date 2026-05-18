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
}
