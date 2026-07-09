import 'dart:math';

import 'package:flutter/material.dart';

class HanjiBackground extends StatelessWidget {
  const HanjiBackground({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFFFFCF7),
    this.opacity = 0.035,
  });

  final Widget child;
  final Color baseColor;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: baseColor,
      child: CustomPaint(
        painter: _HanjiPainter(opacity: opacity),
        child: child,
      ),
    );
  }
}

class _HanjiPainter extends CustomPainter {
  const _HanjiPainter({required this.opacity});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final fiberPaint = Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..strokeWidth = 0.6;
    final dotPaint = Paint()..color = Colors.black.withValues(alpha: opacity * 0.9);
    final random = Random(11);
    for (var i = 0; i < 52; i++) {
      final y = random.nextDouble() * size.height;
      final x = random.nextDouble() * size.width;
      final length = 18 + random.nextDouble() * 58;
      canvas.drawLine(
        Offset(x, y),
        Offset((x + length).clamp(0, size.width), y + random.nextDouble() * 8 - 4),
        fiberPaint,
      );
    }
    for (var i = 0; i < 95; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        0.5 + random.nextDouble() * 1.1,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HanjiPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}
