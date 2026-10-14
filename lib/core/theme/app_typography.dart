import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_colors.dart';

/// Type scale from docs/design-tokens.md. Sizes are logical pixels;
/// wrap with `.sp` at the call site for flutter_screenutil scaling.
class AppTypography {
  static const String montserrat = 'Montserrat';
  static const String poppins = 'Poppins';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: montserrat,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: montserrat,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: montserrat,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: montserrat,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: montserrat,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: poppins,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: poppins,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: poppins,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: poppins,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: poppins,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.muted,
    letterSpacing: 0.66, // 0.06em at 11px
  );
}
