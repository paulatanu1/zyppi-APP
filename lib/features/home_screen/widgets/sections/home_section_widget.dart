import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/common_widgets/nav_bar/provider/nav_bar_provider.dart';
import 'package:zippy/core/theme/zyppi_tokens.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/domain/product.dart';
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
class HomeSectionWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
    final header = section.title == null
        ? null
        : ZSectionHeader(
            section.title!,
            pill: true,
            // "Shop by category" → every category, on the Explore tab.
            onSeeAll: section.type == 'category_grid'
                ? () => ref.read(navBarProvider.notifier).updateIndex(1)
                : null,
          );

    if (fullBleed.contains(section.type)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ZSpace.screen),
              child: header,
            ),
            const SizedBox(height: ZSpace.x3),
          ],
          body,
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ZSpace.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) ...[header, const SizedBox(height: ZSpace.x3)],
          body,
        ],
      ),
    );
  }
}
