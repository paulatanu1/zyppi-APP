import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/routes/home_fallback_scope.dart';

/// docs/screens/light/06-category.png's header: back, title with
/// "148 items · delivered in 12 min", search.
class CategoryDetailsHeader extends StatelessWidget {
  final String title;
  final int itemCount;
  final bool loading;

  const CategoryDetailsHeader({
    super.key,
    required this.title,
    required this.itemCount,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ZSpace.x1),
      child: Row(
        children: [
          IconButton(
            onPressed: () => popOrHome(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            tooltip: 'back'.tr(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.titleLarge,
                ),
                // No "0 items" flash while loading.
                if (!loading)
                  Text(
                    '${'itemCount'.plural(itemCount)} · ${'deliveredInEta'.tr()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodySmall,
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push('/searchScreen'),
            icon: const Icon(Icons.search_rounded),
            tooltip: 'search'.tr(),
          ),
        ],
      ),
    );
  }
}
