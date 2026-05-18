import 'package:flutter/material.dart';

class OnboardingPageModel {
  final String imagePath;
  final String title;
  final String subtitle;
  final List<OnboardingBadgeModel> badges;

  const OnboardingPageModel({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.badges,
  });
}

class OnboardingBadgeModel {
  final IconData icon;
  final String text;

  const OnboardingBadgeModel({required this.icon, required this.text});
}
