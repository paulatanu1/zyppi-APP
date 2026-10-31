import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light =>
      _theme(colors: AppColorsExt.light, brightness: Brightness.light);

  static ThemeData get dark =>
      _theme(colors: AppColorsExt.dark, brightness: Brightness.dark);

  static ThemeData _theme({
    required AppColorsExt colors,
    required Brightness brightness,
  }) => ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: colors.background,
    colorScheme: ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: colors.primary,
      primary: colors.primary,
      secondary: colors.brandBlue,
      surface: colors.surface,
      error: colors.danger,
    ),
    extensions: [colors],
    fontFamily: AppTypography.manrope,
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: colors.ink),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: colors.ink),
      headlineSmall: AppTypography.headlineSmall.copyWith(color: colors.ink),
      titleLarge: AppTypography.titleLarge.copyWith(color: colors.ink),
      titleMedium: AppTypography.titleMedium.copyWith(color: colors.ink),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: colors.ink),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: colors.ink),
      labelLarge: AppTypography.labelLarge.copyWith(color: colors.ink),
      bodySmall: AppTypography.bodySmall.copyWith(color: colors.muted),
      labelSmall: AppTypography.labelSmall.copyWith(color: colors.muted),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.ink,
      elevation: 0,
    ),
    dividerTheme: DividerThemeData(color: colors.divider, thickness: 1),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: AppColors.white,
        minimumSize: const Size.fromHeight(AppSizes.button),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: colors.line),
      ),
    ),
  );
}
