import 'package:flutter/material.dart';

/// Color tokens. Brand palette from docs/design-tokens.md; legacy
/// neutrals (grey*, lightBlue*, etc.) are kept as tokens here so widgets
/// never hardcode a literal `Color(...)` — Phase 2's mockup restyle pass
/// maps the remaining screens onto the brand tokens below.
class AppColors {
  // Brand palette (docs/design-tokens.md)
  static const Color brandPink = Color(0xFFF32AA0);
  static const Color primary = Color(0xFFD81B87);
  static const Color primaryDark = Color(0xFFA8106A);
  static const Color primaryTint = Color(0xFFFFECF7);
  static const Color primarySurface = Color(0xFFFFF5FB);
  static const Color onPrimaryMuted = Color(0xFFFFD3EC);
  static const Color brandBlue = Color(0xFF3158E9);
  static const Color navy = Color(0xFF05416F);
  static const Color green = Color(0xFF53B175);
  static const Color accent = Color(0xFFFFCB45);
  static const Color accentTint = Color(0xFFFFF1C2);
  static const Color ink = Color(0xFF17201B);
  static const Color muted = Color(0xFF5B655F);
  static const Color line = Color(0xFFE4E6E1);
  static const Color divider = Color(0xFFEEF0EA);
  static const Color background = Color(0xFFF6F7F3);
  static const Color backgroundAlt = Color(0xFFF2F3EE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color danger = Color(0xFFB42318);
  static const Color dangerTint = Color(0xFFFDECEA);

  // Order status badges
  static const Color outForDeliveryBg = accentTint;
  static const Color outForDeliveryFg = Color(0xFF7A5A00);
  static const Color deliveredBg = Color(0xFFE7F4EC);
  static const Color deliveredFg = Color(0xFF0A5A34);
  static const Color cancelledBg = Color(0xFFFDECE7);
  static const Color cancelledFg = Color(0xFF9A3412);

  // Legacy tokens kept for screens not yet restyled to the mockup
  // (Phase 2). Prefer the brand tokens above in new code.
  static const Color primaryButtonColor = brandPink;
  static const Color googleSignInButtonColor = Color(0xFFF6F5F5);
  static const Color googleSignInShadowColor = Colors.grey;
  static const Color textFormFieldColor = Color.fromARGB(255, 207, 207, 207);
  static const Color blue = navy;
  static const Color hintTextColor = Color(0xFF676767);
  static const Color hintTextColor1 = Color(0xFFF3F3F3);
  static const Color unselectedOTP = Color.fromRGBO(248, 55, 88, 0.33);
  static const Color selectedOTP = brandPink;
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

  // Category card colors (existing placeholder categories; docs/design-tokens.md
  // lists the mockup's per-category bg/icon pairs for the Phase 2 restyle).
  static const List<Map<String, dynamic>> categoryColors = [
    {
      'categoryCard': Color.fromRGBO(83, 177, 117, 0.1),
      'categoryCardBorder': Color.fromRGBO(83, 177, 117, 1),
    },
    {
      'categoryCard': Color.fromRGBO(255, 236, 247, 1),
      'categoryCardBorder': Color.fromRGBO(251, 84, 182, 1),
    },
    {
      'categoryCard': Color.fromRGBO(248, 164, 76, 0.1),
      'categoryCardBorder': Color.fromRGBO(250, 189, 124, 1),
    },
    {
      'categoryCard': Color.fromRGBO(237, 247, 253, 1),
      'categoryCardBorder': Color.fromRGBO(82, 186, 244, 1),
    },
  ];
}
