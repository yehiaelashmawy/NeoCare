import 'package:flutter/material.dart';
import 'package:neocare/features/home/home_view.dart';
import 'package:neocare/core/utils/app_colors.dart';
import 'package:neocare/features/onboarding/models/onboarding_page_model.dart';
import 'package:neocare/features/onboarding/widgets/onboarding_action_buttons.dart';
import 'package:neocare/features/onboarding/widgets/onboarding_page_item.dart';

class OnboardingViewBody extends StatefulWidget {
  const OnboardingViewBody({super.key});

  @override
  State<OnboardingViewBody> createState() => _OnboardingViewBodyState();
}

class _OnboardingViewBodyState extends State<OnboardingViewBody> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding screens configuration matching pages 1, 2, and 3
  final List<OnboardingPageModel> _pages = [
    const OnboardingPageModel(
      imagePath: 'assets/images/onboarding_1.png',
      title: 'Smart Baby\nMonitoring',
      subtitle:
          'Monitor newborn babies safely with live sensors and camera tracking.',
      badges: [
        OnboardingBadgeModel(icon: Icons.show_chart, text: 'Live Monitoring'),
        OnboardingBadgeModel(icon: Icons.sensors, text: 'Smart Sensors'),
        OnboardingBadgeModel(icon: Icons.sync, text: 'Real-Time Updates'),
      ],
    ),
    const OnboardingPageModel(
      imagePath: 'assets/images/onboarding_2.png',
      title: 'Instant Emergency\nAlerts',
      subtitle:
          'Receive immediate warnings when abnormal readings are detected.',
      badges: [], // Rendered dynamically in page 2 layout
    ),
    const OnboardingPageModel(
      imagePath: 'assets/images/onboarding_3.png',
      title: 'Advanced Medical\nDashboard',
      subtitle:
          'Track temperature, humidity, air quality, body temperature, noise levels and more.',
      badges: [
        OnboardingBadgeModel(icon: Icons.videocam_rounded, text: 'Live Camera'),
        OnboardingBadgeModel(
          icon: Icons.analytics_rounded,
          text: 'Sensor Analytics',
        ),
        OnboardingBadgeModel(
          icon: Icons.verified_user_rounded,
          text: 'Smart Monitoring',
        ),
      ],
    ),
  ];

  void _onSkip() {
    _navigateToLogin();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeView()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.bgGradientStart,
            AppColors.bgGradientMiddle,
            AppColors.bgGradientEnd,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // PageView containing slide items
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPageItem(page: _pages[index], index: index);
                },
              ),
            ),

            // Pagination Indicator & Navigation Actions at bottom
            OnboardingActionButtons(
              currentPage: _currentPage,
              totalPages: _pages.length,
              onSkip: _onSkip,
              onNext: _onNext,
            ),
          ],
        ),
      ),
    );
  }
}
