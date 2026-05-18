// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:neocare/core/utils/app_colors.dart';
import 'package:neocare/core/utils/app_styles.dart';

class WeightCard extends StatelessWidget {
  final double weight;

  const WeightCard({
    super.key,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Weight scale circular icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.iconContainerBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.scale_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),

          // Description label stack
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weight',
                  style: AppStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last updated: 2h ago',
                  style: AppStyles.bodyMedium.copyWith(
                    fontSize: 11,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Readout value
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$weight',
                style: AppStyles.headingMedium.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'kg',
                style: AppStyles.subtitle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
