import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

class LaunchScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const LaunchScreen({super.key, required this.onFinish});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  bool _isVisible = false;
  double _scale = 0.7;
  double _opacity = 0.0;
  double _rotation = -15 * (3.14159 / 180); // To radians
  double _glowOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    // Initial entry animations
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    
    setState(() {
      _isVisible = true;
      _scale = 1.0;
      _opacity = 1.0;
      _rotation = 0.0;
    });

    // Ambient glow delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _glowOpacity = 1.0);
    });

    // Auto-dismiss after 2 seconds
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    setState(() {
      _opacity = 0.0;
      _scale = 1.06;
    });

    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D1B2A),
                  Color(0xFF1A3A4A),
                  Color(0xFF0A2030),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Ambient Glow Blobs
          Stack(
            children: [
              AnimatedOpacity(
                opacity: _glowOpacity,
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeInOut,
                child: Stack(
                  children: [
                    Positioned(
                      left: -80,
                      top: -100,
                      child: _GlowBlob(
                        color: const Color(0xFF09637E).withOpacity(0.18),
                        size: 340,
                        blur: 100,
                      ),
                    ),
                    Positioned(
                      right: -60,
                      bottom: 100,
                      child: _GlowBlob(
                        color: const Color(0xFF2EC4B6).withOpacity(0.14),
                        size: 280,
                        blur: 80,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Container
                AnimatedScale(
                  scale: _scale,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  child: AnimatedOpacity(
                    opacity: _opacity,
                    duration: const Duration(milliseconds: 800),
                    child: AnimatedRotation(
                      turns: _rotation / (2 * 3.14159),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow ring
                          Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF09637E).withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ).animate().scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.15, 1.15),
                            duration: 1200.ms,
                            curve: Curves.easeInOutSine,
                          ).fadeIn(duration: 800.ms),

                          // App icon
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF09637E).withOpacity(0.55),
                                  blurRadius: 36,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.asset(
                                'assets/images/app_logo.png',
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // App Name & Subtitle
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                    children: [
                      const Text(
                        'Expense Diary',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your money, beautifully organised',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.55),
                        ),
                      ),
                    ],
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

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  final double blur;

  const _GlowBlob({
    required this.color,
    required this.size,
    required this.blur,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: blur,
            spreadRadius: blur / 2,
          ),
        ],
      ),
    );
  }
}
