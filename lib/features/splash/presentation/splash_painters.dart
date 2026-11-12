import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:zippy/features/splash/presentation/splash_palette.dart';
import 'package:zippy/features/splash/presentation/splash_timeline.dart';

/// Side of the Z's own coordinate space (`Z-ribbon.svg` viewBox).
const double zUnits = 328;

/// The Zyppi Z, from `Z-ribbon.svg`, in [zUnits] space.
final Path zPath = Path()
  ..moveTo(0, 9.00001)
  ..cubicTo(0, 4.02944, 4.02944, 0, 9, 0)
  ..lineTo(318.68, 0)
  ..cubicTo(323.651, 0, 327.68, 4.02944, 327.68, 9)
  ..lineTo(327.68, 97.1771)
  ..cubicTo(327.68, 100.407, 325.949, 103.389, 323.145, 104.991)
  ..lineTo(142.065, 208.466)
  ..cubicTo(134.052, 213.045, 137.301, 225.28, 146.53, 225.28)
  ..lineTo(318.68, 225.28)
  ..cubicTo(323.651, 225.28, 327.68, 229.309, 327.68, 234.28)
  ..lineTo(327.68, 318.68)
  ..cubicTo(327.68, 323.651, 323.651, 327.68, 318.68, 327.68)
  ..lineTo(9, 327.68)
  ..cubicTo(4.02944, 327.68, 0, 323.651, 0, 318.68)
  ..lineTo(0, 230.503)
  ..cubicTo(0, 227.273, 1.73057, 224.291, 4.53475, 222.689)
  ..lineTo(185.615, 119.214)
  ..cubicTo(193.628, 114.635, 190.379, 102.4, 181.15, 102.4)
  ..lineTo(8.99999, 102.4)
  ..cubicTo(4.02943, 102.4, 0, 98.3706, 0, 93.4)
  ..close();

/// The solid Z, scaled to fit its box.
class ZMarkPainter extends CustomPainter {
  const ZMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / zUnits, size.height / zUnits)
      ..drawPath(zPath, Paint()..color = SplashPalette.brand)
      ..restore();
  }

  @override
  bool shouldRepaint(ZMarkPainter oldDelegate) => false;
}

/// Images made once per splash: a soft glow dot for the particles and
/// sparks, and a tile of film grain.
class SplashTextures {
  SplashTextures._(this.glow, this.grain);

  /// Side of [glow]; its solid core has radius [glowCore].
  static const int glowSize = 32;
  static const double glowCore = 4;
  static const int _grainSize = 128;

  final ui.Image glow;
  final ui.Image grain;

  factory SplashTextures.create() {
    // Glow: a white dot (radius 4) with a soft halo, like the canvas
    // version's `shadowBlur`.
    var recorder = ui.PictureRecorder();
    const half = glowSize / 2;
    Canvas(recorder).drawCircle(
      const Offset(half, half),
      half,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(half, half),
          half,
          const [
            SplashPalette.white,
            SplashPalette.white,
            Color(0x73FFFFFF),
            SplashPalette.clearWhite,
          ],
          const [0, glowCore / half, .4, 1],
        ),
    );
    var picture = recorder.endRecording();
    final glow = picture.toImageSync(glowSize, glowSize);
    picture.dispose();

    // Grain: random grey pixels at 7% alpha (the spec's overlay opacity).
    recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final rnd = math.Random(3);
    const levels = 6;
    final buckets = List.generate(levels, (_) => <double>[]);
    for (var y = 0; y < _grainSize; y++) {
      for (var x = 0; x < _grainSize; x++) {
        buckets[rnd.nextInt(levels)].addAll([x + .5, y + .5]);
      }
    }
    for (var i = 0; i < levels; i++) {
      final grey = (255 * i / (levels - 1)).round();
      canvas.drawRawPoints(
        ui.PointMode.points,
        Float32List.fromList(buckets[i]),
        Paint()
          ..color = Color.fromARGB(18, grey, grey, grey)
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.square,
      );
    }
    picture = recorder.endRecording();
    final grain = picture.toImageSync(_grainSize, _grainSize);
    picture.dispose();

    return SplashTextures._(glow, grain);
  }

  void dispose() {
    glow.dispose();
    grain.dispose();
  }
}

/// Centre of the tile on a screen of [size].
Offset tileCentre(Size size) =>
    Offset(size.width / 2, size.height * SplashSpec.tileCentreY);

/// Stripes, aurora, grain, the ball's ground shadow and the pulse ring:
/// everything behind the tile.
class SplashBackdropPainter extends CustomPainter {
  SplashBackdropPainter({
    required this.t,
    required this.timeline,
    required this.textures,
    required this.showGroundShadow,
  });

  final double t;
  final SplashTimeline timeline;
  final SplashTextures textures;
  final bool showGroundShadow;

  @override
  void paint(Canvas canvas, Size size) {
    _stripes(canvas, size);
    _aurora(canvas, size);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ImageShader(
          textures.grain,
          TileMode.repeated,
          TileMode.repeated,
          Float64List.fromList(Matrix4.identity().storage),
        ),
      // Plain source-over, not the HTML's `overlay`: an advanced blend
      // makes Impeller read back the whole screen every frame, and at 7%
      // the grain looks the same.
    );
    if (showGroundShadow) _groundShadow(canvas, size);
    _pulse(canvas, size);
  }

  void _stripes(Canvas canvas, Size size) {
    final tl = timeline;
    final last = seg(
      t,
      tl.stripeStart + 3 * tl.stripeStagger,
      tl.stripeDur,
      SplashCurves.sweep,
    );
    if (last >= 1) {
      canvas.drawColor(SplashPalette.brand, BlendMode.src);
      return;
    }
    // A box 260% of the screen, rotated −30°; each layer slides in along
    // its own x axis.
    final w = size.width * 2.6, h = size.height * 2.6;
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..rotate(-math.pi / 6);
    for (var i = 0; i < 4; i++) {
      final p = seg(
        t,
        tl.stripeStart + i * tl.stripeStagger,
        tl.stripeDur,
        SplashCurves.sweep,
      );
      if (p <= 0) continue;
      canvas.drawRect(
        Rect.fromLTWH(-w / 2 - w * (1 - p), -h / 2, w, h),
        Paint()..color = SplashPalette.stripes[i],
      );
    }
    canvas.restore();
  }

  void _aurora(Canvas canvas, Size size) {
    final a = seg(t, timeline.auroraStart, 800, SplashCurves.ease);
    if (a <= 0) return;
    final s = math.max(0.0, (t - timeline.auroraStart) / 1000);
    final w = size.width, h = size.height;
    // Rects and drift from the HTML's `.aurora b` and `drift1/drift2`.
    _blob(
      canvas,
      Rect.fromLTWH(-.2 * w, -.05 * h, .7 * w, .4 * h),
      SplashPalette.aurora,
      a,
      _drift(s, 6),
      const Offset(.4, .25),
      1.2,
    );
    _blob(
      canvas,
      Rect.fromLTWH(.5 * w, .35 * h, .8 * w, .45 * h),
      SplashPalette.deep,
      a,
      _drift(s, 7),
      const Offset(-.35, -.2),
      .9,
    );
    _blob(
      canvas,
      Rect.fromLTWH(-.1 * w, .75 * h, .7 * w, .35 * h),
      SplashPalette.s2,
      a * .6,
      1 - _drift(s, 8), // alternate-reverse
      const Offset(.4, .25),
      1.2,
    );
  }

  /// Eased ping-pong of a `[period]s ease-in-out infinite alternate`.
  static double _drift(double seconds, double period) {
    final f = (seconds / period) % 2;
    return SplashCurves.easeInOut.transform(f <= 1 ? f : 2 - f);
  }

  /// A blurred ellipse (CSS `filter: blur(40px)`) as a radial gradient,
  /// which is far cheaper than a real blur and reads the same.
  void _blob(
    Canvas canvas,
    Rect rect,
    Color color,
    double opacity,
    double k,
    Offset move,
    double scaleTo,
  ) {
    const blur = 40.0;
    final scale = 1 + (scaleTo - 1) * k;
    final centre =
        rect.center +
        Offset(move.dx * rect.width * k, move.dy * rect.height * k);
    final rx = rect.width / 2 * scale, ry = rect.height / 2 * scale;
    final inner = ((math.min(rx, ry) - blur) / (math.min(rx, ry) + 2 * blur))
        .clamp(0.0, 1.0);
    final base = color.withValues(alpha: opacity);
    canvas
      ..save()
      ..translate(centre.dx, centre.dy)
      ..scale(rx + 2 * blur, ry + 2 * blur)
      ..drawCircle(
        Offset.zero,
        1,
        Paint()
          ..shader = ui.Gradient.radial(
            Offset.zero,
            1,
            [
              base,
              base,
              color.withValues(alpha: opacity * .5),
              color.withValues(alpha: 0),
            ],
            [0, inner, (inner + 1) / 2, 1],
          ),
      )
      ..restore();
  }

  void _groundShadow(Canvas canvas, Size size) {
    final p = (t - timeline.tileStart) / SplashTimeline.dropDur;
    final scale = keyframes(p, const [
      Kf(0, 0),
      Kf(.32, .5),
      Kf(.38, .6),
      Kf(.56, .25),
      Kf(.70, .5),
      Kf(1, 1.1),
    ]);
    final fade = 1 - seg(t, timeline.exitStart, 200, SplashCurves.ease);
    if (scale <= 0 || fade <= 0) return;
    final c = tileCentre(size) + const Offset(0, 76 + 7);
    const blur = 5.0;
    canvas
      ..save()
      ..translate(c.dx, c.dy)
      ..scale(scale * (45 + blur), scale * (7 + blur))
      ..drawCircle(
        Offset.zero,
        1,
        Paint()
          ..shader = ui.Gradient.radial(Offset.zero, 1, [
            SplashPalette.groundShadow.withValues(
              alpha: SplashPalette.groundShadow.a * fade,
            ),
            SplashPalette.groundShadow.withValues(alpha: 0),
          ]),
      )
      ..restore();
  }

  void _pulse(Canvas canvas, Size size) {
    if (t < timeline.zLand || t > timeline.zLand + 800) return;
    final p = seg(t, timeline.zLand, 800, SplashCurves.easeOut);
    final scale = 1 + .9 * p;
    final side = SplashSpec.tile * scale;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: tileCentre(size), width: side, height: side),
        Radius.circular(30 * scale),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * scale
        ..color = SplashPalette.softWhite.withValues(alpha: .9 * (1 - p)),
    );
  }

  @override
  bool shouldRepaint(SplashBackdropPainter old) =>
      old.t != t || old.timeline != timeline;
}

/// ~500 points sampled inside the Z, each with a random start, spin and
/// size (seeded, so every launch – and every test – is the same).
class SplashSwarm {
  SplashSwarm(this.size) {
    final rnd = math.Random(42);
    final centre = tileCentre(size);
    const inner = SplashSpec.tile - 2 * SplashSpec.zInset;
    const k = inner / zUnits;
    final far = math.max(size.width, size.height) * .55;
    final pts = _samples;
    n = pts.length;
    tx = Float64List(n);
    ty = Float64List(n);
    sx = Float64List(n);
    sy = Float64List(n);
    delay = Float64List(n);
    spin = Float64List(n);
    r = Float64List(n);
    tw = Float64List(n);
    for (var i = 0; i < n; i++) {
      tx[i] = centre.dx - inner / 2 + pts[i].dx * k;
      ty[i] = centre.dy - inner / 2 + pts[i].dy * k;
      final a = rnd.nextDouble() * math.pi * 2;
      final d = 140 + rnd.nextDouble() * far;
      sx[i] = centre.dx + math.cos(a) * d;
      sy[i] = centre.dy + math.sin(a) * d;
      delay[i] = rnd.nextDouble() * .35;
      spin[i] = (rnd.nextBool() ? -1 : 1) * (1.2 + rnd.nextDouble() * 1.4);
      r[i] = .9 + rnd.nextDouble() * 1.3;
      tw[i] = rnd.nextDouble() * 6;
    }
    sparkAngle = Float64List(_sparks);
    sparkSpeed = Float64List(_sparks);
    sparkR = Float64List(_sparks);
    for (var i = 0; i < _sparks; i++) {
      sparkAngle[i] = i / _sparks * math.pi * 2 + rnd.nextDouble() * .2;
      sparkSpeed[i] = 70 + rnd.nextDouble() * 90;
      sparkR[i] = 1.2 + rnd.nextDouble() * 1.8;
    }
    final most = math.max(n, _sparks);
    transforms = Float32List(most * 4);
    rects = Float32List(most * 4);
    for (var i = 0; i < most; i++) {
      rects[i * 4 + 2] = SplashTextures.glowSize.toDouble();
      rects[i * 4 + 3] = SplashTextures.glowSize.toDouble();
    }
    colors = Int32List(most);
  }

  static const _sparks = 22;

  /// Grid points inside the Z (11-unit grid, as in the HTML).
  static final List<Offset> _samples = [
    for (var y = 4.0; y < zUnits; y += 11)
      for (var x = 4.0; x < zUnits; x += 11)
        if (zPath.contains(Offset(x, y))) Offset(x, y),
  ];

  final Size size;
  late final int n;
  late final Float64List tx, ty, sx, sy, delay, spin, r, tw;
  late final Float64List sparkAngle, sparkSpeed, sparkR;

  // Reused draw buffers.
  late final Float32List transforms, rects;
  late final Int32List colors;
}

/// The particle swarm that forms the Z, then the sparks when it lands
/// (`frame()` in the HTML). One `drawRawAtlas` call per effect per frame.
class SplashSwarmPainter extends CustomPainter {
  SplashSwarmPainter({
    required this.t,
    required this.swarm,
    required this.textures,
  });

  final double t;
  final SplashSwarm swarm;
  final SplashTextures textures;

  static const _a = 1.35, _b = 2.65;

  @override
  void paint(Canvas canvas, Size size) {
    final s = t / 1000;
    if (s > _a - .3 && s < _b + .15) _particles(canvas, s);
    if (s > SplashTimeline.sparksFrom / 1000 &&
        s < (SplashTimeline.sparksFrom + SplashTimeline.sparksDur) / 1000) {
      _sparkBurst(canvas, size, s);
    }
  }

  void _particles(Canvas canvas, double s) {
    final sw = swarm;
    final fadeIn = math.min(1.0, (s - (_a - .3)) / .3);
    final fadeOut = s > _b ? math.max(0.0, 1 - (s - _b) / .15) : 1.0;
    for (var i = 0; i < sw.n; i++) {
      final q = ((s - _a - sw.delay[i] * .9) / (_b - _a - .35)).clamp(0.0, 1.0);
      final e = q < .5 ? 4 * q * q * q : 1 - math.pow(-2 * q + 2, 3) / 2;
      final dx = sw.sx[i] - sw.tx[i], dy = sw.sy[i] - sw.ty[i];
      final ang = (1 - e) * sw.spin[i], k = 1 - e;
      final cosA = math.cos(ang), sinA = math.sin(ang);
      final x = sw.tx[i] + (dx * cosA - dy * sinA) * k;
      final y = sw.ty[i] + (dx * sinA + dy * cosA) * k;
      // White glow → brand purple as it lands.
      final c = ((e - .55) / .45).clamp(0.0, 1.0);
      final alpha =
          fadeIn * fadeOut * (.65 + .35 * math.sin(s * 12 + sw.tw[i]));
      _put(
        i,
        x,
        y,
        sw.r[i] * (1 - .35 * e),
        _argb(
          alpha,
          255 + (103 - 255) * c,
          255 + (58 - 255) * c,
          255 + (183 - 255) * c,
        ),
      );
    }
    _draw(canvas, sw.n);
  }

  void _sparkBurst(Canvas canvas, Size size, double s) {
    final sw = swarm;
    final q =
        (s - SplashTimeline.sparksFrom / 1000) /
        (SplashTimeline.sparksDur / 1000);
    final e = 1 - math.pow(1 - q, 3);
    final c = tileCentre(size);
    final n = sw.sparkAngle.length;
    for (var i = 0; i < n; i++) {
      final d = 60 + sw.sparkSpeed[i] * e;
      _put(
        i,
        c.dx + math.cos(sw.sparkAngle[i]) * d,
        c.dy + math.sin(sw.sparkAngle[i]) * d,
        sw.sparkR[i] * (1 - q * .5),
        _argb(1 - q, 255, 255, 255),
      );
    }
    _draw(canvas, n);
  }

  /// Places glow sprite [i] so its core (radius [radius]) sits at x, y.
  void _put(int i, double x, double y, double radius, int argb) {
    final scale = radius / SplashTextures.glowCore;
    const half = SplashTextures.glowSize / 2;
    final t4 = swarm.transforms;
    t4[i * 4] = scale;
    t4[i * 4 + 1] = 0;
    t4[i * 4 + 2] = x - half * scale;
    t4[i * 4 + 3] = y - half * scale;
    swarm.colors[i] = argb;
  }

  void _draw(Canvas canvas, int count) {
    canvas.drawRawAtlas(
      textures.glow,
      Float32List.sublistView(swarm.transforms, 0, count * 4),
      Float32List.sublistView(swarm.rects, 0, count * 4),
      Int32List.sublistView(swarm.colors, 0, count),
      BlendMode.modulate,
      null,
      Paint()..filterQuality = FilterQuality.low,
    );
  }

  static int _argb(double a, double r, double g, double b) =>
      ((a.clamp(0.0, 1.0) * 255).round() << 24) |
      (r.round() << 16) |
      (g.round() << 8) |
      b.round();

  @override
  bool shouldRepaint(SplashSwarmPainter old) => old.t != t;
}

/// The trail (a loading bar) and the scooter with its speed lines, in a
/// full-width box [SplashSpec.roadHeight] tall.
class SplashRoadPainter extends CustomPainter {
  SplashRoadPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final p = (t - SplashTimeline.rideStart) / SplashTimeline.rideDur;
    if (p <= 0) return;
    final w = size.width;

    // Trail: fills from the left like a loading bar.
    final fill = keyframes(p, const [
      Kf(0, 0, SplashCurves.ride),
      Kf(.7, 1),
      Kf(1, 1),
    ]);
    final left = w * SplashSpec.trailInset;
    final trailW = w * (1 - 2 * SplashSpec.trailInset);
    final top = size.height - 4 - SplashSpec.trailHeight;
    if (fill > 0) {
      canvas
        ..save()
        ..translate(left, 0)
        ..scale(fill, 1)
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, top, trailW, SplashSpec.trailHeight),
            const Radius.circular(SplashSpec.trailHeight),
          ),
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(0, top),
              Offset(trailW, top),
              [
                SplashPalette.s2.withValues(alpha: 0),
                SplashPalette.s2,
                SplashPalette.white,
              ],
              const [0, .3, 1],
            ),
        )
        ..restore();
    }

    // Scooter: rides in, pauses near the end of the trail, leaves right.
    final x = keyframes(p, [
      const Kf(0, -100, SplashCurves.ride),
      Kf(.7, w * .82 - SplashSpec.scooterWidth, SplashCurves.ride),
      Kf(1, w + 40),
    ]);
    final rot = keyframes(p, const [
      Kf(0, 0, SplashCurves.ride),
      Kf(.7, -4, SplashCurves.ride),
      Kf(1, 0),
    ]);
    const sw = SplashSpec.scooterWidth;
    const sh = sw * 44 / 64;
    final sTop = size.height - 2 - sh;
    canvas
      ..save()
      ..translate(x + sw / 2, sTop + sh / 2)
      ..rotate(rot * math.pi / 180)
      ..translate(-sw / 2, -sh / 2);

    final line = Paint()..color = SplashPalette.softWhite;
    for (final (y, from) in const [(19.0, 0.0), (26.0, 9.0), (33.0, 16.5)]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-30 + from, y, 30 - from, 2),
          const Radius.circular(2),
        ),
        line,
      );
    }

    canvas.scale(sw / 64);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = SplashPalette.white;
    final box = RRect.fromRectAndRadius(
      const Rect.fromLTWH(8, 6, 18, 15),
      const Radius.circular(3),
    );
    canvas
      ..drawRRect(box, Paint()..color = SplashPalette.white)
      ..drawRRect(box, stroke)
      ..drawLine(
        const Offset(13, 13.5),
        const Offset(21, 13.5),
        Paint()
          ..color = SplashPalette.brand
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round,
      )
      ..drawPath(
        Path()
          ..moveTo(6, 34)
          ..lineTo(28, 34)
          ..lineTo(34, 22)
          ..lineTo(44, 22)
          ..lineTo(50, 34),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(44, 22)
          ..lineTo(40, 8)
          ..lineTo(47, 8),
        stroke,
      );
    final wheel = Paint()..color = SplashPalette.deep;
    for (final c in const [Offset(13, 35), Offset(51, 35)]) {
      canvas
        ..drawCircle(c, 6, wheel)
        ..drawCircle(c, 6, stroke);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(SplashRoadPainter old) => old.t != t;
}
