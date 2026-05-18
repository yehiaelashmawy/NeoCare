// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:neocare/core/utils/app_colors.dart';
import 'package:neocare/core/utils/app_styles.dart';
import 'package:neocare/features/home/widgets/live_dot_blinker.dart';

class LiveCameraCard extends StatefulWidget {
  final bool isTablet;
  final bool isDanger;
  final String statusMessage;

  const LiveCameraCard({
    super.key,
    this.isTablet = false,
    required this.isDanger,
    required this.statusMessage,
  });

  @override
  State<LiveCameraCard> createState() => _LiveCameraCardState();
}

class _LiveCameraCardState extends State<LiveCameraCard> {
  bool _isZoomed = false;
  bool _isLightOn = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Live Generated Camera Feed Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/incubator_feed.png',
                fit: BoxFit.cover,
                color: _isLightOn ? Colors.transparent : Colors.black.withOpacity(0.15),
                colorBlendMode: BlendMode.darken,
              ),
            ),

            // Zoom filter overlay simulation
            if (_isZoomed)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 3),
                  ),
                ),
              ),

            // Top-Left live blinking beacon
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const LiveDotBlinker(),
                    const SizedBox(width: 6),
                    Text(
                      'LIVE',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top-Right Stable/Critical Shield Indicator
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: widget.isDanger
                      ? const Color(0xFFD93025).withOpacity(0.85)
                      : const Color(0xFF34A853).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.isDanger ? Icons.warning_amber_rounded : Icons.verified_user_rounded,
                      size: 12,
                      color: AppColors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.isDanger ? widget.statusMessage.toUpperCase() : 'STABLE',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom-Left Glassmorphic Camera Controls
            Positioned(
              bottom: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CAMERA CONTROLS',
                      style: AppStyles.bodyMedium.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Zoom toggle
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isZoomed = !_isZoomed;
                            });
                          },
                          child: Icon(
                            _isZoomed ? Icons.zoom_out_map_rounded : Icons.zoom_in_rounded,
                            size: 18,
                            color: _isZoomed ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Light toggle
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isLightOn = !_isLightOn;
                            });
                          },
                          child: Icon(
                            _isLightOn ? Icons.wb_sunny_rounded : Icons.wb_sunny_outlined,
                            size: 18,
                            color: _isLightOn ? Colors.amber[700] : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
