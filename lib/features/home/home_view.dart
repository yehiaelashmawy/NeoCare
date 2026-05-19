// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:neocare/core/utils/app_colors.dart';
import 'package:neocare/core/utils/app_styles.dart';
import 'package:neocare/features/home/widgets/home_view_body.dart';
import 'package:neocare/features/home/widgets/settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  final GlobalKey<HomeViewBodyState> _dashboardKey =
      GlobalKey<HomeViewBodyState>();

  // Live connection notifiers — owned here so both children can share them
  final ValueNotifier<bool> _connectionNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _connectingNotifier = ValueNotifier(false);
  final ValueNotifier<String> _espIpNotifier = ValueNotifier("");
  final ValueNotifier<String> _cameraUrlNotifier = ValueNotifier("");
  final ValueNotifier<bool> _cameraConnectedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _cameraCheckingNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeViewBody(
            key: _dashboardKey,
            connectionNotifier: _connectionNotifier,
            connectingNotifier: _connectingNotifier,
            espIpNotifier: _espIpNotifier,
            cameraUrlNotifier: _cameraUrlNotifier,
            cameraConnectedNotifier: _cameraConnectedNotifier,
            cameraCheckingNotifier: _cameraCheckingNotifier,
          ),
          SettingsView(
            onSettingsSaved: () {
              _dashboardKey.currentState?.reloadSettings();
            },
            connectionNotifier: _connectionNotifier,
            connectingNotifier: _connectingNotifier,
            espIpNotifier: _espIpNotifier,
            cameraUrlNotifier: _cameraUrlNotifier,
            cameraConnectedNotifier: _cameraConnectedNotifier,
            cameraCheckingNotifier: _cameraCheckingNotifier,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.only(
        top: 8,
        bottom: math.max(0.0, MediaQuery.of(context).padding.bottom - 8),
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.analytics_rounded, 'Dashboard'),
          _buildNavItem(1, Icons.settings_rounded, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _currentIndex == index;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : (isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF4A5568)),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppStyles.bodyMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF4A5568)),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
