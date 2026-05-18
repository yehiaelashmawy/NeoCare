// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:neocare/core/utils/app_colors.dart';
import 'package:neocare/core/utils/app_styles.dart';

class OnboardingVerticalCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color iconColor;
  final Color circleColor;

  const OnboardingVerticalCard({
    super.key,
    required this.text,
    required this.icon,
    required this.iconColor,
    required this.circleColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    
    // Adaptive sizing values for tablets
    final double cardPaddingH = isTablet ? 24.0 : 16.0;
    final double cardPaddingV = isTablet ? 16.0 : 12.0;
    final double iconContainerSize = isTablet ? 56.0 : 48.0;
    final double iconSize = isTablet ? 28.0 : 24.0;
    final double fontSize = isTablet ? 16.0 : 15.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: cardPaddingH, vertical: cardPaddingV),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Icon Container
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: iconSize,
            ),
          ),
          const SizedBox(width: 16),
          // Description Text
          Expanded(
            child: Text(
              text,
              style: AppStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
