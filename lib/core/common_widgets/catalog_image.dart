import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_colors.dart';

/// Renders a category/product image: a Supabase Storage URL in
/// Supabase mode, or a bundled asset path in mock mode — the catalog
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

    if (source.startsWith('http://') || source.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: source,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => ColoredBox(
          color: AppColors.divider,
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
