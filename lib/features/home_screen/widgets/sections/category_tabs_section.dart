import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/widgets/z_brand_texture.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/home_screen/widgets/sections/section_icons.dart';
import 'package:zippy/features/home_screen/widgets/sections/section_data.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// Horizontal strip of category chips (icon in a circle + label).
/// Admin-configured via `home_sections.type == 'category_tabs'`;
/// `config.sticky` pins it while the rest of Home scrolls (see
/// [StickyCategoryTabsDelegate]).
///
/// [onHero]: the strip sits on Home's purple header (it's the first
/// section), so the chips are glass on purple; otherwise they're light
/// chips on the page. [pinned]: content is scrolling underneath, so the
/// strip gets a solid background.
class CategoryTabsSection extends StatelessWidget {
  static const _chipHeight = 40.0;

  /// The strip's full height, padding included.
  static const height = _chipHeight + 2 * ZSpace.x3;

  /// Chips keep a fixed height (the sticky header needs one), so their
  /// text stops growing here.
  static const _maxTextScale = 1.3;

  final HomeSection section;
  final bool onHero;
  final bool pinned;

  const CategoryTabsSection({
    super.key,
    required this.section,
    this.onHero = false,
    this.pinned = false,
  });

  @override
  Widget build(BuildContext context) {
    final strip = SizedBox(
      height: height,
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: _maxTextScale,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: ZSpace.screen,
            vertical: ZSpace.x3,
          ),
          itemCount: section.items.length,
          separatorBuilder: (context, index) =>
              const SizedBox(width: ZSpace.x2),
          itemBuilder: (context, index) {
            final item = section.items[index];
            final categoryId = item.data.string('category_id');
            return _Chip(
              label: item.data.string('label') ?? '',
              icon: resolveSectionIcon(item.data.string('icon')),
              onHero: onHero,
              onTap: categoryId == null
                  ? null
                  : () => context.push(
                      '/categoryDetailsScreen?categoryId=$categoryId',
                    ),
            );
          },
        ),
      ),
    );

    if (!pinned) return strip;
    final z = context.z;
    return onHero
        ? ZBrandTexture(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(ZRadius.heroPinned),
            ),
            child: strip,
          )
        : DecoratedBox(
            decoration: BoxDecoration(color: z.surface, boxShadow: z.elevation),
            child: strip,
          );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.onHero,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool onHero;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return Semantics(
      button: onTap != null,
      child: ZPressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(left: ZSpace.x1, right: 14),
          decoration: BoxDecoration(
            // Glass on the purple header; a light pill on the page.
            color: onHero ? z.onBrand.withValues(alpha: .14) : z.surface,
            borderRadius: ZRadius.all(ZRadius.chip + 2),
            border: Border.all(
              color: onHero ? z.onBrand.withValues(alpha: .22) : z.line,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: onHero ? z.onBrand : z.brandSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: onHero ? z.brand : z.brandText,
                ),
              ),
              const SizedBox(width: ZSpace.x2),
              Text(
                label,
                maxLines: 1,
                style: t.labelMedium!.copyWith(
                  color: onHero ? z.headerInk : z.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pins a `config.sticky` [CategoryTabsSection] to the top of the Home
/// screen's scroll view; it turns solid once content scrolls under it.
class StickyCategoryTabsDelegate extends SliverPersistentHeaderDelegate {
  final HomeSection section;
  final bool onHero;

  const StickyCategoryTabsDelegate(this.section, {this.onHero = false});

  @override
  double get minExtent => CategoryTabsSection.height;

  @override
  double get maxExtent => CategoryTabsSection.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => CategoryTabsSection(
    section: section,
    onHero: onHero,
    pinned: overlapsContent || shrinkOffset > 0,
  );

  @override
  bool shouldRebuild(StickyCategoryTabsDelegate oldDelegate) =>
      oldDelegate.section != section || oldDelegate.onHero != onHero;
}
