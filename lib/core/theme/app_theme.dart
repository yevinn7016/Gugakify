import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(useMaterial3: true, fontFamily: 'Pretendard');
    final textTheme = base.textTheme.apply(fontFamily: 'Pretendard');
    final primaryTextTheme = base.primaryTextTheme.apply(
      fontFamily: 'Pretendard',
    );

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
      primaryTextTheme: primaryTextTheme.apply(
        bodyColor: AppColors.textBlack,
        displayColor: AppColors.textBlack,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textBlack,
        titleTextStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textBlack,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textGray,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textBlack,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textBlack,
          height: 1.5,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
      ),
      splashColor: AppColors.lightPurple.withValues(alpha: 0.22),
      highlightColor: AppColors.lightPurple.withValues(alpha: 0.14),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryPurple,
        linearTrackColor: AppColors.disabledGray,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.textBlack,
        contentTextStyle: TextStyle(
          fontFamily: 'Pretendard',
          color: Colors.white,
        ),
      ),
    );
  }
}
