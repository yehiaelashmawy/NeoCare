import 'package:flutter/material.dart';
import 'package:neocare/core/theme/app_theme.dart';
import 'package:neocare/features/splash/splash_view.dart';

void main() async {
  // Required by shared_preferences 2.3.x (Pigeon-based Android channels)
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NeoCareApp());
}

class NeoCareApp extends StatelessWidget {
  const NeoCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashView(),
    );
  }
}
