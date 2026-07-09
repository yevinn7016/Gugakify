import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class GrayCard extends StatelessWidget {
  const GrayCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = AppColors.cardGray,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
