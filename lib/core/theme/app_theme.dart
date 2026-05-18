import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: const Color(0xFFF6FAFF),

      // Default text theme using Outfit font family
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: AppStyles.brandTitle,
        bodyLarge: AppStyles.bodyLarge,
        bodyMedium: AppStyles.bodyMedium,
      ),

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: const Color(0xFFF6FAFF),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: const Color(0xFF0B0F19),

      // Default text theme using Outfit font family
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: AppStyles.brandTitle,
        bodyLarge: AppStyles.bodyLarge,
        bodyMedium: AppStyles.bodyMedium,
      ),

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: const Color(0xFF1F2937),
      ),
    );
  }
}
