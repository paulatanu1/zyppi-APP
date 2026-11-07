import 'package:flutter/material.dart';

/// Zyppi colour tokens (design v2). Read them with `context.z`.
///
/// Every value here maps 1:1 to a CSS variable in docs/mockups/zyppi.css
/// (`--brand` → [brand], `--t-veg` → [tileVeg], …).
@immutable
class ZColors extends ThemeExtension<ZColors> {
  const ZColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.line,
    required this.line2,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.onBrand,
    required this.brand,
    required this.brandPress,
    required this.brandText,
    required this.brandSoft,
    required this.brandSoft2,
    required this.header,
    required this.headerInk,
    required this.headerInk2,
    required this.blue,
    required this.blueText,
    required this.blueSoft,
    required this.ok,
    required this.okSoft,
    required this.warn,
    required this.warnSoft,
    required this.danger,
    required this.dangerSoft,
    required this.deal,
    required this.dealInk,
    required this.tileFruit,
    required this.tileVeg,
    required this.tileDairy,
    required this.tileBakery,
    required this.tileMeat,
    required this.tileDrink,
    required this.tileOil,
    required this.tileAll,
    required this.mapBg,
    required this.mapRoad,
    required this.mapBlock,
    required this.mapPark,
    required this.mapWater,
    required this.shadow,
  });

  final Color bg, surface, surface2, surface3, line, line2;
  final Color ink, ink2, ink3, onBrand;
  final Color brand, brandPress, brandText, brandSoft, brandSoft2;
  final Color header, headerInk, headerInk2;
  final Color blue, blueText, blueSoft;
  final Color ok, okSoft, warn, warnSoft, danger, dangerSoft;
  final Color deal, dealInk;
  final Color tileFruit,
      tileVeg,
      tileDairy,
      tileBakery,
      tileMeat,
      tileDrink,
      tileOil,
      tileAll;
  final Color mapBg, mapRoad, mapBlock, mapPark, mapWater;
  final Color shadow;

  /// Parses a data-driven colour such as a category's `colorHex`
  /// (ARGB hex, e.g. `FFF2E6D9`). Pass it through `zTileTint` for dark mode.
  static Color fromHex(String argbHex) => Color(int.parse(argbHex, radix: 16));

  static const light = ZColors(
    bg: Color(0xFFF6F5F2),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF0EEE9),
    surface3: Color(0xFFE8E5DF),
    line: Color(0xFFE4E1DA),
    line2: Color(0xFFD6D2C9),
    ink: Color(0xFF141519),
    ink2: Color(0xFF55585F),
    ink3: Color(0xFF83868D),
    onBrand: Color(0xFFFFFFFF),
    brand: Color(0xFFD4127B),
    brandPress: Color(0xFFB00E66),
    brandText: Color(0xFFC0106F),
    brandSoft: Color(0xFFFDE8F3),
    brandSoft2: Color(0xFFFBD3E8),
    header: Color(0xFFD4127B),
    headerInk: Color(0xFFFFFFFF),
    headerInk2: Color(0xFFFFD6EB),
    blue: Color(0xFF2443D6),
    blueText: Color(0xFF2443D6),
    blueSoft: Color(0xFFE7EBFD),
    ok: Color(0xFF138A4A),
    okSoft: Color(0xFFE2F4E9),
    warn: Color(0xFF9A5B00),
    warnSoft: Color(0xFFFFF1CF),
    danger: Color(0xFFC2263A),
    dangerSoft: Color(0xFFFDE8EA),
    deal: Color(0xFFFFC83D),
    dealInk: Color(0xFF3B2A00),
    tileFruit: Color(0xFFFFF0E6),
    tileVeg: Color(0xFFEAF6E4),
    tileDairy: Color(0xFFEAF1FC),
    tileBakery: Color(0xFFFBF0E2),
    tileMeat: Color(0xFFFDEBEA),
    tileDrink: Color(0xFFF1ECFB),
    tileOil: Color(0xFFFFF6D9),
    tileAll: Color(0xFFEEF0EA),
    mapBg: Color(0xFFECEAE4),
    mapRoad: Color(0xFFFFFFFF),
    mapBlock: Color(0xFFE2DFD8),
    mapPark: Color(0xFFD9EDD2),
    mapWater: Color(0xFFCFE3F5),
    shadow: Color(0x14141519),
  );

  static const dark = ZColors(
    bg: Color(0xFF0D0E11),
    surface: Color(0xFF16171C),
    surface2: Color(0xFF1E2026),
    surface3: Color(0xFF272930),
    line: Color(0xFF2A2C33),
    line2: Color(0xFF383B43),
    ink: Color(0xFFF2F2F4),
    ink2: Color(0xFFA8AAB2),
    ink3: Color(0xFF787B84),
    onBrand: Color(0xFFFFFFFF),
    brand: Color(0xFFE0198A),
    brandPress: Color(0xFFC21275),
    brandText: Color(0xFFFF6DB7),
    brandSoft: Color(0xFF33142A),
    brandSoft2: Color(0xFF4A1B3C),
    header: Color(0xFF1A0A15),
    headerInk: Color(0xFFFFFFFF),
    headerInk2: Color(0xFFF3A9D0),
    blue: Color(0xFF4865F0),
    blueText: Color(0xFF97A9FF),
    blueSoft: Color(0xFF1A2150),
    ok: Color(0xFF3FD27F),
    okSoft: Color(0xFF0F2E1D),
    warn: Color(0xFFF6B73C),
    warnSoft: Color(0xFF33270A),
    danger: Color(0xFFFF6B7D),
    dangerSoft: Color(0xFF3A1218),
    deal: Color(0xFFFFC83D),
    dealInk: Color(0xFF3B2A00),
    tileFruit: Color(0xFF2A1E17),
    tileVeg: Color(0xFF18261A),
    tileDairy: Color(0xFF17202E),
    tileBakery: Color(0xFF2A2216),
    tileMeat: Color(0xFF2C1A1B),
    tileDrink: Color(0xFF211B2E),
    tileOil: Color(0xFF2B2612),
    tileAll: Color(0xFF1E2026),
    mapBg: Color(0xFF15171C),
    mapRoad: Color(0xFF2A2D35),
    mapBlock: Color(0xFF1C1E24),
    mapPark: Color(0xFF16261B),
    mapWater: Color(0xFF14243A),
    shadow: Color(0x59000000),
  );

  /// Card/sheet shadow used by floating elements (cart bar, map buttons).
  List<BoxShadow> get elevation => [
    BoxShadow(color: shadow, blurRadius: 24, offset: const Offset(0, 8)),
  ];

  @override
  ZColors copyWith() => this;

  @override
  ZColors lerp(ThemeExtension<ZColors>? other, double t) {
    if (other is! ZColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return ZColors(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      surface3: l(surface3, other.surface3),
      line: l(line, other.line),
      line2: l(line2, other.line2),
      ink: l(ink, other.ink),
      ink2: l(ink2, other.ink2),
      ink3: l(ink3, other.ink3),
      onBrand: l(onBrand, other.onBrand),
      brand: l(brand, other.brand),
      brandPress: l(brandPress, other.brandPress),
      brandText: l(brandText, other.brandText),
      brandSoft: l(brandSoft, other.brandSoft),
      brandSoft2: l(brandSoft2, other.brandSoft2),
      header: l(header, other.header),
      headerInk: l(headerInk, other.headerInk),
      headerInk2: l(headerInk2, other.headerInk2),
      blue: l(blue, other.blue),
      blueText: l(blueText, other.blueText),
      blueSoft: l(blueSoft, other.blueSoft),
      ok: l(ok, other.ok),
      okSoft: l(okSoft, other.okSoft),
      warn: l(warn, other.warn),
      warnSoft: l(warnSoft, other.warnSoft),
      danger: l(danger, other.danger),
      dangerSoft: l(dangerSoft, other.dangerSoft),
      deal: l(deal, other.deal),
      dealInk: l(dealInk, other.dealInk),
      tileFruit: l(tileFruit, other.tileFruit),
      tileVeg: l(tileVeg, other.tileVeg),
      tileDairy: l(tileDairy, other.tileDairy),
      tileBakery: l(tileBakery, other.tileBakery),
      tileMeat: l(tileMeat, other.tileMeat),
      tileDrink: l(tileDrink, other.tileDrink),
      tileOil: l(tileOil, other.tileOil),
      tileAll: l(tileAll, other.tileAll),
      mapBg: l(mapBg, other.mapBg),
      mapRoad: l(mapRoad, other.mapRoad),
      mapBlock: l(mapBlock, other.mapBlock),
      mapPark: l(mapPark, other.mapPark),
      mapWater: l(mapWater, other.mapWater),
      shadow: l(shadow, other.shadow),
    );
  }
}

extension ZColorsX on BuildContext {
  /// Zyppi colour tokens for the current theme (light or dark).
  ZColors get z => Theme.of(this).extension<ZColors>()!;
}
