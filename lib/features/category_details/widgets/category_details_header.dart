import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_typography.dart';

/// docs/mockups/Category.dc.html's header: back, title + item count,
/// search.
class CategoryDetailsHeader extends StatelessWidget {
  final String title;
  final int itemCount;

  const CategoryDetailsHeader({
    super.key,
    required this.title,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleLarge),
              Text(
                '$itemCount items',
                style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push('/filterScreen'),
          icon: const Icon(Icons.filter_list),
        ),
        IconButton(
          onPressed: () => context.push('/searchScreen'),
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }
}
