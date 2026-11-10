import 'package:flutter/material.dart';

import '../theme/zyppi_theme.dart';

bool _reduceMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context);

/// Fade + 14px slide-up entrance. `index` staggers siblings by 60 ms
/// (mockup class `.in` with `--i`), on the one controller (no timers).
///
/// In lazily built lists/grids pass [once]: an id unique to that item on
/// that screen instance, e.g. `(identityHashCode(context), index)`. The
/// item then animates only the first time it's built, not again each time
/// it scrolls back into view.
class ZEntrance extends StatefulWidget {
  const ZEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 14,
    this.once,
  });

  final Widget child;
  final int index;
  final double offset;
  final Object? once;

  /// Stagger stops growing after this many items, so item 30 of a list
  /// doesn't wait two seconds.
  static const int maxStagger = 8;

  static final _played = <Object>{};

  @override
  State<ZEntrance> createState() => _ZEntranceState();
}

class _ZEntranceState extends State<ZEntrance>
    with SingleTickerProviderStateMixin {
  late final int _slot = widget.index.clamp(0, ZEntrance.maxStagger);
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: ZMotion.entrance + ZMotion.stagger * _slot,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Interval(
      _c.duration!.inMicroseconds == 0
          ? 0
          : (ZMotion.stagger * _slot).inMicroseconds /
                _c.duration!.inMicroseconds,
      1,
      curve: ZMotion.emphasized,
    ),
  );

  @override
  void initState() {
    super.initState();
    final once = widget.once;
    if (once != null) {
      if (ZEntrance._played.length > 2000) ZEntrance._played.clear();
      if (!ZEntrance._played.add(once)) {
        _c.value = 1;
        return;
      }
    }
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Same tree once finished (Opacity at 1 adds no layer), so completing
    // never remounts the child.
    if (_reduceMotion(context)) return widget.child;
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - _t.value)),
          child: child,
        ),
      ),
    );
  }
}

/// Scales to 0.96 while pressed (mockup `:active` rule). Wrap any tappable card/button.
class ZPressable extends StatefulWidget {
  const ZPressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = ZMotion.pressScale,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final BorderRadius? borderRadius;

  @override
  State<ZPressable> createState() => _ZPressableState();
}

class _ZPressableState extends State<ZPressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap != null && _down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        child: AnimatedScale(
          scale: _down && !_reduceMotion(context) ? widget.scale : 1,
          duration: ZMotion.press,
          curve: ZMotion.standard,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Looping animation used for the ETA bolt (pulse) and illustrations (bob/float).
enum ZLoopKind { pulse, bob, float }

class ZLoop extends StatefulWidget {
  const ZLoop({
    super.key,
    required this.child,
    this.kind = ZLoopKind.pulse,
    this.phase = 0,
  });

  final Widget child;
  final ZLoopKind kind;

  /// 0..1 start offset so several loops don't move in sync.
  final double phase;

  @override
  State<ZLoop> createState() => _ZLoopState();
}

class _ZLoopState extends State<ZLoop> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: switch (widget.kind) {
      ZLoopKind.pulse => const Duration(milliseconds: 1600),
      ZLoopKind.bob => const Duration(milliseconds: 2400),
      ZLoopKind.float => const Duration(milliseconds: 4000),
    },
    value: widget.phase,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // No ticking at all when the user has turned animations off.
    if (_reduceMotion(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion(context)) return widget.child;
    // Its own layer: without it the loop repainted everything up to the
    // nearest boundary (on Home, the whole scrolling viewport) every frame.
    return RepaintBoundary(child: _animated());
  }

  Widget _animated() {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_c.value);
        return switch (widget.kind) {
          ZLoopKind.pulse => Transform.scale(
            scale: 1 + 0.18 * t,
            child: Opacity(opacity: 1 - 0.2 * t, child: child),
          ),
          ZLoopKind.bob => Transform.translate(
            offset: Offset(0, -6 * t),
            child: child,
          ),
          ZLoopKind.float => Transform.translate(
            offset: Offset(0, -8 * t),
            child: Transform.rotate(
              angle: (-2 + 4 * t) * 0.01745,
              child: child,
            ),
          ),
        };
      },
    );
  }
}

/// Shimmering placeholder block for loading states.
///
/// Cheap enough to use by the dozen: the sweep is painted by a
/// [CustomPainter] that repaints from the controller (no widget rebuild or
/// new decoration per frame), inside its own [RepaintBoundary], and every
/// block starts at the same phase of a shared clock so a screen of
/// skeletons shimmers as one surface.
class ZSkeleton extends StatefulWidget {
  const ZSkeleton({
    super.key,
    this.width,
    required this.height,
    this.radius = 10,
  });

  final double? width;
  final double height;
  final double radius;

  static const Duration period = Duration(milliseconds: 1200);

  @override
  State<ZSkeleton> createState() => _ZSkeletonState();
}

class _ZSkeletonState extends State<ZSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: ZSkeleton.period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Static block when the user has turned animations off.
    if (_reduceMotion(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      // Same phase as every other block on screen.
      final period = ZSkeleton.period.inMicroseconds;
      _c.value = (DateTime.now().microsecondsSinceEpoch % period) / period;
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return RepaintBoundary(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: CustomPaint(
          // Fill the box like the old decoration-only Container did.
          size: Size.infinite,
          painter: _ShimmerPainter(
            progress: _c,
            radius: widget.radius,
            base: z.surface2,
            highlight: z.surface3,
          ),
        ),
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  _ShimmerPainter({
    required this.progress,
    required this.radius,
    required this.base,
    required this.highlight,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final double radius;
  final Color base, highlight;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final v = progress.value;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-2 + 2 * v, 0),
        end: Alignment(2 * v, 0),
        colors: [base, highlight, base],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) =>
      old.progress != progress ||
      old.radius != radius ||
      old.base != base ||
      old.highlight != highlight;
}
