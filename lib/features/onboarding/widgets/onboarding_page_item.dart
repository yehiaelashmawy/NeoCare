// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:neocare/core/utils/app_colors.dart';
import 'package:neocare/core/utils/app_styles.dart';
import 'package:neocare/features/onboarding/models/onboarding_page_model.dart';
import 'package:neocare/features/onboarding/widgets/onboarding_horizontal_chip.dart';
import 'package:neocare/features/onboarding/widgets/onboarding_vertical_card.dart';

class OnboardingPageItem extends StatelessWidget {
  final OnboardingPageModel page;
  final int index;

  const OnboardingPageItem({
    super.key,
    required this.page,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    if (isTablet) {
      // Premium Two-Column side-by-side split layout on iPads & Tablets
      return Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Column: Incubation / Medical Screen Image Card
                Expanded(
                  flex: 11,
                  child: _buildImage(context, isTablet),
                ),
                const SizedBox(width: 56),
                // Right Column: Title, Description, and Feature Chips
                Expanded(
                  flex: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTitle(isTablet),
                      const SizedBox(height: 16),
                      _buildSubtitle(isTablet),
                      const SizedBox(height: 32),
                      _buildFeatureLayout(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Classic premium vertical layout on Phones
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildImage(context, isTablet),
          const SizedBox(height: 32),
          _buildTitle(isTablet),
          const SizedBox(height: 12),
          _buildSubtitle(isTablet),
          const SizedBox(height: 28),
          _buildFeatureLayout(context),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context, bool isTablet) {
    final double height = isTablet
        ? MediaQuery.of(context).size.height * 0.46
        : MediaQuery.of(context).size.height * 0.38;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Image.asset(
          page.imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTitle(bool isTablet) {
    return Text(
      page.title,
      textAlign: isTablet ? TextAlign.left : TextAlign.center,
      style: AppStyles.brandTitle.copyWith(
        fontSize: isTablet ? 38 : 32,
        height: 1.25,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSubtitle(bool isTablet) {
    return Padding(
      padding: isTablet ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        page.subtitle,
        textAlign: isTablet ? TextAlign.left : TextAlign.center,
        style: AppStyles.subtitle.copyWith(
          fontSize: isTablet ? 17 : 15,
          height: 1.45,
          color: AppColors.textLight,
        ),
      ),
    );
  }

  Widget _buildFeatureLayout(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;

    if (index == 0 || index == 2) {
      // PAGE 1 & 3: Centered, rounded, horizontal wrapped badges
      return Wrap(
        alignment: isTablet ? WrapAlignment.start : WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          OnboardingHorizontalChip(badge: page.badges[0]),
          OnboardingHorizontalChip(badge: page.badges[1]),
          OnboardingHorizontalChip(badge: page.badges[2]),
        ],
      );
    } else {
      // PAGE 2: Large vertical list-item cards matching cardiac monitor mockup
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 0.0 : 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const OnboardingVerticalCard(
              text: 'Emergency Alerts',
              icon: Icons.warning_rounded,
              iconColor: Color(0xFFD93025), // Google Warning Red
              circleColor: Color(0xFFFCE8E6), // Light red circle
            ),
            const SizedBox(height: 12),
            const OnboardingVerticalCard(
              text: 'Real-Time Detection',
              icon: Icons.trending_up,
              iconColor: AppColors.white,
              circleColor: AppColors.primary, // Primary solid blue circle
            ),
          ],
        ),
      );
    }
  }
}
