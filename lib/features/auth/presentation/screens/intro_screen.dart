import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/hanji_background.dart';
import '../../../../shared/widgets/mobile_shell.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.go('/');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileShell(
        child: HanjiBackground(
          baseColor: const Color(0xFFF7F1FB),
          opacity: 0.025,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFDFBFF),
                  Color(0xFFE9DDF2),
                  Color(0xFFF8F3FA),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 74,
                  right: -58,
                  child: _LavenderGlow(size: 190, opacity: 0.16),
                ),
                Positioned(
                  bottom: 84,
                  left: -72,
                  child: _LavenderGlow(size: 220, opacity: 0.12),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/icons/gugakify_logo_full.png',
                          width: 210,
                          errorBuilder: (_, error, stackTrace) =>
                              const Text('Gugakify'),
                        ),
                        const SizedBox(height: 42),
                        const Text(
                          'K-POP을\n국악과 전통 MV로\n변환하다',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            height: 1.42,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LavenderGlow extends StatelessWidget {
  const _LavenderGlow({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primaryPurple.withValues(alpha: opacity),
            AppColors.primaryPurple.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
