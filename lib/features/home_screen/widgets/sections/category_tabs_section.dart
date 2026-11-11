import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/features/home_screen/widgets/sections/section_icons.dart';
import 'package:zippy/features/home_screen/widgets/sections/section_data.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// Blinkit-referenced horizontal icon+label tabs strip, directly under
/// search. Admin-configured via `home_sections.type == 'category_tabs'`;
/// `config.sticky` pins it together with the search bar on the brand
/// header (see [HomePinnedHeaderDelegate]).
///
/// The selected tab gets a bold label and an indicator bar that grows in
/// under it. Tapping a category selects it, opens that category, and
/// selects the first tab ("All") again on return. A tab with no
/// `category_id` ("All") calls [onAllTap].
class CategoryTabsSection extends StatefulWidget {
  static const _stripHeight = 60.0;

  /// The strip's full height, padding included.
  static const height = _stripHeight + ZSpace.x2;

  final HomeSection section;

  /// Paint on the brand header (pinned) instead of a plain surface.
  final bool onBrand;

  /// "All" (no `category_id`): Home scrolls back to the top.
  final VoidCallback? onAllTap;

  const CategoryTabsSection({
    super.key,
    required this.section,
    this.onBrand = false,
    this.onAllTap,
  });

  @override
  State<CategoryTabsSection> createState() => _CategoryTabsSectionState();
}

class _CategoryTabsSectionState extends State<CategoryTabsSection> {
  int _selected = 0;

  Future<void> _onTap(int index, String? categoryId) async {
    setState(() => _selected = index);
    if (categoryId == null) {
      widget.onAllTap?.call();
      return;
    }
    await context.push('/categoryDetailsScreen?categoryId=$categoryId');
    if (mounted) setState(() => _selected = 0);
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final items = widget.section.items;
    final ink = widget.onBrand ? z.headerInk : z.ink;
    final ink2 = widget.onBrand ? z.headerInk2 : z.ink2;
    final indicator = widget.onBrand ? z.onBrand : z.brand;
    final motion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : ZMotion.ui;
    final t = Theme.of(context).textTheme;

    return Container(
      color: widget.onBrand ? z.header : z.surface,
      padding: const EdgeInsets.only(bottom: ZSpace.x2),
      child: SizedBox(
        height: CategoryTabsSection._stripHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: ZSpace.x2),
          itemCount: items.length,
          separatorBuilder: (context, index) =>
              const SizedBox(width: ZSpace.x1),
          itemBuilder: (context, index) {
            final item = items[index];
            final label = item.data.string('label') ?? '';
            final categoryId = item.data.string('category_id');
            final selected = index == _selected;

            return Semantics(
              button: true,
              selected: selected,
              child: InkWell(
                borderRadius: ZRadius.all(ZRadius.control),
                onTap: categoryId == null && widget.onAllTap == null
                    ? null
                    : () => _onTap(index, categoryId),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 64),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: ZSpace.x3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedScale(
                          duration: motion,
                          curve: ZMotion.emphasized,
                          scale: selected ? 1.12 : 1,
                          child: Icon(
                            resolveSectionIcon(item.data.string('icon')),
                            size: 22,
                            color: selected ? ink : ink2,
                          ),
                        ),
                        const SizedBox(height: ZSpace.x1),
                        Text(
                          label,
                          maxLines: 1,
                          style: t.labelMedium!.copyWith(
                            color: selected ? ink : ink2,
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: ZSpace.x1 + 2),
                        AnimatedContainer(
                          duration: motion,
                          curve: ZMotion.emphasized,
                          height: 3,
                          width: selected ? ZSpace.x6 + ZSpace.x2 : 0,
                          decoration: BoxDecoration(
                            color: indicator,
                            borderRadius: ZRadius.all(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Home's pinned chrome: the search bar and (when the admin marked a
/// `category_tabs` section `sticky`) the tabs, as one continuous brand
/// surface right under the status bar. The ETA/address header above it
/// scrolls away; a soft shadow appears once content slides underneath.
class HomePinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final HomeSection? tabs;
  final VoidCallback onSearch;
  final VoidCallback? onAllTap;

  const HomePinnedHeaderDelegate({
    required this.tabs,
    required this.onSearch,
    this.onAllTap,
  });

  static const double _searchBlock = ZSize.search + ZSpace.x3;

  double get _extent =>
      _searchBlock + (tabs == null ? 0 : CategoryTabsSection.height);

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final z = context.z;
    final raised = overlapsContent || shrinkOffset > 0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: z.header,
        boxShadow: [
          if (raised)
            BoxShadow(
              color: z.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ZSpace.screen,
              0,
              ZSpace.screen,
              ZSpace.x3,
            ),
            child: ZSearchBar(onTap: onSearch),
          ),
          if (tabs != null)
            CategoryTabsSection(
              section: tabs!,
              onBrand: true,
              onAllTap: onAllTap,
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(HomePinnedHeaderDelegate oldDelegate) =>
      oldDelegate.tabs != tabs || oldDelegate.onAllTap != onAllTap;
}
