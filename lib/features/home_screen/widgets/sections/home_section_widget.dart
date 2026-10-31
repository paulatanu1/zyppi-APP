import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/home_screen/widgets/sections/banner_carousel_section.dart';
import 'package:zippy/features/home_screen/widgets/sections/category_cluster_section.dart';
import 'package:zippy/features/home_screen/widgets/sections/category_grid_section.dart';
import 'package:zippy/features/home_screen/widgets/sections/category_tabs_section.dart';
import 'package:zippy/features/home_screen/widgets/sections/product_carousel_section.dart';
import 'package:zippy/features/home_screen/widgets/sections/spotlight_cards_section.dart';

/// Dispatches a [HomeSection] to its renderer by `type` — new types are
/// added here as a developer builds a widget for them (see docs/PLAN.md's
/// typed-section/flexible-item note); an unrecognized type renders
/// nothing rather than crashing, since this content is admin-edited.
class HomeSectionWidget extends StatelessWidget {
  final HomeSection section;
  final Map<String, Category> categoriesById;
  final Map<String, Product> productsById;

  const HomeSectionWidget({
    super.key,
    required this.section,
    required this.categoriesById,
    required this.productsById,
  });

  @override
  Widget build(BuildContext context) {
    final body = switch (section.type) {
      'category_tabs' => CategoryTabsSection(section: section),
      'banner_carousel' => BannerCarouselSection(section: section),
      'category_grid' => CategoryGridSection(
        section: section,
        categoriesById: categoriesById,
      ),
      'product_carousel' => ProductCarouselSection(
        section: section,
        productsById: productsById,
      ),
      'category_cluster' => CategoryClusterSection(
        section: section,
        categoriesById: categoriesById,
      ),
      'spotlight_cards' => SpotlightCardsSection(
        section: section,
        productsById: productsById,
      ),
      _ => null,
    };

    if (body == null) {
      if (kDebugMode) {
        debugPrint('HomeSectionWidget: unknown section type "${section.type}"');
      }
      return const SizedBox.shrink();
    }

    // category_tabs renders its own full-bleed strip (no title, no
    // horizontal screen padding) — every other type sits inside the
    // screen's normal content padding with an optional title.
    if (section.type == 'category_tabs') return body;

    // Banners and horizontal lists bleed full-width (lists pad their own
    // first/last item so they scroll out to the screen edge instead of
    // being clipped at the content padding), but — unlike category_tabs —
    // they can still have an optional title, which stays inset like every
    // other section's.
    const fullBleed = {
      'banner_carousel',
      'product_carousel',
      'spotlight_cards',
    };
    if (fullBleed.contains(section.type)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Text(section.title!, style: AppTypography.section),
            ),
            const SizedBox(height: AppSpacing.base),
          ],
          body,
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.title != null) ...[
            Text(section.title!, style: AppTypography.section),
            const SizedBox(height: AppSpacing.base),
          ],
          body,
        ],
      ),
    );
  }
}
