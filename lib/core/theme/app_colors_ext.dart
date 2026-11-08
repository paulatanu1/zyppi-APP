import 'package:flutter/material.dart';

/// Dark-mode-aware color tokens — every v2 brand/semantic token as an
/// instance field, resolved at runtime via `context.colors.*` instead of
/// the compile-time-constant `AppColors.*`. Values from
/// docs/design-tokens.md's "Colors — light"/"Colors — dark" tables.
///
/// Legacy tokens (grey*, lightBlue*, etc. in `AppColors`) are not part of
/// this extension — they belong to screens not yet restyled to v2, which
/// get converted to proper v2 tokens (and so dark-mode awareness) as part
/// of that restyle, not before.
@immutable
class AppColorsExt extends ThemeExtension<AppColorsExt> {
  final Color primary;
  final Color primaryDark;
  final Color primaryText;
  final Color primaryTint;
  final Color primarySurface;
  final Color header;
  final Color headerAlt;
  final Color onPrimaryMuted;
  final Color brandBlue;
  final Color blueText;
  final Color blueSoft;
  final Color green;
  final Color greenSoft;
  final Color warn;
  final Color warnSoft;
  final Color danger;
  final Color dangerTint;
  final Color accent;
  final Color accentInk;
  final Color accentTint;
  final Color onboardingDotInactive;
  final Color ink;
  final Color muted;
  final Color faint;
  final Color line;
  final Color lineAlt;
  final Color divider;
  final Color background;
  final Color backgroundAlt;
  final Color surface;
  final Color surfaceAlt;
  final Color surfaceAlt2;
  final Color shadow;
  final Color dividerOnPrimary;
  final Color categoryFruitTint;
  final Color categoryVegTint;
  final Color categoryDairyTint;
  final Color categoryBakeryTint;
  final Color categoryMeatTint;
  final Color categoryDrinkTint;
  final Color categoryOilTint;
  final Color categoryAllTint;
  final Color fruitsTint;
  final Color fruitsFg;
  final Color outForDeliveryBg;
  final Color outForDeliveryFg;
  final Color deliveredBg;
  final Color deliveredFg;
  final Color cancelledBg;
  final Color cancelledFg;
  final Color mapBg;
  final Color mapRoad;
  final Color mapBlock;
  final Color mapPark;
  final Color mapWater;
  final Color mapRoute;

  const AppColorsExt({
    required this.primary,
    required this.primaryDark,
    required this.primaryText,
    required this.primaryTint,
    required this.primarySurface,
    required this.header,
    required this.headerAlt,
    required this.onPrimaryMuted,
    required this.brandBlue,
    required this.blueText,
    required this.blueSoft,
    required this.green,
    required this.greenSoft,
    required this.warn,
    required this.warnSoft,
    required this.danger,
    required this.dangerTint,
    required this.accent,
    required this.accentInk,
    required this.accentTint,
    required this.onboardingDotInactive,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.line,
    required this.lineAlt,
    required this.divider,
    required this.background,
    required this.backgroundAlt,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceAlt2,
    required this.shadow,
    required this.dividerOnPrimary,
    required this.categoryFruitTint,
    required this.categoryVegTint,
    required this.categoryDairyTint,
    required this.categoryBakeryTint,
    required this.categoryMeatTint,
    required this.categoryDrinkTint,
    required this.categoryOilTint,
    required this.categoryAllTint,
    required this.fruitsTint,
    required this.fruitsFg,
    required this.outForDeliveryBg,
    required this.outForDeliveryFg,
    required this.deliveredBg,
    required this.deliveredFg,
    required this.cancelledBg,
    required this.cancelledFg,
    required this.mapBg,
    required this.mapRoad,
    required this.mapBlock,
    required this.mapPark,
    required this.mapWater,
    required this.mapRoute,
  });

  static const light = AppColorsExt(
    primary: Color(0xFFD4127B),
    primaryDark: Color(0xFFB00E66),
    primaryText: Color(0xFFC0106F),
    primaryTint: Color(0xFFFDE8F3),
    primarySurface: Color(0xFFFBD3E8),
    header: Color(0xFFD4127B),
    headerAlt: Color(0xFFB00E66),
    onPrimaryMuted: Color(0xFFFFD6EB),
    brandBlue: Color(0xFF2443D6),
    blueText: Color(0xFF2443D6),
    blueSoft: Color(0xFFE7EBFD),
    green: Color(0xFF138A4A),
    greenSoft: Color(0xFFE2F4E9),
    warn: Color(0xFF9A5B00),
    warnSoft: Color(0xFFFFF1CF),
    danger: Color(0xFFC2263A),
    dangerTint: Color(0xFFFDE8EA),
    accent: Color(0xFFFFC83D),
    accentInk: Color(0xFF3B2A00),
    accentTint: Color(0xFFFFF1CF),
    onboardingDotInactive: Color(0xFFF07BBE),
    ink: Color(0xFF141519),
    muted: Color(0xFF55585F),
    faint: Color(0xFF83868D),
    line: Color(0xFFE4E1DA),
    lineAlt: Color(0xFFD6D2C9),
    divider: Color(0xFFEEF0EA),
    background: Color(0xFFF6F5F2),
    backgroundAlt: Color(0xFFF0EEE9),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF0EEE9),
    surfaceAlt2: Color(0xFFE8E5DF),
    shadow: Color(0x1A141519),
    dividerOnPrimary: Color(0x24FFFFFF),
    categoryFruitTint: Color(0xFFFFF0E6),
    categoryVegTint: Color(0xFFEAF6E4),
    categoryDairyTint: Color(0xFFEAF1FC),
    categoryBakeryTint: Color(0xFFFBF0E2),
    categoryMeatTint: Color(0xFFFDEBEA),
    categoryDrinkTint: Color(0xFFF1ECFB),
    categoryOilTint: Color(0xFFFFF6D9),
    categoryAllTint: Color(0xFFEEF0EA),
    fruitsTint: Color(0xFFFFF0E6),
    fruitsFg: Color(0xFFC2410C),
    outForDeliveryBg: Color(0xFFFFF1CF),
    outForDeliveryFg: Color(0xFF9A5B00),
    deliveredBg: Color(0xFFE2F4E9),
    deliveredFg: Color(0xFF138A4A),
    cancelledBg: Color(0xFFFDE8EA),
    cancelledFg: Color(0xFFC2263A),
    mapBg: Color(0xFFECEAE4),
    mapRoad: Color(0xFFFFFFFF),
    mapBlock: Color(0xFFE2DFD8),
    mapPark: Color(0xFFD9EDD2),
    mapWater: Color(0xFFCFE3F5),
    mapRoute: Color(0xFFC0106F),
  );

  static const dark = AppColorsExt(
    primary: Color(0xFFE0198A),
    primaryDark: Color(0xFFC21275),
    primaryText: Color(0xFFFF6DB7),
    primaryTint: Color(0xFF33142A),
    primarySurface: Color(0xFF4A1B3C),
    header: Color(0xFF1A0A15),
    headerAlt: Color(0xFF2A1022),
    onPrimaryMuted: Color(0xFFF3A9D0),
    brandBlue: Color(0xFF4865F0),
    blueText: Color(0xFF97A9FF),
    blueSoft: Color(0xFF1A2150),
    green: Color(0xFF3FD27F),
    greenSoft: Color(0xFF0F2E1D),
    warn: Color(0xFFF6B73C),
    warnSoft: Color(0xFF33270A),
    danger: Color(0xFFFF6B7D),
    dangerTint: Color(0xFF3A1218),
    accent: Color(0xFFFFC83D),
    accentInk: Color(0xFF3B2A00),
    accentTint: Color(0xFF33270A),
    onboardingDotInactive: Color(0xFF4A1B3C),
    ink: Color(0xFFF2F2F4),
    muted: Color(0xFFA8AAB2),
    faint: Color(0xFF787B84),
    line: Color(0xFF2A2C33),
    lineAlt: Color(0xFF383B43),
    divider: Color(0xFF2A2C33),
    background: Color(0xFF0D0E11),
    backgroundAlt: Color(0xFF1E2026),
    surface: Color(0xFF16171C),
    surfaceAlt: Color(0xFF1E2026),
    surfaceAlt2: Color(0xFF272930),
    shadow: Color(0x66000000),
    dividerOnPrimary: Color(0x24FFFFFF),
    categoryFruitTint: Color(0xFF2A1E17),
    categoryVegTint: Color(0xFF18261A),
    categoryDairyTint: Color(0xFF17202E),
    categoryBakeryTint: Color(0xFF2A2216),
    categoryMeatTint: Color(0xFF2C1A1B),
    categoryDrinkTint: Color(0xFF211B2E),
    categoryOilTint: Color(0xFF2B2612),
    categoryAllTint: Color(0xFF1E2026),
    fruitsTint: Color(0xFF2A1E17),
    fruitsFg: Color(0xFFFF6B4A),
    outForDeliveryBg: Color(0xFF33270A),
    outForDeliveryFg: Color(0xFFF6B73C),
    deliveredBg: Color(0xFF0F2E1D),
    deliveredFg: Color(0xFF3FD27F),
    cancelledBg: Color(0xFF3A1218),
    cancelledFg: Color(0xFFFF6B7D),
    mapBg: Color(0xFF15171C),
    mapRoad: Color(0xFF2A2D35),
    mapBlock: Color(0xFF1C1E24),
    mapPark: Color(0xFF16261B),
    mapWater: Color(0xFF14243A),
    mapRoute: Color(0xFFFF6DB7),
  );

  @override
  AppColorsExt copyWith() => this;

  @override
  AppColorsExt lerp(ThemeExtension<AppColorsExt>? other, double t) {
    if (other is! AppColorsExt) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColorsExt(
      primary: c(primary, other.primary),
      primaryDark: c(primaryDark, other.primaryDark),
      primaryText: c(primaryText, other.primaryText),
      primaryTint: c(primaryTint, other.primaryTint),
      primarySurface: c(primarySurface, other.primarySurface),
      header: c(header, other.header),
      headerAlt: c(headerAlt, other.headerAlt),
      onPrimaryMuted: c(onPrimaryMuted, other.onPrimaryMuted),
      brandBlue: c(brandBlue, other.brandBlue),
      blueText: c(blueText, other.blueText),
      blueSoft: c(blueSoft, other.blueSoft),
      green: c(green, other.green),
      greenSoft: c(greenSoft, other.greenSoft),
      warn: c(warn, other.warn),
      warnSoft: c(warnSoft, other.warnSoft),
      danger: c(danger, other.danger),
      dangerTint: c(dangerTint, other.dangerTint),
      accent: c(accent, other.accent),
      accentInk: c(accentInk, other.accentInk),
      accentTint: c(accentTint, other.accentTint),
      onboardingDotInactive: c(
        onboardingDotInactive,
        other.onboardingDotInactive,
      ),
      ink: c(ink, other.ink),
      muted: c(muted, other.muted),
      faint: c(faint, other.faint),
      line: c(line, other.line),
      lineAlt: c(lineAlt, other.lineAlt),
      divider: c(divider, other.divider),
      background: c(background, other.background),
      backgroundAlt: c(backgroundAlt, other.backgroundAlt),
      surface: c(surface, other.surface),
      surfaceAlt: c(surfaceAlt, other.surfaceAlt),
      surfaceAlt2: c(surfaceAlt2, other.surfaceAlt2),
      shadow: c(shadow, other.shadow),
      dividerOnPrimary: c(dividerOnPrimary, other.dividerOnPrimary),
      categoryFruitTint: c(categoryFruitTint, other.categoryFruitTint),
      categoryVegTint: c(categoryVegTint, other.categoryVegTint),
      categoryDairyTint: c(categoryDairyTint, other.categoryDairyTint),
      categoryBakeryTint: c(categoryBakeryTint, other.categoryBakeryTint),
      categoryMeatTint: c(categoryMeatTint, other.categoryMeatTint),
      categoryDrinkTint: c(categoryDrinkTint, other.categoryDrinkTint),
      categoryOilTint: c(categoryOilTint, other.categoryOilTint),
      categoryAllTint: c(categoryAllTint, other.categoryAllTint),
      fruitsTint: c(fruitsTint, other.fruitsTint),
      fruitsFg: c(fruitsFg, other.fruitsFg),
      outForDeliveryBg: c(outForDeliveryBg, other.outForDeliveryBg),
      outForDeliveryFg: c(outForDeliveryFg, other.outForDeliveryFg),
      deliveredBg: c(deliveredBg, other.deliveredBg),
      deliveredFg: c(deliveredFg, other.deliveredFg),
      cancelledBg: c(cancelledBg, other.cancelledBg),
      cancelledFg: c(cancelledFg, other.cancelledFg),
      mapBg: c(mapBg, other.mapBg),
      mapRoad: c(mapRoad, other.mapRoad),
      mapBlock: c(mapBlock, other.mapBlock),
      mapPark: c(mapPark, other.mapPark),
      mapWater: c(mapWater, other.mapWater),
      mapRoute: c(mapRoute, other.mapRoute),
    );
  }
}

/// `context.colors.primary` instead of `Theme.of(context).extension<AppColorsExt>()!.primary`.
extension AppColorsContext on BuildContext {
  AppColorsExt get colors => Theme.of(this).extension<AppColorsExt>()!;
}
