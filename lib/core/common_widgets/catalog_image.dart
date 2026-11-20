import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_colors.dart';

/// Renders a category/product image: a Firebase Storage URL in
/// Firebase mode, or a bundled asset path in mock mode — the catalog
/// repositories hand back whichever one applies, so this is the only
/// place that needs to tell them apart.
class CatalogImage extends StatelessWidget {
  static const _fallbackAsset = 'assets/images/item.png';

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

  static bool _isNetwork(String? source) =>
      source != null &&
      (source.startsWith('http://') || source.startsWith('https://'));

  /// Starts downloading and decoding [image] for a [width]-wide slot, with
  /// the same cache key [CatalogImage] uses, so it shows at once when it
  /// scrolls or slides into view (e.g. the 2nd and 3rd home banners).
  static Future<void> precache(
    BuildContext context,
    String? image, {
    double? width,
  }) {
    if (!_isNetwork(image)) return Future.value();
    final provider = ResizeImage.resizeIfNeeded(
      _decodeWidth(
        width ?? MediaQuery.sizeOf(context).width,
        MediaQuery.devicePixelRatioOf(context),
      ),
      null,
      CachedNetworkImageProvider(image!),
    );
    return precacheImage(provider, context, onError: (_, _) {});
  }

  @override
  Widget build(BuildContext context) {
    final source = image;

    if (source == null || source.isEmpty) {
      return Image.asset(
        _fallbackAsset,
        fit: fit,
        width: width,
        height: height,
      );
    }

    if (_isNetwork(source)) {
      // Decode at the size it's drawn (never wider than the screen), not
      // the uploaded size: a grid of full-size photos is what makes lists
      // stutter and run out of memory on low-end phones. No LayoutBuilder:
      // some tiles sit inside IntrinsicHeight.
      final decodeWidth = _decodeWidth(
        width ?? MediaQuery.sizeOf(context).width,
        MediaQuery.devicePixelRatioOf(context),
      );
      return CachedNetworkImage(
        imageUrl: source,
        fit: fit,
        width: width,
        height: height,
        memCacheWidth: decodeWidth,
        fadeInDuration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 200),
        placeholder: (context, url) => ColoredBox(
          color: context.z.surface2,
          child: SizedBox(width: width, height: height),
        ),
        errorWidget: (context, url, error) =>
            Image.asset(_fallbackAsset, fit: fit, width: width, height: height),
      );
    }

    return Image.asset(
      source,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) =>
          Image.asset(_fallbackAsset, fit: fit, width: width, height: height),
    );
  }
}

/// Pixels to decode for an image drawn [logicalWidth] wide, rounded up to
/// a step of 100 so nearby sizes share one cached bitmap. Null (decode at
/// full size) when the width isn't known.
int? _decodeWidth(double logicalWidth, double pixelRatio) {
  if (!logicalWidth.isFinite || logicalWidth <= 0) return null;
  final px = (logicalWidth * pixelRatio / 100).ceil() * 100;
  return px.clamp(100, 1600);
}
