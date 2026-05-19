// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:neocare/core/utils/app_colors.dart';
import 'package:neocare/core/utils/app_styles.dart';
import 'package:neocare/features/home/widgets/live_dot_blinker.dart';
import 'package:neocare/features/home/widgets/mjpeg_stream_player.dart';

class LiveCameraCard extends StatefulWidget {
  final bool isTablet;
  final bool isDanger;
  final String statusMessage;
  final String? cameraUrl;
  final ValueChanged<String>? onCameraUrlChanged;
  final bool isConnected;

  const LiveCameraCard({
    super.key,
    this.isTablet = false,
    required this.isDanger,
    required this.statusMessage,
    this.cameraUrl,
    this.onCameraUrlChanged,
    required this.isConnected,
  });

  @override
  State<LiveCameraCard> createState() => _LiveCameraCardState();
}

class _LiveCameraCardState extends State<LiveCameraCard> {
  bool _isZoomed = false;
  bool _isLightOn = false;
  int _reconnectKey = 0;

  @override
  Widget build(BuildContext context) {
    final bool hasLiveStream =
        widget.cameraUrl != null && widget.cameraUrl!.isNotEmpty;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color textSecondaryColor =
        isDark ? const Color(0xFFE5E7EB) : const Color(0xFF333A4D);
    final Color textPrimaryColor =
        isDark ? const Color(0xFFF9FAFB) : const Color(0xFF1E2229);

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
            // Live Generated Camera Feed Image or MJPEG Stream
            Positioned.fill(
              child: Transform.scale(
                scale: _isZoomed ? 1.4 : 1.0,
                alignment: Alignment.center,
                child: hasLiveStream
                    ? MjpegStreamPlayer(
                        key: ValueKey('${widget.cameraUrl}_$_reconnectKey'),
                        streamUrl: widget.cameraUrl!,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/incubator_feed.png',
                        fit: BoxFit.cover,
                        color: _isLightOn
                            ? Colors.transparent
                            : Colors.black.withOpacity(0.15),
                        colorBlendMode: BlendMode.darken,
                      ),
              ),
            ),

            // Zoom filter overlay simulation
            if (_isZoomed)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.5),
                      width: 3,
                    ),
                  ),
                ),
              ),

            // Top-Left live blinking beacon
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const LiveDotBlinker(),
                    const SizedBox(width: 6),
                    Text(
                      hasLiveStream ? 'LIVE STREAM' : 'LIVE SIM',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: !widget.isConnected
                      ? (isDark ? const Color(0xFF374151) : Colors.grey.shade600).withOpacity(0.85)
                      : (widget.isDanger
                          ? const Color(0xFFD93025).withOpacity(0.85)
                          : const Color(0xFF34A853).withOpacity(0.85)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      !widget.isConnected
                          ? Icons.wifi_off_rounded
                          : (widget.isDanger
                              ? Icons.warning_amber_rounded
                              : Icons.verified_user_rounded),
                      size: 12,
                      color: AppColors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      !widget.isConnected
                          ? 'NO SIGNAL'
                          : (widget.isDanger
                              ? widget.statusMessage.toUpperCase()
                              : 'STABLE'),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B).withOpacity(0.85)
                      : Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.white.withOpacity(0.1)
                        : Colors.transparent,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(isDark ? 0.3 : 0.05),
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
                        color: textSecondaryColor,
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
                            _isZoomed
                                ? Icons.zoom_out_map_rounded
                                : Icons.zoom_in_rounded,
                            size: 18,
                            color: _isZoomed
                                ? AppColors.primary
                                : textPrimaryColor,
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
                            _isLightOn
                                ? Icons.wb_sunny_rounded
                                : Icons.wb_sunny_outlined,
                            size: 18,
                            color: _isLightOn
                                ? Colors.amber[700]
                                : textPrimaryColor,
                          ),
                        ),
                        if (hasLiveStream) ...[
                          const SizedBox(width: 14),
                          // Reconnect/Refresh stream
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _reconnectKey++;
                              });
                            },
                            child: Icon(
                              Icons.refresh_rounded,
                              size: 18,
                              color: textPrimaryColor,
                            ),
                          ),
                        ],
                        const SizedBox(width: 14),
                        // Settings / IP configuration
                        GestureDetector(
                          onTap: _showCameraIpDialog,
                          child: Icon(
                            Icons.settings_rounded,
                            size: 18,
                            color: textPrimaryColor,
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

  void _showCameraIpDialog() {
    final TextEditingController controller = TextEditingController(
      text: widget.cameraUrl ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.videocam_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Camera Configuration',
                style: AppStyles.headingMedium.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the IP Address of your Live Camera Stream:',
                style: AppStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.white.withOpacity(0.7)
                      : AppColors.textLight,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.url,
                autofocus: true,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. 192.168.1.9:8080',
                  labelText: 'Camera IP',
                  labelStyle: TextStyle(
                    color: isDark
                        ? AppColors.white.withOpacity(0.6)
                        : AppColors.textSecondary,
                  ),
                  prefixIcon: const Icon(
                    Icons.settings_ethernet_rounded,
                    color: AppColors.primary,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Note: Enter only the local IP address (e.g. 192.168.1.9:8080 or 192.168.1.9) of the camera stream.',
                style: AppStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.white.withOpacity(0.4)
                      : AppColors.textSecondary.withOpacity(0.7),
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark
                      ? AppColors.white.withOpacity(0.6)
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (widget.cameraUrl != null && widget.cameraUrl!.isNotEmpty)
              TextButton(
                onPressed: () {
                  widget.onCameraUrlChanged?.call("");
                  Navigator.pop(context);
                },
                child: Text(
                  'Disconnect / Simulator',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: () {
                final url = controller.text.trim();
                widget.onCameraUrlChanged?.call(url);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Save & Link',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
