import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// "Fly to cart": on ADD, a copy of the product picture arcs from the card
/// into the floating cart bar, which then bumps (see [CartFlyTarget]).
///
/// Several cart bars can be mounted at once (Home inside the tab stack,
/// a pushed category page), so targets register themselves and the one
/// that is on screen — current route, ticking (not an offstage tab) — wins.
/// With no visible bar yet (first item: the bar is still sliding in), the
/// picture flies to where the bar appears, at the bottom centre.
abstract final class CartFly {
  static final Set<_CartFlyTargetState> _targets = {};

  static const Duration duration = Duration(milliseconds: 650);
  static const double _size = 56;

  /// Flies [image] from [source]'s top area to the visible cart bar.
  /// Does nothing when animations are disabled.
  static void launch(BuildContext source, Widget image) {
    if (MediaQuery.disableAnimationsOf(source)) return;
    final overlay = Overlay.maybeOf(source, rootOverlay: true);
    final box = source.findRenderObject() as RenderBox?;
    if (overlay == null || box == null || !box.attached) return;
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (overlayBox == null) return;

    final from = box.localToGlobal(
      Offset(box.size.width / 2, box.size.width * .4),
      ancestor: overlayBox,
    );
    final target = _visibleTarget();
    final targetBox = target?.context.findRenderObject() as RenderBox?;
    final to = targetBox != null && targetBox.attached
        ? targetBox.localToGlobal(
            Offset(ZSpace.x6, targetBox.size.height / 2),
            ancestor: overlayBox,
          )
        : Offset(
            overlayBox.size.width / 2,
            overlayBox.size.height - ZSize.navBar - ZSize.cartBar / 2,
          );

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _FlyingThumb(
        from: from,
        to: to,
        image: image,
        onDone: () {
          entry.remove();
          target?.bump();
        },
      ),
    );
    overlay.insert(entry);
  }

  static _CartFlyTargetState? _visibleTarget() {
    for (final t in _targets) {
      if (!t.mounted) continue;
      final route = ModalRoute.of(t.context);
      if ((route == null || route.isCurrent) &&
          TickerMode.valuesOf(t.context).enabled) {
        return t;
      }
    }
    return null;
  }
}

/// Wrap the floating cart bar: it becomes the landing spot for
/// [CartFly.launch] and bumps when a picture lands.
class CartFlyTarget extends StatefulWidget {
  const CartFlyTarget({super.key, required this.child});

  final Widget child;

  @override
  State<CartFlyTarget> createState() => _CartFlyTargetState();
}

class _CartFlyTargetState extends State<CartFlyTarget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bump = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  @override
  void initState() {
    super.initState();
    CartFly._targets.add(this);
  }

  @override
  void dispose() {
    CartFly._targets.remove(this);
    _bump.dispose();
    super.dispose();
  }

  void bump() {
    if (mounted) _bump.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _bump,
    child: widget.child,
    // 1 → 1.05 → 1 over the bump.
    builder: (context, child) => Transform.scale(
      scale: 1 + .05 * math.sin(math.pi * _bump.value),
      child: child,
    ),
  );
}

class _FlyingThumb extends StatefulWidget {
  const _FlyingThumb({
    required this.from,
    required this.to,
    required this.image,
    required this.onDone,
  });

  final Offset from, to;
  final Widget image;
  final VoidCallback onDone;

  @override
  State<_FlyingThumb> createState() => _FlyingThumbState();
}

class _FlyingThumbState extends State<_FlyingThumb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: CartFly.duration,
  )..forward().whenComplete(widget.onDone);

  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Curves.easeInOutCubic,
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Quadratic Bézier with the control point above both ends: an arc.
  Offset _at(double t) {
    final a = widget.from, b = widget.to;
    final control = Offset(
      (a.dx + b.dx) / 2,
      math.min(a.dy, b.dy) - ZSpace.x8 * 3,
    );
    final u = 1 - t;
    return a * (u * u) + control * (2 * u * t) + b * (t * t);
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, child) {
          final t = _t.value;
          final p = _at(t);
          final size = CartFly._size * (1 - .55 * t);
          return Stack(
            children: [
              Positioned(
                left: p.dx - size / 2,
                top: p.dy - size / 2,
                width: size,
                height: size,
                child: Opacity(
                  opacity: t < .85 ? 1 : (1 - t) / .15,
                  child: child,
                ),
              ),
            ],
          );
        },
        child: Container(
          padding: const EdgeInsets.all(ZSpace.x1),
          decoration: BoxDecoration(
            // Product shots are on white in both themes.
            color: z.onBrand,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: z.shadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(child: widget.image),
        ),
      ),
    );
  }
}
