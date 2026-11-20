import 'package:flutter/painting.dart';
import 'package:zippy/core/widgets/z_brand_texture.dart';

/// Every colour of the launch animation, in one place
/// (docs: SPLASH_SPEC "Colours"). The splash is a brand moment and looks
/// the same in light and dark theme; only its last frame blends into the
/// app's own background (see `ZyppiSplashScreen`).
abstract final class SplashPalette {
  static const s1 = Color(0xFFEDE7F6);
  static const s2 = ZBrandTones.lilac;
  static const s3 = Color(0xFF7E57C2);
  static const brand = Color(0xFF673AB7);
  static const deep = ZBrandTones.deep;
  static const aurora = ZBrandTones.aurora;

  /// The four sweeps, in order; the last one stays as the background.
  static const stripes = [s1, s2, s3, brand];

  static const white = Color(0xFFFFFFFF);
  static const tileEnd = Color(0xFFF4EFFC);

  /// rgba(255,255,255,.7) – the tile's inner edge.
  static const tileEdge = Color(0xB3FFFFFF);

  /// rgba(30,0,80,.45) – the tile's drop shadow.
  static const tileShadow = Color(0x731E0050);

  /// rgba(20,0,60,.4) – the ellipse under the bouncing ball.
  static const groundShadow = Color(0x6614003C);

  /// rgba(255,255,255,.85)
  static const tagline = Color(0xD9FFFFFF);

  /// rgba(255,255,255,.8) – pulse ring and scooter speed lines.
  static const softWhite = Color(0xCCFFFFFF);

  static const clearWhite = Color(0x00FFFFFF);

  /// rgba(255,255,255,.95) – the glass highlight band.
  static const glass = Color(0xF2FFFFFF);
}

/// Sizes and positions from the spec ("Layout"), in logical pixels or as
/// fractions of the screen.
abstract final class SplashSpec {
  static const double tile = 124;
  static const double tileRadius = 32;

  /// While it is still a ball the tile is a circle (radius = half of [tile]).
  static const double ballRadius = 62;
  static const double zInset = 22;

  static const double wordTop = .56;
  static const double wordSize = 46;
  static const double wordLineHeight = 1.1;
  static const double wordSpacingFrom = 16;
  static const double wordSpacingTo = 1;

  static const double taglineTop = .67;
  static const double taglineSize = 13.5;

  static const double roadBottom = .14;
  static const double roadHeight = 56;
  static const double trailInset = .12;
  static const double trailHeight = 3;
  static const double scooterWidth = 78;

  /// CSS `perspective: 600px` for the 3D tilt.
  static const double perspective = 600;

  /// Text never grows past this on the splash, whatever the system setting.
  static const double maxTextScale = 1.2;
}
