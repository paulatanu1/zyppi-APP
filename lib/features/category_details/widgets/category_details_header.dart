import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

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
          tooltip: 'back'.tr(),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleLarge),
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
          onPressed: () => context.push('/filterScreen'),
          icon: const Icon(Icons.filter_list),
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
