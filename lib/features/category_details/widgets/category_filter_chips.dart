import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/domain/product_filter.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/features/filter/presentation/filter_screen.dart';

/// docs/screens/light/06-category.png's chip row: Filter (opens the filter
/// screen, shows the active count) · Sort (sheet) · Offers (toggles
/// "only discounted"). All three edit [productFilterProvider].
class CategoryFilterChips extends ConsumerWidget {
  const CategoryFilterChips({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(productFilterProvider(categoryId));
    final notifier = ref.read(productFilterProvider(categoryId).notifier);

    return SizedBox(
      height: ZSize.touch,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: ZSpace.screen),
        children: [
          ZChip(
            icon: Icons.tune_rounded,
            label: 'filters'.tr(),
            count: filter.activeCount,
            onTap: () => context.push('/filterScreen?categoryId=$categoryId'),
          ),
          const SizedBox(width: ZSpace.x2),
          ZChip(
            label: filter.sort == ProductSort.relevance
                ? 'sortBy'.tr()
                : productSortLabel(filter.sort),
            trailing: Icons.keyboard_arrow_down_rounded,
            selected: filter.sort != ProductSort.relevance,
            onTap: () async {
              final sort = await showModalBottomSheet<ProductSort>(
                context: context,
                showDragHandle: true,
                builder: (context) => _SortSheet(selected: filter.sort),
              );
              if (sort != null) {
                notifier.state = notifier.state.copyWith(sort: sort);
              }
            },
          ),
          const SizedBox(width: ZSpace.x2),
          ZChip(
            label: 'offersChip'.tr(),
            selected: filter.onlyDiscounted,
            onTap: () => notifier.state = notifier.state.copyWith(
              onlyDiscounted: !filter.onlyDiscounted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.selected});

  final ProductSort selected;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ZSpace.screen,
              0,
              ZSpace.screen,
              ZSpace.x2,
            ),
            child: Text('sortBy'.tr(), style: t.titleMedium),
          ),
          RadioGroup<ProductSort>(
            groupValue: selected,
            onChanged: (value) => Navigator.of(context).pop(value),
            child: Column(
              children: [
                for (final sort in ProductSort.values)
                  RadioListTile<ProductSort>(
                    value: sort,
                    title: Text(productSortLabel(sort)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: ZSpace.x2),
        ],
      ),
    );
  }
}
