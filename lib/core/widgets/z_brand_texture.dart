import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// The splash's supporting purples, used for the aurora blobs on any brand
/// surface (splash backdrop, Home header).
abstract final class ZBrandTones {
  static const deep = Color(0xFF4527A0);
  static const aurora = Color(0xFF9575CD);
  static const lilac = Color(0xFFB39DDB);
}

/// The textured fill of brand buttons (`filledButtonTheme`): the texture
/// in [ZColors.brand], with a pressed shade drawn here because the ink
/// ripple sits under it. Disabled buttons keep their flat colour.
Widget zBrandButtonBackground(
  BuildContext context,
  Set<WidgetState> states,
  Widget? child,
) {
  if (states.contains(WidgetState.disabled)) return child ?? const SizedBox();
  final pressed = states.contains(WidgetState.pressed);
  return ZBrandTexture(
    color: context.z.brand,
    borderRadius: ZRadius.all(ZRadius.button),
    child: Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      children: [
        if (pressed)
          Positioned.fill(
            child: ColoredBox(color: ZBrandTones.deep.withValues(alpha: .3)),
          ),
        ?child,
      ],
    ),
  );
}

/// A tile of film grain (random greys at 7% alpha), made once and kept for
/// the life of the app. Tile it with an [ImageShader].
abstract final class ZGrain {
  static const int _size = 128;

  static final ui.Image image = _make();

  static ui.Image _make() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final rnd = math.Random(3);
    const levels = 6;
    final buckets = List.generate(levels, (_) => <double>[]);
    for (var y = 0; y < _size; y++) {
      for (var x = 0; x < _size; x++) {
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
    final picture = recorder.endRecording();
    final image = picture.toImageSync(_size, _size);
    picture.dispose();
    return image;
  }

  /// Covers [rect] with grain. Plain source-over: an advanced blend such as
  /// overlay makes Impeller read back the screen, and at 7% it looks the
  /// same.
  static void paint(Canvas canvas, Rect rect) {
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ImageShader(
          image,
          TileMode.repeated,
          TileMode.repeated,
          Float64List.fromList(Matrix4.identity().storage),
        ),
    );
  }
}

/// A blurred ellipse (CSS `filter: blur(40px)`) drawn as a radial
/// gradient — far cheaper than a real blur and reads the same. [k] (0–1)
/// moves it by [move] (fractions of its size) and scales it toward
/// [scaleTo].
void paintAuroraBlob(
  Canvas canvas,
  Rect rect,
  Color color, {
  double opacity = 1,
  double k = 0,
  Offset move = Offset.zero,
  double scaleTo = 1,
  double blur = 40,
}) {
  final scale = 1 + (scaleTo - 1) * k;
  final centre =
      rect.center + Offset(move.dx * rect.width * k, move.dy * rect.height * k);
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

/// The splash texture on a brand surface: [ZColors.header] fill, three
/// still aurora blobs and film grain, clipped to [borderRadius]. Static —
/// painted once behind a [RepaintBoundary], then only composited.
class ZBrandTexture extends StatelessWidget {
  const ZBrandTexture({
    super.key,
    this.borderRadius = BorderRadius.zero,
    this.color,
    this.child,
  });

  final BorderRadius borderRadius;

  /// Fill colour; defaults to [ZColors.header].
  final Color? color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // The texture repaints only when its colour or size changes, never
    // because the content on top of it did.
    final texture = RepaintBoundary(
      child: CustomPaint(
        painter: _BrandTexturePainter(
          fill: color ?? context.z.header,
          // Softer blobs on the dark header so it stays dark.
          strength: dark ? .45 : 1,
        ),
      ),
    );
    return ClipRRect(
      borderRadius: borderRadius,
      child: child == null
          ? SizedBox.expand(child: texture)
          // Passthrough: the content gets the same constraints as this box
          // (a button's label stays centred, a header keeps its width).
          : Stack(
              fit: StackFit.passthrough,
              children: [
                Positioned.fill(child: texture),
                child!,
              ],
            ),
    );
  }
}

class _BrandTexturePainter extends CustomPainter {
  const _BrandTexturePainter({required this.fill, required this.strength});

  final Color fill;
  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final w = size.width, h = size.height;
    canvas.drawRect(rect, Paint()..color = fill);
    // Same three blobs as the splash, laid out on this box and frozen
    // part-way through their drift.
    paintAuroraBlob(
      canvas,
      Rect.fromLTWH(-.2 * w, -.25 * h, .7 * w, .8 * h),
      ZBrandTones.aurora,
      opacity: strength,
      k: .35,
      move: const Offset(.4, .25),
      scaleTo: 1.2,
    );
    paintAuroraBlob(
      canvas,
      Rect.fromLTWH(.45 * w, .1 * h, .8 * w, .9 * h),
      ZBrandTones.deep,
      opacity: strength,
      k: .5,
      move: const Offset(-.35, -.2),
      scaleTo: .9,
    );
    paintAuroraBlob(
      canvas,
      Rect.fromLTWH(-.1 * w, .7 * h, .6 * w, .6 * h),
      ZBrandTones.lilac,
      opacity: .5 * strength,
      k: .2,
      move: const Offset(.4, .25),
      scaleTo: 1.2,
    );
    ZGrain.paint(canvas, rect);
  }

  @override
  bool shouldRepaint(_BrandTexturePainter old) =>
      old.fill != fill || old.strength != strength;
}
