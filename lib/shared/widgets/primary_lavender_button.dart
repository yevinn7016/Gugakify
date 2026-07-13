import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PrimaryLavenderButton extends StatelessWidget {
  const PrimaryLavenderButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: DecoratedBox(
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
          style: ButtonStyle(
            elevation: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.pressed) ? 0 : 1,
            ),
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            foregroundColor: WidgetStateProperty.all(
              enabled ? AppColors.deepInkPurple : AppColors.textGray,
            ),
            shadowColor: WidgetStateProperty.all(
              AppColors.primaryPurple.withValues(alpha: 0.12),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final labelMaxWidth =
                  (constraints.maxWidth - (icon == null ? 0 : 28)).clamp(
                    0.0,
                    constraints.maxWidth,
                  );
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: labelMaxWidth),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class SecondaryOutlineButton extends StatelessWidget {
  const SecondaryOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: onPressed == null
              ? AppColors.textGray
              : AppColors.primaryPurple,
          side: BorderSide(
            color: onPressed == null
                ? AppColors.disabledGray
                : AppColors.primaryPurple.withValues(alpha: 0.45),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: onPressed == null
              ? AppColors.disabledGray
              : AppColors.white,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final labelMaxWidth =
                (constraints.maxWidth - (icon == null ? 0 : 28)).clamp(
                  0.0,
                  constraints.maxWidth,
                );
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: labelMaxWidth),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
