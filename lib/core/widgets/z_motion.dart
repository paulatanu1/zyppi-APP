import 'package:flutter/material.dart';

import '../theme/zyppi_theme.dart';

bool _reduceMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context);

/// Fade + 14px slide-up entrance. `index` staggers siblings by 60 ms
/// (mockup class `.in` with `--i`).
class ZEntrance extends StatefulWidget {
  const ZEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 14,
  });

  final Widget child;
  final int index;
  final double offset;

  @override
  State<ZEntrance> createState() => _ZEntranceState();
}

class _ZEntranceState extends State<ZEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: ZMotion.entrance,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: ZMotion.emphasized,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(ZMotion.stagger * widget.index, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion(context)) return widget.child;
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

  @override
  State<ZSkeleton> createState() => _ZSkeletonState();
}

class _ZSkeletonState extends State<ZSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(-1 + 2 * _c.value - 1, 0),
            end: Alignment(1 + 2 * _c.value - 1, 0),
            colors: [z.surface2, z.surface3, z.surface2],
          ),
        ),
      ),
    );
  }
}
