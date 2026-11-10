import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_colors.dart';

/// Renders a category/product image: a Firebase Storage URL in
/// Firebase mode, or a bundled asset path in mock mode — the catalog
/// repositories hand back whichever one applies, so this is the only
/// place that needs to tell them apart.
///
/// Images are decoded at the size they're shown (× the screen's pixel
/// ratio), not at the source's full resolution: a 1500 px photo in a 64 px
/// tile otherwise costs a full-size decode and ~9 MB of memory per image,
/// which is what made grids and carousels stutter while scrolling.
class CatalogImage extends StatelessWidget {
  static const _fallbackAsset = 'assets/images/item.png';

  /// Quick fade for images that weren't in memory yet; the package default
  /// (500 ms in, 1 s placeholder out) left whole grids mid-fade.
  static const _fadeIn = Duration(milliseconds: 150);

  final String? image;
  final BoxFit fit;
  final double? width;
  final double? height;

  const CatalogImage({
    super.key,
    required this.image,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (width != null && height != null) {
      return _build(context, _decodeWidth(context, width!, height!));
    }
    return LayoutBuilder(
      builder: (context, constraints) => _build(
        context,
        _decodeWidth(
          context,
          width ?? constraints.maxWidth,
          height ?? constraints.maxHeight,
        ),
      ),
    );
  }

  /// Decode width in physical pixels: the box's longer side, so a square
  /// photo still fills it under [BoxFit.cover]. Only the width is fixed, so
  /// the aspect ratio is kept. `null` (full size) when the box is unbounded.
  static int? _decodeWidth(BuildContext context, double w, double h) {
    final side = [w, h].where((v) => v.isFinite && v > 0).fold(0.0, _max);
    if (side == 0) return null;
    return (side * MediaQuery.devicePixelRatioOf(context)).round();
  }

  static double _max(double a, double b) => a > b ? a : b;

  Widget _fallback(int? cacheWidth) => Image.asset(
    _fallbackAsset,
    fit: fit,
    width: width,
    height: height,
    cacheWidth: cacheWidth,
  );

  Widget _build(BuildContext context, int? cacheWidth) {
    final source = image;

    if (source == null || source.isEmpty) return _fallback(cacheWidth);

    if (source.startsWith('http://') || source.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: source,
        fit: fit,
        width: width,
        height: height,
        memCacheWidth: cacheWidth,
        fadeInDuration: _fadeIn,
        fadeOutDuration: Duration.zero,
        placeholder: (context, url) => ColoredBox(
          color: context.z.surface2,
          child: SizedBox(width: width, height: height),
        ),
        errorWidget: (context, url, error) => _fallback(cacheWidth),
      );
    }

    return Image.asset(
      source,
      fit: fit,
      width: width,
      height: height,
      cacheWidth: cacheWidth,
      errorBuilder: (context, error, stackTrace) => _fallback(cacheWidth),
    );
  }
}
