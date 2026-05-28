import 'package:flutter/material.dart';

/// 디자인 토큰 — DESIGN.md를 그대로 옮긴 단일 소스.
/// 위젯은 값을 하드코딩하지 말고 반드시 이 토큰을 참조한다.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF121212);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Colors.white70;
  static const Color brandRed = Color(0xFFFE2C55);
  static const Color brandCyan = Color(0xFF25F4EE);
  static const Color bookmark = Color(0xFFFACC15);
  static const Color divider = Colors.white24;
}

/// 영상 위에 올라가는 텍스트/아이콘의 가독성을 위한 부드러운 그림자.
const List<Shadow> kOverlayTextShadows = [
  Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
];

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle username = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    shadows: kOverlayTextShadows,
  );

  static const TextStyle caption = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
    shadows: kOverlayTextShadows,
  );

  static const TextStyle actionCount = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    shadows: kOverlayTextShadows,
  );

  static const TextStyle musicTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    shadows: kOverlayTextShadows,
  );
}

/// DESIGN.md의 스페이싱 스케일.
class AppGaps {
  AppGaps._();

  static const double screenPadding = 16;
  static const double actionBarRightPadding = 8;
  static const double actionItemGap = 20;

  static const double actionIconSize = 34;
  static const double avatarSize = 48;
  static const double musicDiscSize = 48;
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        surface: AppColors.background,
        primary: AppColors.brandRed,
        secondary: AppColors.brandCyan,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.textPrimary,
      ),
    );
  }
}
