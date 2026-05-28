import 'package:flutter/material.dart';

/// Design tokens — single source mirrored from DESIGN.md.
/// Widgets must reference these instead of hardcoding values.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF121212);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Colors.white70;
  static const Color brandRed = Color(0xFFFE2C55);
  static const Color brandCyan = Color(0xFF25F4EE);
  static const Color divider = Colors.white24;
}

/// Soft shadow applied to text/icons rendered over video for legibility.
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

/// Spacing scale from DESIGN.md.
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
