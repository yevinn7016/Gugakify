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
    final enabled = onPressed != null;
    return SizedBox(
      height: primary ? 56 : 52,
      child: primary
          ? DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: enabled
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.lightPurple, AppColors.softPurple],
                      )
                    : null,
                color: enabled ? null : AppColors.disabledGray,
              ),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  elevation: enabled ? 1 : 0,
                  backgroundColor: Colors.transparent,
                  foregroundColor: enabled
                      ? AppColors.deepInkPurple
                      : AppColors.textGray,
                  shadowColor: AppColors.primaryPurple.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: enabled
                    ? AppColors.primaryPurple
                    : AppColors.textGray,
                backgroundColor: enabled
                    ? Colors.white.withValues(alpha: 0.9)
                    : AppColors.disabledGray,
                side: BorderSide(
                  color: enabled
                      ? AppColors.lightPurple
                      : AppColors.disabledGray,
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
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}
