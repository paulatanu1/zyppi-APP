import 'package:flutter/material.dart';

/// Type scale (design v2). Sora = display/headings, Manrope = UI/body.
/// Fonts are bundled in assets/fonts/Sora and assets/fonts/Manrope.
///
/// | Style        | Font    | Size/weight | Used for                         |
/// |--------------|---------|-------------|----------------------------------|
/// | displaySmall | Sora    | 31 / 700    | onboarding headline              |
/// | headlineSmall| Sora    | 24 / 700    | home ETA, product title (22)     |
/// | titleLarge   | Sora    | 18 / 700    | app-bar titles                   |
/// | titleMedium  | Sora    | 17 / 700    | section headers                  |
/// | bodyLarge    | Manrope | 15 / 500    | paragraphs                       |
/// | bodyMedium   | Manrope | 14 / 500    | default text                     |
/// | labelLarge   | Manrope | 14 / 700    | product names, list rows         |
/// | bodySmall    | Manrope | 12 / 600    | captions, weights                |
/// | labelSmall   | Manrope | 11 / 800    | overlines, badges (+0.08em)      |
abstract final class ZFonts {
  static const display = 'Sora';
  static const body = 'Manrope';
  // Bengali / Hindi / Punjabi glyphs fall back to Noto Sans families if bundled.
  static const fallback = [
    'Noto Sans Bengali',
    'Noto Sans Devanagari',
    'Noto Sans Gurmukhi',
  ];
}

TextTheme zyppiTextTheme(Color ink, Color ink2, Color ink3) {
  TextStyle sora(
    double size, {
    FontWeight w = FontWeight.w700,
    double h = 1.15,
  }) => TextStyle(
    fontFamily: ZFonts.display,
    // Sora has no ₹ (U+20B9): Manrope draws it, so amounts in headings
    // ("Order total", "To pay") stay in the app's own fonts.
    fontFamilyFallback: const [ZFonts.body, ...ZFonts.fallback],
    fontSize: size,
    fontWeight: w,
    height: h,
    letterSpacing: -0.02 * size,
    color: ink,
  );
  TextStyle manrope(
    double size,
    FontWeight w, {
    Color? c,
    double h = 1.4,
    double ls = 0,
  }) => TextStyle(
    fontFamily: ZFonts.body,
    fontFamilyFallback: ZFonts.fallback,
    fontSize: size,
    fontWeight: w,
    height: h,
    letterSpacing: ls,
    color: c ?? ink,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  return TextTheme(
    displaySmall: sora(31, h: 1.12),
    headlineMedium: sora(27),
    headlineSmall: sora(24, h: 1.1),
    titleLarge: sora(18),
    titleMedium: sora(17),
    titleSmall: sora(15),
    bodyLarge: manrope(15, FontWeight.w500, c: ink2, h: 1.5),
    bodyMedium: manrope(14, FontWeight.w500),
    bodySmall: manrope(12, FontWeight.w600, c: ink3),
    labelLarge: manrope(14, FontWeight.w700),
    labelMedium: manrope(13, FontWeight.w700),
    labelSmall: manrope(11, FontWeight.w800, c: ink3, ls: 0.88),
  );
}

/// Extra named styles that are not part of Material's TextTheme.
extension ZTextX on TextTheme {
  /// Bold price, e.g. ₹149.
  TextStyle get price =>
      labelLarge!.copyWith(fontSize: 15, fontWeight: FontWeight.w800);

  /// Struck-through MRP, e.g. ₹179.
  TextStyle get mrp =>
      bodySmall!.copyWith(decoration: TextDecoration.lineThrough);

  /// Uppercase overline, e.g. ARRIVING IN.
  TextStyle get overline => labelSmall!;
}
