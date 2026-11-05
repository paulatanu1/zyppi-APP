import 'package:flutter/material.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_motion.dart';

/// docs/screens/light/12-tracking.png's map: a drawn street plan (not a
/// live map) with the store, the home pin and the dotted route. The rider
/// marker sits where the order's *status* puts it — at the store until
/// it's out for delivery, half-way while on the way, home once delivered.
/// There is no rider GPS in the data.
class TrackingMap extends StatelessWidget {
  const TrackingMap({super.key, required this.status});

  final OrderStatus status;

  // Route in fractions of the map: store → corner → corner → home.
  static const _store = Offset(.18, .74);
  static const _corner1 = Offset(.18, .56);
  static const _corner2 = Offset(.64, .56);
  static const _corner3 = Offset(.64, .27);
  static const _home = Offset(.85, .27);

  /// 0 = at the store, 1 = home.
  double get _progress => switch (status) {
    OrderStatus.placed || OrderStatus.packed => 0,
    OrderStatus.outForDelivery => .5,
    OrderStatus.delivered => 1,
    OrderStatus.cancelled => 0,
  };

  static Offset _along(double p) {
    const points = [_store, _corner1, _corner2, _corner3, _home];
    final lengths = [
      for (var i = 0; i < points.length - 1; i++)
        (points[i + 1] - points[i]).distance,
    ];
    var remaining = p * lengths.fold<double>(0, (a, b) => a + b);
    for (var i = 0; i < lengths.length; i++) {
      if (remaining <= lengths[i]) {
        return Offset.lerp(points[i], points[i + 1], remaining / lengths[i])!;
      }
      remaining -= lengths[i];
    }
    return _home;
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, c) {
          final size = Size(c.maxWidth, c.maxHeight);
          Offset at(Offset f) => Offset(f.dx * size.width, f.dy * size.height);
          final rider = at(_along(_progress));
          const marker = ZSize.touch;

          Widget pin(Offset p, Widget child) => Positioned(
            left: p.dx - marker / 2,
            top: p.dy - marker / 2,
            child: child,
          );

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _MapPainter(
                    colors: z,
                    route: [
                      at(_store),
                      at(_corner1),
                      at(_corner2),
                      at(_corner3),
                      at(_home),
                    ],
                  ),
                ),
              ),
              pin(
                at(_store),
                _Marker(
                  color: z.ink,
                  icon: Icons.storefront_rounded,
                  iconColor: z.surface,
                  radius: ZRadius.control,
                ),
              ),
              pin(
                at(_home),
                _Marker(
                  color: z.blue,
                  icon: Icons.home_outlined,
                  iconColor: z.onBrand,
                  radius: ZSize.touch,
                ),
              ),
              if (status != OrderStatus.cancelled)
                pin(
                  rider,
                  ZLoop(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: z.brand.withValues(alpha: .25),
                      ),
                      padding: const EdgeInsets.all(ZSpace.x1),
                      child: _Marker(
                        color: z.brand,
                        icon: Icons.pedal_bike_rounded,
                        iconColor: z.onBrand,
                        radius: ZSize.touch,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.radius,
  });

  final Color color, iconColor;
  final IconData icon;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: ZSize.touch - ZSpace.x2,
    height: ZSize.touch - ZSpace.x2,
    decoration: BoxDecoration(
      color: color,
      borderRadius: ZRadius.all(radius),
      boxShadow: [
        BoxShadow(
          color: context.z.shadow,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Icon(icon, size: 20, color: iconColor),
  );
}

class _MapPainter extends CustomPainter {
  _MapPainter({required this.colors, required this.route});

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
