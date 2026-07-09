import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  static const logo = TextStyle(
    color: AppColors.primaryPurple,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  static const title = TextStyle(
    color: AppColors.textBlack,
    fontSize: 21,
    fontWeight: FontWeight.w700,
    height: 1.35,
    letterSpacing: 0,
  );

  static const body = TextStyle(
    color: AppColors.textBlack,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0,
  );

  static const caption = TextStyle(
    color: AppColors.textGray,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: 0,
  );
}
