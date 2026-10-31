import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/home_screen/widgets/sections/section_icons.dart';
import 'package:zippy/features/home_screen/widgets/sections/section_data.dart';

/// Blinkit-referenced horizontal icon+label tabs strip, directly under
/// search. Admin-configured via `home_sections.type == 'category_tabs'`;
/// `config.sticky` pins it while the rest of the Home screen scrolls.
class CategoryTabsSection extends StatelessWidget {
  final HomeSection section;

  const CategoryTabsSection({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surface,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
      child: SizedBox(
        height: 64,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          itemCount: section.items.length,
          separatorBuilder: (context, index) =>
              const SizedBox(width: AppSpacing.xl),
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
                    color: context.colors.ink,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: context.colors.ink,
                    ),
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
