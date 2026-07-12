import 'package:flutter/material.dart';

import 'hanji_background.dart';
import 'mobile_shell.dart';

class GugakifyAppScaffold extends StatelessWidget {
  const GugakifyAppScaffold({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0xFFFFFDF8),
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
