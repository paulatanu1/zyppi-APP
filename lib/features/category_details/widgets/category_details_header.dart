import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

/// docs/mockups/Category.dc.html's header: back, title + item count,
/// search.
class CategoryDetailsHeader extends StatelessWidget {
  final String categoryId;
  final String title;
  final int itemCount;
  final bool loading;
  final int activeFilters;

  const CategoryDetailsHeader({
    super.key,
    required this.categoryId,
    required this.title,
    required this.itemCount,
    this.loading = false,
    this.activeFilters = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          tooltip: 'back'.tr(),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleLarge),
              // No "0 items" flash while loading.
              if (!loading)
                Text(
                  'itemCount'.plural(itemCount),
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.muted,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push('/filterScreen?categoryId=$categoryId'),
          icon: Badge(
            isLabelVisible: activeFilters > 0,
            label: Text('$activeFilters'),
            child: const Icon(Icons.filter_list),
          ),
          tooltip: 'filters'.tr(),
        ),
        IconButton(
          onPressed: () => context.push('/searchScreen'),
          icon: const Icon(Icons.search),
          tooltip: 'search'.tr(),
        ),
      ],
    );
  }
}
