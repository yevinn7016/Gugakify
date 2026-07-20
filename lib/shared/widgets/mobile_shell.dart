import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class MobileShell extends StatelessWidget {
  const MobileShell({super.key, required this.child, this.useSafeArea = true});

  final Widget child;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final appWidth = kIsWeb ? math.min(screenWidth, 392.0) : screenWidth;

    return ColoredBox(
      color: AppColors.webOuterBackground,
      child: Center(
        child: SizedBox(
          width: appWidth,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                if (kIsWeb)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
              ],
            ),
            child: useSafeArea
                ? SafeArea(
                    child: SizedBox(width: double.infinity, child: child),
                  )
                : SizedBox.expand(child: child),
          ),
        ),
      ),
    );
  }
}
