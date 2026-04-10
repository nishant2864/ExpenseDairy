import 'package:flutter/material.dart';
import 'dart:math';

class AppBackdrop extends StatefulWidget {
  const AppBackdrop({super.key});

  @override
  State<AppBackdrop> createState() => _AppBackdropState();
}

class _AppBackdropState extends State<AppBackdrop> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _glowOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                  ? [const Color(0xFF0D1B2A), const Color(0xFF1A3A4A), const Color(0xFF0A2030)]
                  : [const Color(0xFFEBF4F6), const Color(0xFF7AB2B2)],
                begin: isDark ? Alignment.topLeft : Alignment.bottomCenter,
                end: isDark ? Alignment.bottomRight : Alignment.topCenter,
              ),
            ),
          ),
        ),
        
        // Ambient glow blobs (matched to SwiftUI offsets)
        if (isDark) ...[
          AnimatedBuilder(
            animation: _glowOpacity,
            builder: (context, child) => Positioned(
              left: -80,
              top: -200,
              child: Opacity(
                opacity: _glowOpacity.value * 0.18,
                child: Container(
                  width: 340,
                  height: 340,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4F8EF7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Color(0xFF4F8EF7), blurRadius: 100, spreadRadius: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _glowOpacity,
            builder: (context, child) => Positioned(
              right: -50,
              bottom: 100,
              child: Opacity(
                opacity: _glowOpacity.value * 0.14,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2EC4B6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Color(0xFF2EC4B6), blurRadius: 80, spreadRadius: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ] else ...[
          Positioned(
            left: -120,
            top: -250,
            child: Opacity(
              opacity: 0.08,
              child: Container(
                width: 240,
                height: 240,
                decoration: const BoxDecoration(
                  color: Color(0xFF4A6488),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0xFF4A6488), blurRadius: 90, spreadRadius: 10),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -100,
            bottom: 150,
            child: Opacity(
              opacity: 0.06,
              child: Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  color: Color(0xFF7385A3),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0xFF7385A3), blurRadius: 100, spreadRadius: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
