import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/common_widgets/section_card.dart';
import 'package:zippy/core/domain/product_filter.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/filter/widgets/filter_header.dart';

/// Display name of a sort order (filter screen and the category sort sheet).
String productSortLabel(ProductSort sort) => switch (sort) {
  ProductSort.relevance => 'sortRelevance'.tr(),
  ProductSort.priceLowToHigh => 'sortPriceLowHigh'.tr(),
  ProductSort.priceHighToLow => 'sortPriceHighLow'.tr(),
  ProductSort.discount => 'sortDiscount'.tr(),
};

/// Sort and narrow one category's listing. Opens with the filter that's
/// currently applied; "Apply" writes it back to [productFilterProvider],
/// which the category screen applies. (No brand facet — the catalog has
/// no brand field.)
class FilterScreen extends ConsumerStatefulWidget {
  final String categoryId;

  const FilterScreen({super.key, required this.categoryId});

  @override
  ConsumerState<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends ConsumerState<FilterScreen> {
  late ProductFilter _draft = ref.read(
    productFilterProvider(widget.categoryId),
  );

  void _apply() {
    ref.read(productFilterProvider(widget.categoryId).notifier).state = _draft;
    context.pop();
  }

  static String _bandLabel(PriceBand band) => switch (band) {
    PriceBand(:final minPaise, maxPaise: final max?) when minPaise == null =>
      'priceUnder'.tr(args: [PriceTag.format(max)]),
    PriceBand(minPaise: final min?, :final maxPaise) when maxPaise == null =>
      'priceOver'.tr(args: [PriceTag.format(min)]),
    PriceBand(minPaise: final min?, maxPaise: final max?) =>
      '${PriceTag.format(min)} – ${PriceTag.format(max)}',
    _ => '',
  };

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: z.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ZSpace.screen,
                ZSpace.x2,
                ZSpace.x2,
                0,
              ),
              child: FilterHeader(onCrossIconClicked: () => context.pop()),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(ZSpace.screen),
                children: [
                  SectionCard(
                    title: 'sortBy'.tr(),
                    child: RadioGroup<ProductSort>(
                      groupValue: _draft.sort,
                      onChanged: (value) =>
                          setState(() => _draft = _draft.copyWith(sort: value)),
                      child: Column(
                        children: [
                          for (final sort in ProductSort.values)
                            RadioListTile<ProductSort>(
                              value: sort,
                              contentPadding: EdgeInsets.zero,
                              activeColor: z.brand,
                              title: Text(
                                productSortLabel(sort),
                                style: text.bodyMedium,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: ZSpace.x3),
                  SectionCard(
                    title: 'price'.tr(),
                    child: Wrap(
                      spacing: ZSpace.x2,
                      runSpacing: ZSpace.x2,
                      children: [
                        for (final band in PriceBand.values)
                          FilterChip(
                            label: Text(_bandLabel(band)),
                            selected: _draft.priceBands.contains(band),
                            onSelected: (on) => setState(() {
                              final bands = {..._draft.priceBands};
                              on ? bands.add(band) : bands.remove(band);
                              _draft = _draft.copyWith(priceBands: bands);
                            }),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: ZSpace.x3),
                  SectionCard(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'onlyDiscounted'.tr(),
                        style: text.labelLarge,
                      ),
                      value: _draft.onlyDiscounted,
                      onChanged: (value) => setState(
                        () => _draft = _draft.copyWith(onlyDiscounted: value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                ZSpace.screen,
                ZSpace.x3,
                ZSpace.screen,
                ZSpace.x3 + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: BoxDecoration(
                color: z.surface,
                border: Border(top: BorderSide(color: z.line)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _draft.isActive
                          ? () => setState(() => _draft = ProductFilter.none)
                          : null,
                      child: Text('clearFilters'.tr()),
                    ),
                  ),
                  const SizedBox(width: ZSpace.x3),
                  Expanded(
                    child: FilledButton(
                      onPressed: _apply,
                      child: Text('applyFilter'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
