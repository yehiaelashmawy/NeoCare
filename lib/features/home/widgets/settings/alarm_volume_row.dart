// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:neocare/core/utils/app_colors.dart';
import 'package:neocare/core/utils/app_styles.dart';

class AlarmVolumeRow extends StatelessWidget {
  final double alarmVolume;
  final bool isDark;
  final ValueChanged<double> onChanged;

  const AlarmVolumeRow({
    super.key,
    required this.alarmVolume,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.volume_up_rounded,
                  color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Alarm Volume',
                  style: AppStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '${(alarmVolume * 100).toInt()}%',
                style: AppStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 42.0),
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 6,
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0),
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withOpacity(0.12),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              ),
              child: Slider(
                value: alarmVolume,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
