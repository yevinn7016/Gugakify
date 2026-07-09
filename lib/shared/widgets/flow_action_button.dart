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
      height: 48,
      child: primary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: onPressed == null ? AppColors.disabledGray : AppColors.lightPurple,
                foregroundColor: onPressed == null ? AppColors.textGray : AppColors.primaryPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryPurple,
                side: const BorderSide(color: AppColors.lightPurple),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
    );
  }
}
