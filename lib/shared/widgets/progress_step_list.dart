import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ProgressStepList extends StatelessWidget {
  const ProgressStepList({
    super.key,
    required this.steps,
    required this.progress,
  });

  final List<String> steps;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final activeIndex = (progress * steps.length).floor().clamp(0, steps.length - 1);
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: Row(
              children: [
                Icon(
                  i < activeIndex || progress >= 1
                      ? Icons.check_circle_rounded
                      : i == activeIndex
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                  size: 22,
                  color: i <= activeIndex || progress >= 1 ? AppColors.primaryPurple : AppColors.textGray,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    steps[i],
                    style: TextStyle(
                      fontWeight: i == activeIndex ? FontWeight.w800 : FontWeight.w500,
                      color: i <= activeIndex || progress >= 1 ? AppColors.textBlack : AppColors.textGray,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
