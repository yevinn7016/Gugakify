import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class GugakHeader extends StatelessWidget {
  const GugakHeader({
    super.key,
    required this.title,
    this.onBack,
    this.showBack = true,
  });

  final String title;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          if (showBack)
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: onBack ?? () => context.pop(),
              ),
            ),
          if (!showBack) const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primaryPurple,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Image.asset(
            'assets/icons/gugakify_wordmark.png',
            width: 102,
            errorBuilder: (_, error, stackTrace) => const Text(
              'Gugakify',
              style: TextStyle(
                color: AppColors.primaryPurple,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
