import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/home_screen/widgets/sections/section_icons.dart';
import 'package:zippy/features/home_screen/widgets/sections/section_data.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// Blinkit-referenced horizontal icon+label tabs strip, directly under
/// search. Admin-configured via `home_sections.type == 'category_tabs'`;
/// `config.sticky` pins it while the rest of the Home screen scrolls (see
/// [StickyCategoryTabsDelegate]).
class CategoryTabsSection extends StatelessWidget {
  static const _stripHeight = 64.0;

  /// The strip's full height, padding included.
  static const height = _stripHeight + 2 * ZSpace.x3;

  final HomeSection section;

  const CategoryTabsSection({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.z.surface,
      padding: const EdgeInsets.symmetric(vertical: ZSpace.x3),
      child: SizedBox(
        height: _stripHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: ZSpace.x4),
          itemCount: section.items.length,
          separatorBuilder: (context, index) =>
              const SizedBox(width: ZSpace.x4),
          itemBuilder: (context, index) {
            final item = section.items[index];
            final label = item.data.string('label') ?? '';
            final categoryId = item.data.string('category_id');

            return InkWell(
              onTap: categoryId == null
                  ? null
                  : () => context.push(
                      '/categoryDetailsScreen?categoryId=$categoryId',
                    ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    resolveSectionIcon(item.data.string('icon')),
                    size: 22,
                    color: context.z.ink,
                  ),
                  const SizedBox(height: ZSpace.x1),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(color: context.z.ink),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Pins a `config.sticky` [CategoryTabsSection] to the top of the Home
/// screen's scroll view.
class StickyCategoryTabsDelegate extends SliverPersistentHeaderDelegate {
  final HomeSection section;

  const StickyCategoryTabsDelegate(this.section);

  @override
  double get minExtent => CategoryTabsSection.height;

  @override
  double get maxExtent => CategoryTabsSection.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => CategoryTabsSection(section: section);

  @override
  bool shouldRebuild(StickyCategoryTabsDelegate oldDelegate) =>
      oldDelegate.section != section;
}
