// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:neocare/core/utils/app_colors.dart';
import 'package:neocare/core/utils/app_styles.dart';

class BabyTempCard extends StatelessWidget {
  final double babyTemp;
  final bool isDanger;
  final bool isConnected;
  final bool showValue;

  const BabyTempCard({
    super.key,
    required this.babyTemp,
    required this.isDanger,
    required this.isConnected,
    required this.showValue,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isConnected && isDanger
              ? const Color(0xFFD93025).withOpacity(0.25)
              : Colors.transparent,
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
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE).withOpacity(isDark ? 0.08 : 0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Title Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.brandIconBackground,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.face_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Baby Temp',
                          style: AppStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isConnected
                            ? (isDanger ? const Color(0xFFFCE8E6) : const Color(0xFFE6F4EA))
                            : (AppColors.isDark ? const Color(0xFF374151) : const Color(0xFFF1F3F4)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isConnected
                                ? (isDanger ? Icons.warning_amber_rounded : Icons.check_circle_rounded)
                                : Icons.remove_rounded,
                            size: 11,
                            color: isConnected
                                ? (isDanger ? const Color(0xFFD93025) : const Color(0xFF137333))
                                : AppColors.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isConnected
                                ? (isDanger ? 'Critical' : 'Safe')
                                : 'No Signal',
                            style: AppStyles.bodyMedium.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isConnected
                                  ? (isDanger ? const Color(0xFFD93025) : const Color(0xFF137333))
                                  : AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Massive numerical readout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      showValue ? '$babyTemp' : '--',
                      style: AppStyles.headingLarge.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: isConnected
                            ? (isDanger ? const Color(0xFFD93025) : AppColors.textPrimary)
                            : (showValue ? AppColors.textPrimary : AppColors.textLight),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '°C',
                      style: AppStyles.subtitle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isConnected
                            ? (isDanger ? const Color(0xFFD93025) : AppColors.textSecondary)
                            : (showValue ? AppColors.textSecondary : AppColors.textLight),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Label String & Safe range progress bar row
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Target Range: 36.0 - 37.0',
                        style: AppStyles.bodyMedium.copyWith(
                          fontSize: 12,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: showValue ? ((babyTemp - 35) / (38 - 35)).clamp(0.0, 1.0) : 0.0,
                          minHeight: 6,
                          backgroundColor: showValue ? const Color(0xFFE9ECEF) : (AppColors.isDark ? const Color(0xFF374151) : Colors.grey.shade300),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isConnected
                                ? (isDanger ? const Color(0xFFD93025) : const Color(0xFF34A853))
                                : (showValue ? const Color(0xFF34A853) : Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
