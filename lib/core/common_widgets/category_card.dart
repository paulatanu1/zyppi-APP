import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

/// docs/mockups/Main.dc.html's `.cat` chip: a circular colored icon
/// with the category label below.
class CategoryCard extends StatelessWidget {
  final String categoryText;
  final String? imageUrl;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.categoryText,
    this.imageUrl,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Category tints come from catalog data as light pastels; on a dark
    // surface they glare, so mute them into the surface colour.
    final circleColor = Theme.of(context).brightness == Brightness.dark
        ? Color.alphaBlend(
            backgroundColor.withValues(alpha: 0.16),
            context.colors.surface,
          )
        : backgroundColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ZSize.categoryTile / 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: ClipOval(child: CatalogImage(image: imageUrl)),
          ),
          const SizedBox(height: 6),
          Text(
            categoryText,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(color: context.colors.ink),
          ),
        ],
      ),
    );
  }
}
