import 'package:flutter/material.dart';

/// Color tokens — Zyppi design system v2 (docs/design-tokens.md), light
/// mode. Legacy neutrals (grey*, lightBlue*, etc.) are kept as tokens here
/// so widgets never hardcode a literal `Color(...)` — the v2 restyle pass
/// maps the remaining screens onto the brand tokens below; dark-mode values
/// land alongside the `ThemeExtension` conversion in a later phase.
class AppColors {
  /// Parses an 8-digit ARGB hex string (as stored in mock JSON, e.g.
  /// category colorHex/borderColorHex) into a [Color].
  static Color fromHex(String argbHex) => Color(int.parse(argbHex, radix: 16));

  // Brand
  static const Color primary = Color(0xFF673AB7);
  static const Color primaryDark = Color(0xFF5E35B1);
  static const Color primaryText = Color(0xFF5E35B1);
  static const Color primaryTint = Color(0xFFEDE7F6);
  static const Color primarySurface = Color(0xFFD1C4E9);
  static const Color header = Color(0xFF673AB7);
  static const Color headerAlt = Color(0xFF5E35B1);
  static const Color onPrimaryMuted = Color(0xFFD1C4E9);

  // Blue (links, info)
  static const Color brandBlue = Color(0xFF2443D6);
  static const Color blueText = Color(0xFF2443D6);
  static const Color blueSoft = Color(0xFFE7EBFD);

  // Status
  static const Color green = Color(0xFF138A4A);
  static const Color greenSoft = Color(0xFFE2F4E9);
  static const Color warn = Color(0xFF9A5B00);
  static const Color warnSoft = Color(0xFFFFF1CF);
  static const Color danger = Color(0xFFC2263A);
  static const Color dangerTint = Color(0xFFFDE8EA);

  // Deals / promo
  static const Color accent = Color(0xFFFFC83D);
  static const Color accentInk = Color(0xFF3B2A00);
  static const Color accentTint = Color(0xFFFFF1CF);

  /// Onboarding's inactive step dot (not in the v2 token table, but the
  /// mockup itself specifies it).
  static const Color onboardingDotInactive = Color(0xFFF07BBE);

  // Neutrals / surfaces
  static const Color ink = Color(0xFF141519);
  static const Color muted = Color(0xFF55585F);
  static const Color faint = Color(0xFF83868D);
  static const Color line = Color(0xFFE4E1DA);
  static const Color lineAlt = Color(0xFFD6D2C9);
  static const Color divider = Color(0xFFEEF0EA);
  static const Color background = Color(0xFFF6F5F2);
  static const Color backgroundAlt = Color(0xFFF0EEE9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF0EEE9);
  static const Color surfaceAlt2 = Color(0xFFE8E5DF);

  /// Card/sheet drop-shadow colour (ink at ~10% alpha) — shadows only on
  /// the floating cart bar, map buttons and sheets.
  static const Color shadow = Color(0x1A141519);

  /// Divider on a `primary`-coloured surface (white at ~14% alpha), where
  /// the regular `divider`/`line` tokens (meant for light backgrounds)
  /// wouldn't be visible.
  static const Color dividerOnPrimary = Color(0x24FFFFFF);

  // Category tile tints (per-category bg; icon/fg colors come from the
  // Category model's own colorHex/borderColorHex, not a fixed token).
  static const Color categoryFruitTint = Color(0xFFFFF0E6);
  static const Color categoryVegTint = Color(0xFFEAF6E4);
  static const Color categoryDairyTint = Color(0xFFEAF1FC);
  static const Color categoryBakeryTint = Color(0xFFFBF0E2);
  static const Color categoryMeatTint = Color(0xFFFDEBEA);
  static const Color categoryDrinkTint = Color(0xFFF1ECFB);
  static const Color categoryOilTint = Color(0xFFFFF6D9);
  static const Color categoryAllTint = Color(0xFFEEF0EA);

  /// Decorative icon circle (e.g. the home promo banner) — not a category
  /// tile itself, just needs a tint/fg pair from the palette.
  static const Color fruitsTint = categoryFruitTint;
  static const Color fruitsFg = Color(0xFFC2410C);

  // Order status badges
  static const Color outForDeliveryBg = warnSoft;
  static const Color outForDeliveryFg = warn;
  static const Color deliveredBg = greenSoft;
  static const Color deliveredFg = green;
  static const Color cancelledBg = dangerTint;
  static const Color cancelledFg = danger;

  // Order-tracking map (decorative only — Tracking.dc.html)
  static const Color mapBg = Color(0xFFECEAE4);
  static const Color mapRoad = Color(0xFFFFFFFF);
  static const Color mapBlock = Color(0xFFE2DFD8);
  static const Color mapPark = Color(0xFFD9EDD2);
  static const Color mapWater = Color(0xFFCFE3F5);
  static const Color mapRoute = primaryText;

  // Legacy tokens kept for screens not yet restyled to the v2 mockup.
  // Prefer the brand tokens above in new code.
  static const Color brandPurple = primary;
  static const Color navy = Color(0xFF05416F);
  static const Color primaryButtonColor = brandPurple;
  static const Color googleSignInButtonColor = Color(0xFFF6F5F5);
  static const Color googleSignInShadowColor = Colors.grey;
  static const Color textFormFieldColor = Color.fromARGB(255, 207, 207, 207);
  static const Color blue = navy;
  static const Color hintTextColor = Color(0xFF676767);
  static const Color hintTextColor1 = Color(0xFFF3F3F3);
  static const Color unselectedOTP = Color.fromRGBO(248, 55, 88, 0.33);
  static const Color selectedOTP = brandPurple;
  static const Color selectedOTP1 = Color.fromARGB(255, 231, 62, 115);
  static const Color white = Color(0xFFFFFFFF);
  static const Color deepBlue = brandBlue;
  static const Color black = Color(0xFF000000);
  static const Color lightBlack = Color(0xFF6D6D6D);
  static const Color darkBlue = Color(0xFF181725);
  static const Color brownBlue = Color(0xFF4F4F4F);
  static const Color grey = Color(0xFFA8A8A9);
  static const Color grey1 = Color(0xFF575757);
  static const Color grey2 = Color(0xFFF2F3F2);
  static const Color grey3 = Color(0xFF7C7C7C);
  static const Color grey4 = Color(0xFFB3B3B3);
  static const Color grey5 = Color(0xFFE2E2E2);
  static const Color grey6 = Color(0xFFE5E5E5);
  static const Color grey7 = Color(0xFF909090);
  static const Color grey8 = Color(0xFFEBEBEB);
  static const Color deepBlue1 = Color(0xFF1541E6);
  static const Color deepBlue2 = Color(0xFF1C5FA1);
  static const Color deepBlue3 = Color(0xFF054F61);
  static const Color lightBlue = Color(0xFF597AF1);
  static const Color lightBlue1 = Color(0xFFCFDEF5);
  static const Color lightBlue2 = Color(0xFF8EB8FB);
  static const Color lightBlue3 = Color(0xFFF9F9F9);
  static const Color lightBlue4 = Color(0xFFD1E5F6);
  static const Color green1 = Color(0xFFCAEEC9);

  static LinearGradient gradientHomeBackGround = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.blueAccent.withValues(alpha: 0.6),
      Colors.white,
      Colors.white,
    ],
  );

  static const bottomSheet = Color(0xFFDDE7F6);
  static const borderColor = Color(0xFFCFDEF5);
}
