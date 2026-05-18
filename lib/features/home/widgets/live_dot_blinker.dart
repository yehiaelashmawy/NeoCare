// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class LiveDotBlinker extends StatefulWidget {
  const LiveDotBlinker({super.key});

  @override
  State<LiveDotBlinker> createState() => _LiveDotBlinkerState();
}

class _LiveDotBlinkerState extends State<LiveDotBlinker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD93025).withOpacity(_controller.value),
          ),
        );
      },
    );
  }
}
