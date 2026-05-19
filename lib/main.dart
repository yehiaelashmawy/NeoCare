import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neocare/core/theme/app_theme.dart';
import 'package:neocare/features/splash/splash_view.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  // Required by shared_preferences 2.3.x (Pigeon-based Android channels)
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode');
  if (isDarkMode != null) {
    themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  runApp(const NeoCareApp());
}

class NeoCareApp extends StatelessWidget {
  const NeoCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const SplashView(),
        );
      },
    );
  }
}
