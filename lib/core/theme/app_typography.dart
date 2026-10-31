import 'package:flutter/material.dart';

/// Type scale — Zyppi design system v2: Sora for headings/display,
/// Manrope for body/UI text. Sizes are logical pixels; wrap with `.sp` at
/// the call site for flutter_screenutil scaling.
///
/// Styles carry no colour: text inherits the theme's ink from
/// `DefaultTextStyle`, so it is correct in light and dark. Muted/faint text
/// sets `color: context.colors.muted` / `.faint` at the call site.
class AppTypography {
  static const String sora = 'Sora';
  static const String manrope = 'Manrope';

  // v2's named scale (docs/design-tokens.md Styleguide) — prefer these in
  // new code.
  static const TextStyle display = TextStyle(
    fontFamily: sora,
    fontSize: 31,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle titleL = TextStyle(
    fontFamily: sora,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle titleM = TextStyle(
    fontFamily: sora,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle section = TextStyle(
    fontFamily: sora,
    fontSize: 17,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle body = TextStyle(
    fontFamily: manrope,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle label = TextStyle(
    fontFamily: manrope,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle price = TextStyle(
    fontFamily: manrope,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: manrope,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: manrope,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.66, // 0.08em at 11px
  );

  // Pre-v2 names, kept as aliases onto the scale above so existing call
  // sites keep working; migrate call sites to the named styles above as
  // each screen gets its v2 restyle.
  static const TextStyle displayLarge = TextStyle(
    fontFamily: sora,
    fontSize: 31,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: sora,
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headlineSmall = titleL;

  static const TextStyle titleLarge = TextStyle(
    fontFamily: sora,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle titleMedium = section;

  static const TextStyle bodyLarge = body;

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: manrope,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: manrope,
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: manrope,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: manrope,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.66, // 0.06em at 11px
  );
}
