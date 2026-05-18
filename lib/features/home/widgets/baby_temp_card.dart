// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:neocare/core/utils/app_colors.dart';
import 'package:neocare/core/utils/app_styles.dart';

class BabyTempCard extends StatelessWidget {
  final double babyTemp;
  final bool isDanger;

  const BabyTempCard({
    super.key,
    required this.babyTemp,
    required this.isDanger,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDanger ? const Color(0xFFD93025).withOpacity(0.25) : Colors.transparent,
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
                  color: isDanger ? const Color(0xFFFCE8E6) : const Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDanger ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                      size: 11,
                      color: isDanger ? const Color(0xFFD93025) : const Color(0xFF137333),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isDanger ? 'Critical' : 'Safe',
                      style: AppStyles.bodyMedium.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDanger ? const Color(0xFFD93025) : const Color(0xFF137333),
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
                '$babyTemp',
                style: AppStyles.headingLarge.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: isDanger ? const Color(0xFFD93025) : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '°C',
                style: AppStyles.subtitle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDanger ? const Color(0xFFD93025) : AppColors.textSecondary,
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
                    value: ((babyTemp - 35) / (38 - 35)).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE9ECEF),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDanger ? const Color(0xFFD93025) : const Color(0xFF34A853),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
