import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF0A66F5); // Vibrant blue from logo
  static const Color secondary = Color(0xFF2A7AFE);
  
  // Base constants (always literal white/black)
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Dynamic system theme detector
  static bool get isDark {
    try {
      final dispatcher = SchedulerBinding.instance.platformDispatcher;
      return dispatcher.platformBrightness == Brightness.dark;
    } catch (_) {
      return false;
    }
  }

  // Theme-aware dynamic background gradient steps
  static Color get bgGradientStart => isDark ? const Color(0xFF0B0F19) : const Color(0xFFF6FAFF);
  static Color get bgGradientMiddle => isDark ? const Color(0xFF111827) : const Color(0xFFECF4FF);
  static Color get bgGradientEnd => isDark ? const Color(0xFF1F2937) : const Color(0xFFDFECFF);

  // Theme-aware dynamic text/neutral colors
  static Color get textPrimary => isDark ? const Color(0xFFF9FAFB) : const Color(0xFF1E2229);
  static Color get textSecondary => isDark ? const Color(0xFFE5E7EB) : const Color(0xFF333A4D);
  static Color get textLight => isDark ? const Color(0xFF9CA3AF) : const Color(0xFF7D8797);

  // Semantically correct dynamic backgrounds & accents
  static Color get cardBackground => isDark ? const Color(0xFF1F2937) : Colors.white;
  static Color get scaffoldBackground => isDark ? const Color(0xFF0B0F19) : const Color(0xFFF6F8FC);
  static Color get iconContainerBackground => isDark ? const Color(0xFF374151) : const Color(0xFFF1F3F4);
  static Color get brandIconBackground => isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE8F0FE);
  static Color get chipBackground => isDark ? const Color(0xFF374151) : const Color(0xFFF3F7FD);
  static Color get buttonBackgroundLight => isDark ? const Color(0xFF374151) : const Color(0xFFF1F5FB);
}
