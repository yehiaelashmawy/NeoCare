// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:neocare/core/utils/app_colors.dart';
import 'package:neocare/core/utils/app_styles.dart';

class MjpegStreamPlayer extends StatefulWidget {
  final String streamUrl;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget? loadingBuilder;

  const MjpegStreamPlayer({
    super.key,
    required this.streamUrl,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  State<MjpegStreamPlayer> createState() => _MjpegStreamPlayerState();
}

class _MjpegStreamPlayerState extends State<MjpegStreamPlayer> {
  http.Client? _httpClient;
  StreamSubscription? _subscription;
  bool _isLoading = true;
  Object? _error;
  String _resolvedUrl = "";
  ui.Image? _currentImage;

  final List<int> _buffer = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _resolveAndStartStream();
  }

  @override
  void didUpdateWidget(covariant MjpegStreamPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streamUrl != widget.streamUrl) {
      _stopStream();
      _resolveAndStartStream();
    }
  }

  @override
  void dispose() {
    _stopStream();
    super.dispose();
  }

  void _stopStream() {
    _subscription?.cancel();
    _subscription = null;
    _httpClient?.close();
    _httpClient = null;
    _currentImage?.dispose();
    _currentImage = null;
    _buffer.clear();
    _isProcessing = false;
  }

  void _resolveAndStartStream() {
    String url = widget.streamUrl.trim();
    
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }

    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    final parsedUri = Uri.tryParse(url);
    if (parsedUri != null) {
      if (parsedUri.path.isEmpty || parsedUri.path == '/') {
        if (parsedUri.port == 8080) {
          url = '$url/video';
        } else if (parsedUri.port == 81) {
          url = '$url/stream';
        }
      }
    }

    setState(() {
      _resolvedUrl = url;
    });

    _startStream(url);
  }

  Future<void> _startStream(String url) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    _httpClient = http.Client();

    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await _httpClient!.send(request).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        throw Exception('Server responded with HTTP Status ${response.statusCode}');
      }

      _subscription = response.stream.listen(
        (chunk) {
          _buffer.addAll(chunk);
          _processBuffer();
        },
        onError: (err) {
          if (mounted) {
            setState(() {
              _error = err;
              _isLoading = false;
            });
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _processBuffer() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      while (mounted) {
        if (_buffer.length < 4) break;

        // Find SOI (Start of Image) marker: 0xFF, 0xD8
        int startIndex = -1;
        for (int i = 0; i < _buffer.length - 1; i++) {
          if (_buffer[i] == 0xFF && _buffer[i + 1] == 0xD8) {
            startIndex = i;
            break;
          }
        }

        if (startIndex == -1) {
          // No start marker found. Clear buffer to prevent runway growth.
          _buffer.clear();
          break;
        }

        // Find EOI (End of Image) marker: 0xFF, 0xD9
        int endIndex = -1;
        for (int i = startIndex + 2; i < _buffer.length - 1; i++) {
          if (_buffer[i] == 0xFF && _buffer[i + 1] == 0xD9) {
            endIndex = i + 2; // Include the marker itself
            break;
          }
        }

        if (endIndex != -1) {
          // Extract the frame bytes
          final frameBytes = Uint8List.fromList(_buffer.sublist(startIndex, endIndex));
          // Remove processed bytes from buffer
          _buffer.removeRange(0, endIndex);

          try {
            // Decode the JPEG frame safely before passing to UI
            final codec = await ui.instantiateImageCodec(frameBytes);
            final frameInfo = await codec.getNextFrame();
            final newImage = frameInfo.image;

            if (mounted) {
              setState(() {
                _currentImage?.dispose();
                _currentImage = newImage;
                _isLoading = false;
              });
            } else {
              newImage.dispose();
            }
          } catch (decodeError) {
            // Silently ignore decode errors for corrupted or partial frames
            debugPrint("Discarding corrupted frame: $decodeError");
          }
        } else {
          // SOI found but EOI not complete yet.
          // Keep only from startIndex onwards and wait for next chunk.
          if (startIndex > 0) {
            _buffer.removeRange(0, startIndex);
          }
          break;
        }
      }
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder != null
          ? widget.errorBuilder!(context, _error!, null)
          : Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.black.withOpacity(0.4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.videocam_off_rounded,
                      color: Color(0xFFD93025),
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Camera Live Stream Offline',
                      style: AppStyles.headingMedium.copyWith(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Could not connect to:\n$_resolvedUrl',
                      textAlign: TextAlign.center,
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.white.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Error: ${_error.toString().split(':').last.trim()}',
                      textAlign: TextAlign.center,
                      style: AppStyles.bodyMedium.copyWith(
                        color: const Color(0xFFEA868F),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
    }

    if (_isLoading || _currentImage == null) {
      return widget.loadingBuilder ??
          Center(
            child: Container(
              color: AppColors.black.withOpacity(0.4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'CONNECTING TO STREAM',
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _resolvedUrl,
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.white.withOpacity(0.4),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          );
    }

    return RawImage(
      image: _currentImage,
      fit: widget.fit,
    );
  }
}

