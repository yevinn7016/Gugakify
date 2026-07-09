import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.notoSansKrTextTheme(base.textTheme);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryPurple,
        secondary: AppColors.lightPurple,
        surface: AppColors.background,
        onSurface: AppColors.textBlack,
      ),
      textTheme: textTheme.apply(
        bodyColor: AppColors.textBlack,
        displayColor: AppColors.textBlack,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textBlack,
      ),
      splashColor: AppColors.lightPurple.withValues(alpha: 0.22),
      highlightColor: AppColors.lightPurple.withValues(alpha: 0.14),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryPurple,
        linearTrackColor: AppColors.disabledGray,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.textBlack,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
