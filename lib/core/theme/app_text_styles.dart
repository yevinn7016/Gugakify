import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  /// 로고 워드마크 전용 스타일 (변경하지 않음)
  static const logo = TextStyle(
    fontFamily: 'Pretendard',
    color: AppColors.primaryPurple,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  /// 화면 대제목 (22~26px, 700)
  static const TextStyle display = TextStyle(
    fontFamily: 'Pretendard',
    color: AppColors.textBlack,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0,
  );

  /// 섹션 제목 (16~18px, 700)
  static const TextStyle section = TextStyle(
    fontFamily: 'Pretendard',
    color: AppColors.textBlack,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.35,
    letterSpacing: 0,
  );

  /// 카드 제목 (15~17px, 700)
  static const TextStyle cardTitle = TextStyle(
    fontFamily: 'Pretendard',
    color: AppColors.textBlack,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.35,
    letterSpacing: 0,
  );

  /// 카드 설명 (13~14px, 400~500)
  static const TextStyle cardBody = TextStyle(
    fontFamily: 'Pretendard',
    color: AppColors.textMuted,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0,
  );

  /// 화면 대제목 (하위 호환: 기존 title)
  static const TextStyle title = TextStyle(
    fontFamily: 'Pretendard',
    color: AppColors.textBlack,
    fontSize: 21,
    fontWeight: FontWeight.w700,
    height: 1.35,
    letterSpacing: 0,
  );

  /// 본문 (14~15px, 400~500)
  static const TextStyle body = TextStyle(
    fontFamily: 'Pretendard',
    color: AppColors.textBlack,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0,
  );

  /// 설명/보조 문구 (12~13px, 400)
  static const TextStyle caption = TextStyle(
    fontFamily: 'Pretendard',
    color: AppColors.textGray,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.35,
    letterSpacing: 0,
  );

  /// 버튼 텍스트 (15~16px, 600)
  static const TextStyle button = TextStyle(
    fontFamily: 'Pretendard',
    color: AppColors.textBlack,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  /// 입력창 텍스트 (14~15px, 400~500)
  static const TextStyle input = TextStyle(
    fontFamily: 'Pretendard',
    color: AppColors.textBlack,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );
}
