import 'package:flutter/material.dart';

class MobileShell extends StatelessWidget {
  const MobileShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF6F2FA),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 392),
          child: SafeArea(child: child),
        ),
      ),
    );
  }
}
