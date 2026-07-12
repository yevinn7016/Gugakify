import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class FlowActionButton extends StatelessWidget {
  const FlowActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: primary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                elevation: onPressed == null ? 0 : 1,
                backgroundColor: onPressed == null
                    ? AppColors.disabledGray
                    : AppColors.lightPurple,
                foregroundColor: onPressed == null
                    ? AppColors.textGray
                    : AppColors.primaryPurple,
                shadowColor: AppColors.primaryPurple.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: onPressed == null
                    ? AppColors.textGray
                    : AppColors.primaryPurple,
                backgroundColor: onPressed == null
                    ? AppColors.disabledGray
                    : Colors.white.withValues(alpha: 0.9),
                side: BorderSide(
                  color: onPressed == null
                      ? AppColors.disabledGray
                      : AppColors.primaryPurple.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
    );
  }
}
