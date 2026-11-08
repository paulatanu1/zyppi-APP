import 'dart:async';

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
/// pubspec.yaml) — so the hand-off is invisible. The mark then lifts while
/// the wordmark and tagline fade in, and the app moves on to Home (signed
/// in) or Onboarding. Bootstrap has already finished by now, so this adds
/// presentation time only, never waiting.
class LaunchScreen extends ConsumerStatefulWidget {
  const LaunchScreen({super.key});

  /// Logical width of the mark; the native splash images are cut to match.
  static const double markWidth = 120;

  static const Duration duration = Duration(milliseconds: 1100);

  /// How long the static frame stays up when animations are off.
  static const Duration reducedMotionHold = Duration(milliseconds: 300);

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
      _controller.value = 1;
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
    final z = context.z;
    final text = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    // Phases of the 1.1 s timeline.
    final lift = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 0.55, curve: ZMotion.emphasized),
    );
    final word = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.75, curve: ZMotion.standard),
    );
    final tagline = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.9, curve: ZMotion.standard),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: z.splashBg,
        // No SafeArea: the native splash centres on the whole window.
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, -ZSpace.x8 * lift.value),
                child: Transform.scale(
                  scale: 1 - .14 * lift.value,
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
              // Wordmark + tagline sit just under where the mark settles.
              Transform.translate(
                offset: const Offset(0, LaunchScreen.markWidth * .62),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Opacity(
                      opacity: word.value,
                      child: Transform.translate(
                        offset: Offset(0, ZSpace.x3 * (1 - word.value)),
                        child: Text(
                          'Zyppi',
                          style: text.displaySmall!.copyWith(color: z.ink),
                        ),
                      ),
                    ),
                    const SizedBox(height: ZSpace.x1),
                    Opacity(
                      opacity: tagline.value,
                      child: Text(
                        'launchTagline'.tr().toUpperCase(),
                        textAlign: TextAlign.center,
                        style: text.labelSmall!.copyWith(
                          color: z.logo,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
