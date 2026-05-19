// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:neocare/core/utils/app_colors.dart';
import 'package:neocare/core/utils/app_styles.dart';

class TelemetryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final double progress;
  final bool isDanger;
  final bool isConnected;
  final bool isConnecting;
  final bool isConfigured;
  final Color? progressColor;

  const TelemetryCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.progress,
    required this.isDanger,
    required this.isConnected,
    required this.isConnecting,
    required this.isConfigured,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isConnected && isDanger) ? const Color(0xFFD93025).withOpacity(0.25) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Safe/Danger pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isConnected
                      ? (isDanger ? const Color(0xFFFCE8E6) : const Color(0xFFE6F4EA))
                      : ((isConnecting || isConfigured) ? const Color(0xFFFEF7E0) : (AppColors.isDark ? const Color(0xFF374151) : const Color(0xFFF1F3F4))),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isConnected
                          ? (isDanger ? Icons.warning_amber_rounded : Icons.check_circle_rounded)
                          : ((isConnecting || isConfigured) ? Icons.sync_rounded : Icons.remove_rounded),
                      size: 10,
                      color: isConnected
                          ? (isDanger ? const Color(0xFFD93025) : const Color(0xFF137333))
                          : ((isConnecting || isConfigured) ? const Color(0xFFB06000) : AppColors.textLight),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isConnected
                          ? (isDanger ? 'Alert' : 'Safe')
                          : (isConnecting ? 'Connecting' : (isConfigured ? 'Reconnecting' : 'No Signal')),
                      style: AppStyles.bodyMedium.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isConnected
                            ? (isDanger ? const Color(0xFFD93025) : const Color(0xFF137333))
                            : ((isConnecting || isConfigured) ? const Color(0xFFB06000) : AppColors.textLight),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Numerical Value
          Text(
            value,
            style: AppStyles.headingMedium.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: (isConnected && isDanger) ? const Color(0xFFD93025) : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),

          // Label string
          Text(
            subtitle,
            style: AppStyles.bodyMedium.copyWith(
              fontSize: 11,
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),

          // Visual Progress range bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: const Color(0xFFE9ECEF),
              valueColor: AlwaysStoppedAnimation<Color>(
                (isConnected && isDanger)
                    ? const Color(0xFFD93025)
                    : (progressColor ?? AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
