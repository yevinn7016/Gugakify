import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class OptionChipButton extends StatelessWidget {
  const OptionChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.lightPurple : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primaryPurple : AppColors.disabledGray,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primaryPurple : AppColors.textBlack,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
