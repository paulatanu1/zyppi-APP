import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// Spacing on a 4-pt grid (docs/design-tokens.md → Spacing).
abstract final class ZSpace {
  static const double x1 = 4,
      x2 = 8,
      x3 = 12,
      x4 = 16,
      x5 = 20,
      x6 = 24,
      x8 = 32;

  /// Horizontal screen padding.
  static const double screen = 16;
}

/// Corner radii.
abstract final class ZRadius {
  static const double badge = 7,
      control = 11,
      chip = 18,
      input = 16,
      button = 16,
      card = 18,
      tile = 16,
      sheet = 26,
          // Onboarding hero illustration (zyppi.css .illo).
          illo =
          28;

  static BorderRadius all(double r) => BorderRadius.all(Radius.circular(r));
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}

/// Fixed component sizes.
abstract final class ZSize {
  static const double button = 54,
      input = 56,
      search = 50,
      addButton = 34,
      navBar = 78,
      cartBar = 60,
      touch = 44;
  static const double productTile = 112, categoryTile = 72;
}

/// Motion tokens. Respect `MediaQuery.disableAnimationsOf(context)`.
abstract final class ZMotion {
  static const Duration press = Duration(milliseconds: 120);
  static const Duration ui = Duration(milliseconds: 240);
  static const Duration entrance = Duration(milliseconds: 420);
  static const Duration sheet = Duration(milliseconds: 500);
  static const Duration stagger = Duration(milliseconds: 60);

  /// CSS cubic-bezier(.2,.7,.2,1)
  static const Curve standard = Cubic(0.2, 0.7, 0.2, 1);

  /// CSS cubic-bezier(.16,1,.3,1)
  static const Curve emphasized = Cubic(0.16, 1, 0.3, 1);

  static const double pressScale = 0.96;
}
