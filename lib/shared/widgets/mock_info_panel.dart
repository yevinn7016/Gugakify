import 'package:flutter/material.dart';

import 'gray_card.dart';

class MockInfoPanel extends StatelessWidget {
  const MockInfoPanel({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GrayCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
