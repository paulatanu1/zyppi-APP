import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// First Flutter frame after the native splash. It starts as an exact copy
/// of that splash — the Z mark, [markWidth] wide, centred on the whole
/// window over [ZColors.splashBg] (see `flutter_native_splash` in
/// pubspec.yaml) — so the hand-off is invisible. Then, on one timeline:
/// a glow blooms behind the mark as it pops, speed streaks "zip" past it,
/// the mark lifts while "Zyppi" rises in letter by letter, the tagline
/// fades in with a single shimmer pass, grocery icons drift in around the
/// edges, and everything zooms gently away into Home (signed in) or
/// Onboarding. Bootstrap has already finished by now, so this adds
/// presentation time only, never waiting.
class LaunchScreen extends ConsumerStatefulWidget {
  const LaunchScreen({super.key});

  /// Logical width of the mark; the native splash images are cut to match.
  static const double markWidth = 120;

  static const Duration duration = Duration(milliseconds: 1600);

  /// How long the static frame stays up when animations are off.
  static const Duration reducedMotionHold = Duration(milliseconds: 300);

  /// Timeline value at which everything is in its resting pose (before the
  /// exit zoom). Reduced motion jumps straight here.
  static const double restPose = .88;

  @override
  ConsumerState<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends ConsumerState<LaunchScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: LaunchScreen.duration,
  );
  Timer? _hold;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = LaunchScreen.restPose;
      _hold = Timer(LaunchScreen.reducedMotionHold, _next);
    } else {
      _controller.forward().whenComplete(_next);
    }
  }

  void _next() {
    if (!mounted) return;
    final token = ref.read(sharedPreferenceProvider).authToken;
    context.go(token != null && token.isNotEmpty ? '/navBar' : '/slider');
  }

  @override
  void dispose() {
    _hold?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Follow the phone's theme, not the in-app Light/Dark choice: Android
    // draws the native splash from the system setting before the app can
    // read its own, so matching it here avoids a light/dark flash. The fade
    // into Home/Onboarding then blends into the app's chosen theme.
    final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final z = dark ? ZColors.dark : ZColors.light;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: z.splashBg,
        // No SafeArea: the native splash centres on the whole window.
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => _LaunchFrame(t: _controller.value, z: z),
        ),
      ),
    );
  }
}

/// 0…1 progress of [t] through the window [begin, end], eased by [curve].
double _phase(
  double t,
  double begin,
  double end, [
  Curve curve = ZMotion.standard,
]) => curve.transform(((t - begin) / (end - begin)).clamp(0.0, 1.0));

/// One frame of the launch timeline at progress [t].
class _LaunchFrame extends StatelessWidget {
  const _LaunchFrame({required this.t, required this.z});

  final double t;
  final ZColors z;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final glow = _phase(t, 0, .35, ZMotion.emphasized);
    // Quick pop (1 → 1.08 → 1) that starts from rest, so frame 0 still
    // matches the native splash exactly.
    final pop = math.sin(math.pi * _phase(t, 0, .26, Curves.easeOut));
    final lift = _phase(t, .2, .62, ZMotion.emphasized);
    final streaks = ((t - .1) / .4).clamp(0.0, 1.0);
    final tagline = _phase(t, .56, .8);
    final shimmer = ((t - .62) / .26).clamp(0.0, 1.0);
    final icons = _phase(t, .3, .8, ZMotion.emphasized);
    final exit = _phase(t, .9, 1, Curves.easeIn);

    final markDy = -ZSpace.x8 * lift;

    return Opacity(
      opacity: 1 - exit,
      child: Transform.scale(
        scale: 1 + .06 * exit,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Soft bloom behind the mark.
            Center(
              child: Transform.translate(
                offset: Offset(0, markDy),
                child: Transform.scale(
                  scale: .4 + .6 * glow,
                  child: Container(
                    width: LaunchScreen.markWidth * 3.2,
                    height: LaunchScreen.markWidth * 3.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          z.logo.withValues(alpha: .28 * glow),
                          z.logo.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _DriftingIcons(t: icons, color: z.logo),
            if (streaks > 0 && streaks < 1)
              RepaintBoundary(
                child: CustomPaint(
                  painter: _StreaksPainter(
                    t: streaks,
                    color: z.logo,
                    centerDy: markDy,
                  ),
                ),
              ),
            Center(
              child: Transform.translate(
                offset: Offset(0, markDy),
                child: Transform.scale(
                  scale: 1 + .08 * pop - .14 * lift,
                  child: Semantics(
                    label: 'Zyppi',
                    image: true,
                    child: Image.asset(
                      'assets/brand/zyppi_mark.png',
                      width: LaunchScreen.markWidth,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
              ),
            ),
            // Wordmark + tagline sit just under where the mark settles.
            Center(
              child: Transform.translate(
                offset: const Offset(0, LaunchScreen.markWidth * .66),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Wordmark(
                      t: t,
                      style: text.displaySmall!.copyWith(color: z.ink),
                    ),
                    const SizedBox(height: ZSpace.x1),
                    Opacity(
                      opacity: tagline,
                      child: Transform.translate(
                        offset: Offset(0, ZSpace.x2 * (1 - tagline)),
                        child: _Shimmer(
                          t: shimmer,
                          base: z.logo,
                          highlight: z.ink,
                          child: Text(
                            'launchTagline'.tr().toUpperCase(),
                            textAlign: TextAlign.center,
                            style: text.labelSmall!.copyWith(
                              color: z.logo,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Zyppi", each letter rising and fading in a beat after the last.
class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.t, required this.style});

  static const word = 'Zyppi';

  final double t;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: word,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < word.length; i++)
            _Letter(
              letter: word[i],
              p: _phase(t, .32 + i * .04, .6 + i * .04, ZMotion.emphasized),
              style: style,
            ),
        ],
      ),
    );
  }
}

class _Letter extends StatelessWidget {
  const _Letter({required this.letter, required this.p, required this.style});

  final String letter;
  final double p;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: p,
    child: Transform.translate(
      offset: Offset(0, ZSpace.x4 * (1 - p)),
      child: Text(letter, style: style),
    ),
  );
}

/// One highlight sweep across [child] while 0 < [t] < 1; plain otherwise.
class _Shimmer extends StatelessWidget {
  const _Shimmer({
    required this.t,
    required this.base,
    required this.highlight,
    required this.child,
  });

  final double t;
  final Color base, highlight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (t <= 0 || t >= 1) return child;
    final x = -1.5 + 3 * Curves.easeInOut.transform(t);
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment(x - .5, 0),
        end: Alignment(x + .5, 0),
        colors: [base, highlight, base],
      ).createShader(bounds),
      child: child,
    );
  }
}

/// Grocery icons floating in around the edges, each a little later than
/// the one before.
class _DriftingIcons extends StatelessWidget {
  const _DriftingIcons({required this.t, required this.color});

  final double t;
  final Color color;

  // (icon, position, size, starting tilt in degrees)
  static const _icons = [
    (Icons.eco_rounded, Alignment(-.72, -.62), 30.0, -12.0),
    (Icons.egg_rounded, Alignment(.74, -.48), 26.0, 10.0),
    (Icons.local_drink_rounded, Alignment(-.8, .42), 28.0, 8.0),
    (Icons.bakery_dining_rounded, Alignment(.7, .58), 32.0, -10.0),
    (Icons.shopping_basket_rounded, Alignment(-.18, .8), 26.0, 6.0),
  ];

  @override
  Widget build(BuildContext context) {
    if (t == 0) return const SizedBox.shrink();
    return ExcludeSemantics(
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (var i = 0; i < _icons.length; i++)
            _drifting(i, ((t - i * .1) / (1 - i * .1)).clamp(0.0, 1.0)),
        ],
      ),
    );
  }

  Widget _drifting(int i, double p) {
    final (icon, align, size, tilt) = _icons[i];
    return Align(
      alignment: align,
      child: Opacity(
        opacity: .5 * p,
        child: Transform.translate(
          offset: Offset(0, ZSpace.x6 * (1 - p)),
          child: Transform.rotate(
            angle: tilt * (1 - p) * math.pi / 180,
            child: Icon(icon, size: size, color: color),
          ),
        ),
      ),
    );
  }
}

/// Three rounded speed lines sweeping left → right through the mark.
class _StreaksPainter extends CustomPainter {
  _StreaksPainter({
    required this.t,
    required this.color,
    required this.centerDy,
  });

  final double t;
  final Color color;
  final double centerDy;

  // (vertical offset from the mark's centre, length, start delay)
  static const _lanes = [
    (-26.0, 90.0, 0.0),
    (0.0, 140.0, .08),
    (26.0, 70.0, .16),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2 + centerDy;
    for (final (dy, length, delay) in _lanes) {
      final p = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (p <= 0 || p >= 1) continue;
      final head =
          -length +
          (size.width + 2 * length) * Curves.easeOutCubic.transform(p);
      final paint = Paint()
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            color.withValues(alpha: 0),
            color.withValues(alpha: .55 * math.sin(math.pi * p)),
          ],
        ).createShader(Rect.fromLTWH(head - length, 0, length, 1));
      canvas.drawLine(
        Offset(head - length, cy + dy),
        Offset(head, cy + dy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StreaksPainter old) =>
      old.t != t || old.color != color || old.centerDy != centerDy;
}
