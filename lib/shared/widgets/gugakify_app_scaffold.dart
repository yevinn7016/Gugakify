import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'hanji_background.dart';
import 'mobile_shell.dart';

class GugakifyAppScaffold extends StatelessWidget {
  const GugakifyAppScaffold({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.backgroundAlt,
    this.padding = const EdgeInsets.symmetric(horizontal: 22),
  });

  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileShell(
        child: HanjiBackground(
          baseColor: backgroundColor,
          child: SingleChildScrollView(
            padding: padding.add(const EdgeInsets.only(bottom: 36)),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ),
    );
  }
}
