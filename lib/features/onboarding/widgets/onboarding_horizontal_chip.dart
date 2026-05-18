import 'package:flutter/material.dart';
import 'package:neocare/core/utils/app_colors.dart';
import 'package:neocare/core/utils/app_styles.dart';
import 'package:neocare/features/onboarding/models/onboarding_page_model.dart';

class OnboardingHorizontalChip extends StatelessWidget {
  final OnboardingBadgeModel badge;

  const OnboardingHorizontalChip({
    super.key,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    // Adapt padding and font size for larger devices (Tablets)
    final double horizontalPadding = MediaQuery.of(context).size.width > 600 ? 20.0 : 16.0;
    final double verticalPadding = MediaQuery.of(context).size.width > 600 ? 12.0 : 10.0;
    final double fontSize = MediaQuery.of(context).size.width > 600 ? 14.0 : 13.0;
    final double iconSize = MediaQuery.of(context).size.width > 600 ? 18.0 : 16.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badge.icon,
            size: iconSize,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            badge.text,
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
