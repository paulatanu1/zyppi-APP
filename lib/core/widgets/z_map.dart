import 'package:flutter/material.dart';

import '../theme/zyppi_theme.dart';

/// Drawn street plan from the mockups (blocks, roads, a park and water, in
/// the `map*` colour tokens) with an optional dotted [route]. Decorative:
/// it is not a live map of the user's area.
class ZMapBackdrop extends StatelessWidget {
  const ZMapBackdrop({super.key, this.route = const []});

  /// Points in pixels within this widget.
  final List<Offset> route;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      painter: _MapPainter(colors: context.z, route: route),
      size: Size.infinite,
    ),
  );
}

class _MapPainter extends CustomPainter {
  _MapPainter({required this.colors, this.route = const []});

  final ZColors colors;
  final List<Offset> route;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.mapBg);

    final block = Paint()..color = colors.mapBlock;
    RRect r(double l, double t, double rr, double b) => RRect.fromLTRBR(
      l * w,
      t * h,
      rr * w,
      b * h,
      const Radius.circular(ZRadius.tile),
    );
    for (final b in [
      r(.05, .05, .30, .22),
      r(.36, .05, .60, .22),
      r(.70, .05, .95, .22),
      r(.05, .33, .38, .50),
      r(.44, .33, .58, .50),
      r(.70, .33, .95, .50),
      r(.05, .62, .23, .80),
    ]) {
      canvas.drawRRect(b, block);
    }
    canvas.drawRRect(r(.28, .62, .56, .80), Paint()..color = colors.mapPark);
    canvas.drawPath(
      Path()
        ..moveTo(.66 * w, .80 * h)
        ..quadraticBezierTo(.75 * w, .64 * h, w, .66 * h)
        ..lineTo(w, h)
        ..lineTo(.66 * w, h)
        ..close(),
      Paint()..color = colors.mapWater,
    );

    final road = Paint()
      ..color = colors.mapRoad
      ..strokeWidth = 18;
    for (final y in [.27, .56, .86]) {
      canvas.drawLine(Offset(0, y * h), Offset(w, y * h), road);
    }
    for (final x in [.33, .64]) {
      canvas.drawLine(Offset(x * w, 0), Offset(x * w, h), road);
    }
    canvas.drawLine(Offset(.18 * w, .5 * h), Offset(.18 * w, h), road);

    // Dotted route.
    final dot = Paint()
      ..color = colors.brandText
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < route.length - 1; i++) {
      final a = route[i], b = route[i + 1];
      final len = (b - a).distance;
      for (var d = 0.0; d < len; d += 12) {
        canvas.drawLine(
          Offset.lerp(a, b, d / len)!,
          Offset.lerp(a, b, ((d + 5) / len).clamp(0, 1))!,
          dot,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.colors != colors || old.route != route;
}
