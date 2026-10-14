import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_typography.dart';

/// docs/mockups/Main.dc.html's `.cat` chip: a circular colored icon
/// with the category label below.
class CategoryCard extends StatelessWidget {
  final String categoryText;
  final String imageUrl;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.categoryText,
    required this.imageUrl,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            categoryText,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}
