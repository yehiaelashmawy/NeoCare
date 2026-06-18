import 'package:flutter/material.dart';
import 'package:neocare/core/utils/app_colors.dart';
import 'package:neocare/core/utils/app_styles.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppColors.isDark;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'NeoCare',
            style: AppStyles.headingMedium.copyWith(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. NeoCare Title Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E3A8A).withValues(alpha: 0.2)
                      : const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
                        : const Color(0xFFD6E4FF),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'NeoCare',
                      style: AppStyles.headingLarge.copyWith(
                        color: AppColors.primary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Smart Neonatal Monitoring System',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.textLight,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 2. Centered Stylized Premium N Logo
              Center(
                child: Image.asset(
                  Theme.of(context).brightness == Brightness.dark
                      ? 'assets/images/dark_about.png'
                      : 'assets/images/about.png',
                ),
              ),
              const SizedBox(height: 32),

              // 3. About The System Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.02),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.info_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About The System',
                            style: AppStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'NeoCare is a smart neonatal monitoring system designed to provide real-time monitoring for newborn incubators using IoT sensors, Bluetooth communication, and live camera streaming.',
                            style: AppStyles.bodyMedium.copyWith(
                              color: AppColors.textLight,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 4. Key Features Title
              Text(
                'Key Features',
                style: AppStyles.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),

              // 5. Feature List
              _buildFeatureItem(
                icon: Icons.trending_up_rounded,
                title: 'Real-Time Monitoring',
                description:
                    'Continuous tracking of vital signs and environmental metrics.',
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                icon: Icons.thermostat_rounded,
                title: 'Smart Temperature Tracking',
                description:
                    'Precision environmental control and automated alerts.',
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                icon: Icons.videocam_rounded,
                title: 'Live Camera Feed',
                description:
                    'Secure, low-latency visual monitoring for peace of mind.',
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                icon: Icons.notifications_active_rounded,
                title: 'Emergency Alerts',
                description:
                    'Instant notifications for critical parameter deviations.',
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                icon: Icons.wifi_tethering_rounded,
                title: 'ESP32 Wifi Connection',
                description:
                    'Robust local connectivity for uninterrupted data flow.',
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                icon: Icons.dashboard_rounded,
                title: 'Analytics Dashboard',
                description:
                    'Comprehensive historical data visualization and reporting.',
              ),

              const SizedBox(height: 48),

              // 6. Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'VERSION 1.0.0',
                      style: AppStyles.bodyMedium.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Smart Medical IoT System',
                      style: AppStyles.bodyMedium.copyWith(
                        fontSize: 12,
                        color: AppColors.textLight.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.brandIconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textLight,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
