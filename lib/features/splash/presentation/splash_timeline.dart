import 'dart:ui' show lerpDouble;

import 'package:flutter/animation.dart';

/// Which version of the launch animation plays.
enum SplashMode {
  /// The whole story (~5 s): first launch, or a new splash revision.
  full,

  /// Stripes → Z lands → zoom (~2 s), for people who have seen it.
  short,
}

/// When each part of the animation starts, in ms from the first frame.
/// The full timings are copied from `zyppi-splash-v3.html` (the approved
/// animation); the story-only parts (particles, tilt, text, scooter) use
/// the constants below and only play in [SplashMode.full].
class SplashTimeline {
  const SplashTimeline._({
    required this.totalMs,
    required this.stripeStart,
    required this.stripeStagger,
    required this.stripeDur,
    required this.auroraStart,
    required this.tileStart,
    required this.zLand,
    required this.exitStart,
    required this.story,
  });

  final int totalMs;
  final double stripeStart, stripeStagger, stripeDur;
  final double auroraStart;

  /// Full: the ball starts to drop. Short: the tile pops in.
  final double tileStart;

  /// The solid Z appears, the ring pulses and the sparks burst.
  final double zLand;

  /// Text fades and the tile zooms to fill the screen.
  final double exitStart;

  /// Particles, ground shadow, tilt, glass, wordmark, tagline, scooter.
  final bool story;

  static const full = SplashTimeline._(
    totalMs: 4950,
    stripeStart: 50,
    stripeStagger: 120,
    stripeDur: 550,
    auroraStart: 800,
    tileStart: 850,
    zLand: 2620,
    exitStart: 4350,
    story: true,
  );

  static const short = SplashTimeline._(
    totalMs: 2000,
    stripeStart: 0,
    stripeStagger: 60,
    stripeDur: 330,
    auroraStart: 300,
    tileStart: 250,
    zLand: 650,
    exitStart: 1400,
    story: false,
  );

  static SplashTimeline of(SplashMode mode) =>
      mode == SplashMode.full ? full : short;

  /// The exit zoom, in both modes.
  static const double exitDur = 600;

  /// The resting frame (tile, Z, wordmark, tagline) shown when animations
  /// are off.
  static const double restMs = 4300;

  // Story parts (full only).
  static const double dropDur = 1000;
  static const double particlesFrom = 1050, particlesTo = 2800;
  static const double sparksFrom = 2620, sparksDur = 700;
  static const double tiltStart = 2850, tiltDur = 1100;
  static const double glassStart = 3000, glassDur = 800;
  static const double wordStart = 2950, letterStagger = 60, letterDur = 700;
  static const double trackDur = 1000;
  static const double taglineStart = 3400, taglineDur = 600;
  static const double rideStart = 3450, rideDur = 1000;
  static const double fadeDur = 250;
}

/// The CSS curves of the approved animation.
abstract final class SplashCurves {
  static const sweep = Cubic(.7, 0, .2, 1);
  static const fall = Cubic(.5, 0, 1, .6);
  static const rebound = Cubic(0, .4, .5, 1);
  static const pop = Cubic(.2, 1.6, .4, 1);
  static const zIn = Cubic(.2, 1.5, .4, 1);
  static const tilt = Cubic(.4, 0, .2, 1);
  static const glass = Cubic(.5, 0, .3, 1);
  static const track = Cubic(.2, .8, .2, 1);
  static const rise = Cubic(.2, 1.2, .3, 1);
  static const unclip = Cubic(.6, 0, .2, 1);
  static const ride = Cubic(.5, 0, .4, 1);
  static const zoom = Cubic(.7, 0, .9, .4);
  static const ease = Cubic(.25, .1, .25, 1);
  static const easeOut = Cubic(0, 0, .58, 1);
  static const easeInOut = Cubic(.42, 0, .58, 1);
}

/// Progress of a segment that starts at [start] ms and lasts [dur] ms at
/// time [t], through [curve] (0 before, 1 after; may overshoot in between).
double seg(double t, double start, double dur, [Curve curve = Curves.linear]) {
  final x = ((t - start) / dur).clamp(0.0, 1.0);
  return curve.transform(x);
}

/// One CSS keyframe: [value] at [at] (0–1); [curve] eases the segment that
/// starts here, like `animation-timing-function` on a keyframe.
class Kf {
  const Kf(this.at, this.value, [this.curve = Curves.linear]);

  final double at;
  final double value;
  final Curve curve;
}

/// Value of a keyframe track at progress [p].
double keyframes(double p, List<Kf> ks) {
  if (p <= ks.first.at) return ks.first.value;
  for (var i = 0; i < ks.length - 1; i++) {
    final a = ks[i], b = ks[i + 1];
    if (p <= b.at) {
      final x = (p - a.at) / (b.at - a.at);
      return lerpDouble(a.value, b.value, a.curve.transform(x))!;
    }
  }
  return ks.last.value;
}
