import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/splash/presentation/splash_painters.dart';
import 'package:zippy/features/splash/presentation/splash_palette.dart';
import 'package:zippy/features/splash/presentation/splash_timeline.dart';

/// The `/launch` route: plays the full splash (every launch; tap skips),
/// then goes to Home (signed in) or Onboarding. Bootstrap has
/// finished before this shows, so the splash is presentation only.
class SplashRoute extends ConsumerStatefulWidget {
  const SplashRoute({super.key});

  @override
  ConsumerState<SplashRoute> createState() => _SplashRouteState();
}

class _SplashRouteState extends ConsumerState<SplashRoute> {
  // The full animation plays on every launch (tap anywhere skips it).
  final SplashMode _mode = SplashMode.full;

  void _next() {
    if (!mounted) return;
    final token = ref.read(sharedPreferenceProvider).authToken;
    context.go(token != null && token.isNotEmpty ? '/navBar' : '/slider');
  }

  @override
  Widget build(BuildContext context) =>
      ZyppiSplashScreen(mode: _mode, onFinished: _next);
}

/// The "Zyppi Pop" launch animation (`zyppi-splash-v3.html`): stripes
/// sweep in, a ball drops and becomes the app tile, particles swarm into
/// the Z, the tile tilts, the wordmark and tagline appear, a scooter
/// rides by, and the tile zooms to fill the screen. Tap anywhere to skip.
///
/// One [AnimationController] drives everything; [onFinished] fires once,
/// when it completes (or right after a skip during the zoom).
class ZyppiSplashScreen extends StatefulWidget {
  const ZyppiSplashScreen({
    super.key,
    required this.onFinished,
    this.mode = SplashMode.full,
  });

  final VoidCallback onFinished;
  final SplashMode mode;

  /// How long the resting frame stays up when animations are off.
  static const Duration reducedMotionHold = Duration(milliseconds: 300);

  static Duration durationOf(SplashMode mode) =>
      Duration(milliseconds: SplashTimeline.of(mode).totalMs);

  /// The wordmark's [Opacity] (for tests).
  static const wordmarkKey = ValueKey('splash-wordmark');

  @override
  State<ZyppiSplashScreen> createState() => _ZyppiSplashScreenState();
}

class _ZyppiSplashScreenState extends State<ZyppiSplashScreen>
    with SingleTickerProviderStateMixin {
  late final SplashTimeline _timeline = SplashTimeline.of(widget.mode);
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _timeline.totalMs),
  )..addStatusListener(_onStatus);
  final SplashTextures _textures = SplashTextures.create();
  SplashSwarm? _swarm;
  Timer? _hold;
  bool _started = false, _reduced = false, _done = false;

  /// Where the timeline was when the person tapped to skip.
  double? _skippedAt;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduced) {
      _hold = Timer(ZyppiSplashScreen.reducedMotionHold, _finish);
    } else {
      _controller.forward();
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _finish();
  }

  void _finish() {
    if (_done || !mounted) return;
    _done = true;
    widget.onFinished();
  }

  void _skip() {
    if (_reduced || _done) return;
    final t = _controller.value * _timeline.totalMs;
    if (t >= _timeline.exitStart) return _finish();
    _skippedAt = t;
    _controller.forward(from: _timeline.exitStart / _timeline.totalMs);
  }

  @override
  void dispose() {
    _hold?.cancel();
    _controller.dispose();
    _textures.dispose();
    super.dispose();
  }

  /// True when [start] had been reached before a skip (so the part was on
  /// screen and may fade out), or there was no skip.
  bool _shown(double start) => _skippedAt == null || _skippedAt! >= start;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: SplashSpec.maxTextScale,
      child: Scaffold(
        backgroundColor: context.z.splashBg,
        // No SafeArea: the composition is laid out on the whole window.
        // One node for screen readers: the brand, the tagline, and a tap
        // that skips.
        body: Semantics(
          container: true,
          label: 'Zyppi',
          hint: 'launchTagline'.tr(),
          onTap: _skip,
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _skip,
              child: LayoutBuilder(
                builder: (context, constraints) => AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => _frame(context, constraints.biggest),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _frame(BuildContext context, Size size) {
    final tl = _reduced ? SplashTimeline.full : _timeline;
    final t = _reduced
        ? SplashTimeline.restMs
        : _controller.value * _timeline.totalMs;
    final story = tl.story;
    final fade = 1 - seg(t, tl.exitStart, SplashTimeline.fadeDur);
    final centre = tileCentre(size, tl.tileY);

    final swarm = story && !_reduced
        ? (_swarm?.size == size ? _swarm! : _swarm = SplashSwarm(size))
        : null;

    // Purple from the first frame: light status-bar icons throughout.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: SplashBackdropPainter(
                t: t,
                timeline: tl,
                textures: _textures,
                showGroundShadow: story,
              ),
            ),
          ),
          // Full version: the native launch screen's tile becomes the
          // ball: its Z fades, it rounds and shrinks to ball size, then
          // jumps up off the screen; the story drops it back down.
          if (story && !_reduced && t < SplashTimeline.handoffDur)
            _handoff(size, t),
          Positioned(
            left: centre.dx - SplashSpec.tile / 2,
            top: centre.dy - SplashSpec.tile / 2,
            width: SplashSpec.tile,
            height: SplashSpec.tile,
            child: _tile(context, t, tl),
          ),
          if (swarm != null)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: SplashSwarmPainter(
                    t: t,
                    swarm: swarm,
                    textures: _textures,
                  ),
                ),
              ),
            ),
          if (story && _shown(SplashTimeline.wordStart)) ...[
            Positioned(
              top: size.height * SplashSpec.wordTop,
              left: 0,
              right: 0,
              child: Opacity(
                key: ZyppiSplashScreen.wordmarkKey,
                opacity: fade,
                child: _wordmark(t),
              ),
            ),
            Positioned(
              top: size.height * SplashSpec.taglineTop,
              left: ZSpace.x4,
              right: ZSpace.x4,
              child: Opacity(opacity: fade, child: _tagline(t)),
            ),
          ],
          if (story && !_reduced && _shown(SplashTimeline.rideStart))
            Positioned(
              left: 0,
              right: 0,
              bottom: size.height * SplashSpec.roadBottom,
              height: SplashSpec.roadHeight,
              child: Opacity(
                opacity: fade,
                child: CustomPaint(painter: SplashRoadPainter(t: t)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _handoff(Size size, double t) {
    final shrink = seg(t, 0, 320, SplashCurves.easeInOut);
    final jump = seg(
      t,
      380,
      SplashTimeline.handoffDur - 380,
      SplashCurves.fall,
    );
    final scale = 1 - (1 - .32) * shrink;
    final radius =
        SplashSpec.tileRadius +
        (SplashSpec.ballRadius - SplashSpec.tileRadius) * shrink;
    // From the screen centre to just above the top edge.
    final dy = -(size.height / 2 + SplashSpec.tile) * jump;
    return Positioned(
      left: size.width / 2 - SplashSpec.tile / 2,
      top: size.height / 2 - SplashSpec.tile / 2,
      width: SplashSpec.tile,
      height: SplashSpec.tile,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Transform.scale(
          scale: scale,
          child: _TileFace(radius: radius, zOpacity: 1 - seg(t, 0, 220)),
        ),
      ),
    );
  }

  /// Ball → tile, 3D tilt, glass shine, solid Z, and the exit zoom.
  Widget _tile(BuildContext context, double t, SplashTimeline tl) {
    double ty = 0, sx, sy, radius, opacity = 1;
    final zoom = seg(
      t,
      tl.exitStart,
      SplashTimeline.exitDur,
      SplashCurves.zoom,
    );
    if (t >= tl.exitStart) {
      sx = sy = 1 + 13 * zoom;
      radius = SplashSpec.tileRadius * (1 - zoom);
    } else if (tl.story) {
      // `@keyframes drop`: fall, squash, bounce, settle, grow.
      final p = (t - tl.tileStart) / SplashTimeline.dropDur;
      ty = keyframes(p, const [
        Kf(0, -480, SplashCurves.fall),
        Kf(.32, 40),
        Kf(.38, 52, SplashCurves.rebound),
        Kf(.56, -40, SplashCurves.fall),
        Kf(.70, 0),
        Kf(1, 0),
      ]);
      sx = keyframes(p, const [
        Kf(0, .32, SplashCurves.fall),
        Kf(.32, .32),
        Kf(.38, .42, SplashCurves.rebound),
        Kf(.56, .3, SplashCurves.fall),
        Kf(.70, .34),
        Kf(1, 1),
      ]);
      sy = keyframes(p, const [
        Kf(0, .32, SplashCurves.fall),
        Kf(.32, .32),
        Kf(.38, .22, SplashCurves.rebound),
        Kf(.56, .36, SplashCurves.fall),
        Kf(.70, .3),
        Kf(1, 1),
      ]);
      radius = keyframes(p, const [
        Kf(.70, SplashSpec.ballRadius),
        Kf(1, SplashSpec.tileRadius),
      ]);
    } else {
      // Short: the tile pops in, already a tile.
      final p = seg(t, tl.tileStart, 450, SplashCurves.pop);
      sx = sy = .3 + .7 * p;
      radius =
          SplashSpec.ballRadius -
          (SplashSpec.ballRadius - SplashSpec.tileRadius) * p.clamp(0.0, 1.0);
      opacity = seg(t, tl.tileStart, 100);
    }
    if (opacity <= 0) return const SizedBox.shrink();

    // Hand off to the app's own background as the tile fills the screen.
    final bg = context.z.bg;
    final top = Color.lerp(SplashPalette.white, bg, zoom)!;
    final bottom = Color.lerp(SplashPalette.tileEnd, bg, zoom)!;

    final zIn = seg(t, tl.zLand, 450, SplashCurves.zIn);
    final glass = tl.story
        ? seg(
            t,
            SplashTimeline.glassStart,
            SplashTimeline.glassDur,
            SplashCurves.glass,
          )
        : 0.0;

    Widget tile = Transform(
      alignment: Alignment.center,
      transform: Matrix4.translationValues(0, ty, 0)
        ..scaleByDouble(sx, sy, 1, 1),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: const Alignment(-.57, -.82),
            end: const Alignment(.57, .82),
            colors: [top, bottom],
          ),
          border: Border.all(
            color: Color.lerp(SplashPalette.tileEdge, bg, zoom)!,
          ),
          boxShadow: const [
            BoxShadow(
              color: SplashPalette.tileShadow,
              offset: Offset(0, 20),
              blurRadius: 50,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            children: [
              if (zIn > 0)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(SplashSpec.zInset),
                    child: Opacity(
                      opacity: zIn.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: 1.25 - .25 * zIn,
                        child: const CustomPaint(painter: ZMarkPainter()),
                      ),
                    ),
                  ),
                ),
              if (glass > 0 && glass < 1)
                Positioned(
                  left: -.2 * SplashSpec.tile,
                  top: -.2 * SplashSpec.tile,
                  width: 1.4 * SplashSpec.tile,
                  height: 1.4 * SplashSpec.tile,
                  child: Transform.translate(
                    offset: Offset(
                      (-1.2 + 2.4 * glass) * 1.4 * SplashSpec.tile,
                      0,
                    ),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(-.906, -.423),
                          end: Alignment(.906, .423),
                          colors: [
                            SplashPalette.clearWhite,
                            SplashPalette.glass,
                            SplashPalette.clearWhite,
                          ],
                          stops: [.35, .5, .65],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (tl.story && !_reduced) {
      // `@keyframes tilt3d`, with real perspective.
      final p = (t - SplashTimeline.tiltStart) / SplashTimeline.tiltDur;
      if (p > 0 && p < 1) {
        final ry = keyframes(p, const [
          Kf(0, 0, SplashCurves.tilt),
          Kf(.35, -24, SplashCurves.tilt),
          Kf(.7, 14, SplashCurves.tilt),
          Kf(1, 0),
        ]);
        final rx = keyframes(p, const [
          Kf(0, 0, SplashCurves.tilt),
          Kf(.35, 12, SplashCurves.tilt),
          Kf(.7, -6, SplashCurves.tilt),
          Kf(1, 0),
        ]);
        tile = Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 1 / SplashSpec.perspective)
            ..rotateY(ry * math.pi / 180)
            ..rotateX(rx * math.pi / 180),
          child: tile,
        );
      }
    }

    return Opacity(opacity: opacity, child: tile);
  }

  /// "Zyppi": letters rise from behind a mask while the spacing tightens.
  Widget _wordmark(double t) {
    final spacing =
        SplashSpec.wordSpacingFrom +
        (SplashSpec.wordSpacingTo - SplashSpec.wordSpacingFrom) *
            seg(
              t,
              SplashTimeline.wordStart,
              SplashTimeline.trackDur,
              SplashCurves.track,
            );
    final style = TextStyle(
      fontFamily: ZFonts.display,
      fontFamilyFallback: ZFonts.fallback,
      fontWeight: FontWeight.w800,
      fontVariations: const [FontVariation.weight(800)],
      fontSize: SplashSpec.wordSize,
      height: SplashSpec.wordLineHeight,
      letterSpacing: spacing,
      color: SplashPalette.white,
    );
    const lineH = SplashSpec.wordSize * SplashSpec.wordLineHeight;
    const word = 'Zyppi';
    return ClipRect(
      child: Padding(
        padding: const EdgeInsets.only(top: ZSpace.x1, bottom: ZSpace.x2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < word.length; i++)
              Builder(
                builder: (_) {
                  final p = seg(
                    t,
                    SplashTimeline.wordStart + i * SplashTimeline.letterStagger,
                    SplashTimeline.letterDur,
                    SplashCurves.rise,
                  );
                  return Opacity(
                    opacity: p.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, 1.15 * lineH * (1 - p)),
                      child: Transform.rotate(
                        angle: 12 * math.pi / 180 * (1 - p),
                        child: Text(word[i], style: style),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// The tagline opens from the centre outwards.
  Widget _tagline(double t) {
    final p = seg(
      t,
      SplashTimeline.taglineStart,
      SplashTimeline.taglineDur,
      SplashCurves.unclip,
    );
    return ClipRect(
      clipper: _CentreClip(p),
      child: Text(
        'launchTagline'.tr(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: ZFonts.display,
          fontFamilyFallback: ZFonts.fallback,
          fontWeight: FontWeight.w500,
          fontVariations: [FontVariation.weight(500)],
          fontSize: SplashSpec.taglineSize,
          color: SplashPalette.tagline,
        ),
      ),
    );
  }
}

/// CSS `clip-path: inset(0 x 0 x)` opening from the middle: [open] 0 shows
/// nothing, 1 shows everything.
class _CentreClip extends CustomClipper<Rect> {
  const _CentreClip(this.open);

  final double open;

  @override
  Rect getClip(Size size) {
    final half = size.width / 2 * open.clamp(0.0, 1.0);
    return Rect.fromLTRB(
      size.width / 2 - half,
      0,
      size.width / 2 + half,
      size.height,
    );
  }

  @override
  bool shouldReclip(_CentreClip old) => old.open != open;
}

/// The resting tile (white gradient, purple Z): the same face the native
/// launch screen shows.
class _TileFace extends StatelessWidget {
  const _TileFace({this.radius = SplashSpec.tileRadius, this.zOpacity = 1});

  final double radius;
  final double zOpacity;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: ZRadius.all(radius),
      gradient: const LinearGradient(
        begin: Alignment(-.57, -.82),
        end: Alignment(.57, .82),
        colors: [SplashPalette.white, SplashPalette.tileEnd],
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(SplashSpec.zInset),
      child: Opacity(
        opacity: zOpacity,
        child: const CustomPaint(painter: ZMarkPainter()),
      ),
    ),
  );
}
