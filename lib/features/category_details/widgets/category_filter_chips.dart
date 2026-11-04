import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/domain/product_filter.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_motion.dart';
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
          _Chip(
            icon: Icons.tune_rounded,
            label: 'filters'.tr(),
            count: filter.activeCount,
            onTap: () => context.push('/filterScreen?categoryId=$categoryId'),
          ),
          const SizedBox(width: ZSpace.x2),
          _Chip(
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
          _Chip(
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

/// Pill chip; selected = filled with ink. The tap area is the full 44 pt
/// row height.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.onTap,
    this.icon,
    this.trailing,
    this.selected = false,
    this.count = 0,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon, trailing;
  final bool selected;
  final int count;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final fg = selected ? z.surface : z.ink;
    final text = Theme.of(context).textTheme.labelMedium!
        .copyWith(color: fg, fontWeight: FontWeight.w700);

    return Semantics(
      selected: selected,
      child: ZPressable(
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : ZMotion.ui,
            curve: ZMotion.standard,
            padding: const EdgeInsets.symmetric(
              horizontal: ZSpace.x3,
              vertical: ZSpace.x2,
            ),
            decoration: BoxDecoration(
              color: selected ? z.ink : z.surface,
              borderRadius: ZRadius.all(ZRadius.chip),
              border: Border.all(color: selected ? z.ink : z.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: fg),
                  const SizedBox(width: ZSpace.x1),
                ],
                Text(label, style: text),
                if (count > 0) ...[
                  const SizedBox(width: ZSpace.x1),
                  Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: z.brand,
                      borderRadius: ZRadius.all(ZRadius.chip),
                    ),
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: text.copyWith(color: z.onBrand),
                    ),
                  ),
                ],
                if (trailing != null) Icon(trailing, size: 18, color: fg),
              ],
            ),
          ),
        ),
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
