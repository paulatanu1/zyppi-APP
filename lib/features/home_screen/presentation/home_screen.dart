import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/cart/presentation/floating_cart_bar.dart';
import 'package:zippy/core/common_widgets/home_screen_header.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/theme/z_brand_scope.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_brand_texture.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/core/widgets/z_product_card.dart';
import 'package:zippy/features/home_screen/application/home_sections_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zippy/features/home_screen/widgets/sections/category_tabs_section.dart';
import 'package:zippy/features/home_screen/widgets/sections/home_section_widget.dart';
import 'package:zippy/features/home_screen/widgets/sections/section_data.dart';

/// Backend/admin-driven Home screen — renders `home_sections` in order
/// (see docs/PLAN.md's Blinkit-referenced redesign note). The delivery
/// header and search stay fixed app chrome, not admin content.
///
/// Logo-purple trial: the screen is wrapped in [ZBrandScope.violet]. A
/// textured hero panel sits behind the scroll view and curves under the
/// first section; the header pins and folds down to the search bar.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scroll = ScrollController();

  /// How far the hero panel reaches below the header, under the first
  /// section.
  static const _heroOverlap = 40.0;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ZBrandScope.violet(child: Builder(builder: _build));

  Widget _build(BuildContext context) {
    final sectionsAsync = ref.watch(homeSectionsProvider);
    final maxHeader = HomeScreenHeader.maxHeight(context);
    final minHeader = HomeScreenHeader.minHeight(context);
    // A category strip that comes first sits on the purple: the hero
    // panel grows to hold it, with the curve just below the chips.
    final first = sectionsAsync.value?.sections.firstOrNull;
    final tabsOnHero = first?.type == 'category_tabs';
    final tabsPinned = tabsOnHero && first!.config.boolean('sticky') == true;
    final heroOverlap = tabsOnHero
        ? CategoryTabsSection.height + ZSpace.x6
        : _heroOverlap;

    return Scaffold(
      backgroundColor: context.z.bg,
      body: Stack(
        children: [
          // Hero panel: moves with the content (a translate only — the
          // texture itself is painted once).
          AnimatedBuilder(
            animation: _scroll,
            builder: (context, child) {
              final offset = _scroll.hasClients ? _scroll.offset : 0.0;
              return Positioned(
                top: math.min(0.0, -offset),
                left: 0,
                right: 0,
                // Pulling down past the top stretches it instead of
                // opening a gap.
                height: maxHeader + heroOverlap + math.max(0.0, -offset),
                child: child!,
              );
            },
            child: const ZBrandTexture(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(ZRadius.hero),
              ),
            ),
          ),
          // Pull down to refresh: drops the cached catalog too, so new
          // prices/products show without restarting the app.
          RefreshIndicator(
            edgeOffset: minHeader,
            onRefresh: () {
              ref.read(catalogRepositoryProvider).invalidate();
              ref.invalidate(homeSectionsProvider);
              return ref
                  .read(homeSectionsProvider.future)
                  .then((_) {}, onError: (_) {});
            },
            // Slivers so the header and a `config.sticky` category_tabs
            // section can pin.
            child: CustomScrollView(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _HomeHeaderDelegate(
                    maxHeight: maxHeader,
                    minHeight: minHeader,
                    // A pinned category strip carries the curve instead.
                    roundPinned: !tabsPinned,
                  ),
                ),
                if (!tabsOnHero)
                  const SliverToBoxAdapter(child: SizedBox(height: ZSpace.x3)),
                ...sectionsAsync.when(
                  loading: () => [
                    const SliverToBoxAdapter(child: _HomeSkeleton()),
                  ],
                  error: (error, stackTrace) => [
                    SliverToBoxAdapter(
                      child: _HomeMessage(
                        child: Column(
                          children: [
                            Text(
                              'somethingWentWrong'.tr(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: ZSpace.x3),
                            SizedBox(
                              width: 140,
                              child: PrimaryButton(
                                buttonTitle: 'retry'.tr(),
                                action: () =>
                                    ref.invalidate(homeSectionsProvider),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  data: (data) => [
                    if (data.sections.isEmpty)
                      SliverToBoxAdapter(
                        child: _HomeMessage(
                          child: Column(
                            children: [
                              Icon(
                                Icons.storefront_outlined,
                                size: 48,
                                color: context.z.ink2,
                              ),
                              const SizedBox(height: ZSpace.x3),
                              Text(
                                'homeEmpty'.tr(),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(color: context.z.ink2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    for (final (i, section) in data.sections.indexed) ...[
                      if (section.type == 'category_tabs' &&
                          section.config.boolean('sticky') == true)
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: StickyCategoryTabsDelegate(
                            section,
                            onHero: tabsOnHero && i == 0,
                          ),
                        )
                      else if (section.type == 'category_tabs')
                        SliverToBoxAdapter(
                          child: CategoryTabsSection(
                            section: section,
                            onHero: tabsOnHero && i == 0,
                          ),
                        )
                      else
                        SliverToBoxAdapter(
                          // Sections rise in one after another as they
                          // first appear.
                          child: ZEntrance(
                            index: math.min(i, 6),
                            child: HomeSectionWidget(
                              section: section,
                              categoriesById: data.categoriesById,
                              productsById: data.productsById,
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: ZSpace.x4),
                      ),
                    ],
                    // Room for the floating cart bar so the last section
                    // isn't hidden behind it.
                    const SliverToBoxAdapter(
                      child: SizedBox(height: ZSize.cartBar + ZSpace.x6),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Positioned(
            left: ZSpace.screen,
            right: ZSpace.screen,
            // 12px above the nav bar, per docs/mockups/zyppi.css .cartbar.
            bottom: ZSpace.x3,
            child: FloatingCartBar(textured: true),
          ),
        ],
      ),
    );
  }
}

/// The pinned header: transparent over the hero panel while full; as it
/// folds to the search bar, its own textured strip fades in so content
/// scrolling underneath stays hidden.
class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  _HomeHeaderDelegate({
    required this.maxHeight,
    required this.minHeight,
    this.roundPinned = true,
  });

  final double maxHeight, minHeight;

  /// Round the folded strip's bottom corners (off when a pinned category
  /// strip continues the purple below it).
  final bool roundPinned;

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final p = (shrinkOffset / (maxHeight - minHeight)).clamp(0.0, 1.0);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (p > 0)
          Opacity(
            opacity: p,
            child: ZBrandTexture(
              borderRadius: roundPinned
                  ? const BorderRadius.vertical(
                      bottom: Radius.circular(ZRadius.heroPinned),
                    )
                  : BorderRadius.zero,
            ),
          ),
        // Anchored to the bottom so the search bar always sits there; if
        // the text-scale estimate is off, the top is clipped rather than
        // overflowing.
        ClipRect(
          child: OverflowBox(
            alignment: Alignment.bottomCenter,
            minHeight: 0,
            maxHeight: double.infinity,
            child: HomeScreenHeader(collapse: p, background: false),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(_HomeHeaderDelegate old) =>
      old.maxHeight != maxHeight ||
      old.minHeight != minHeight ||
      old.roundPinned != roundPinned;
}

/// Centred empty / error content below the hero panel.
class _HomeMessage extends StatelessWidget {
  const _HomeMessage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      ZSpace.x4,
      ZSpace.x8,
      ZSpace.x4,
      ZSpace.x4,
    ),
    child: child,
  );
}

/// Banner, category grid and a product row, shaped like the loaded page.
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ZSpace.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ZSkeleton(height: 128, radius: ZRadius.card),
          const SizedBox(height: ZSpace.x6),
          const ZSkeleton(width: 160, height: 20),
          const SizedBox(height: ZSpace.x3),
          for (var row = 0; row < 2; row++) ...[
            Row(
              children: [
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(width: ZSpace.x3),
                  Expanded(
                    child: SizedBox(
                      height: ZCategoryTile.height(context),
                      child: const Column(
                        children: [
                          ZSkeleton(
                            height: ZSize.categoryTile,
                            radius: ZRadius.tile,
                          ),
                          SizedBox(height: ZSpace.x2),
                          ZSkeleton(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: ZSpace.x4),
          ],
          const SizedBox(height: ZSpace.x2),
          const ZSkeleton(width: 140, height: 20),
          const SizedBox(height: ZSpace.x3),
          const Row(
            children: [
              Expanded(child: ZProductCardSkeleton()),
              SizedBox(width: ZSpace.x3),
              Expanded(child: ZProductCardSkeleton()),
            ],
          ),
        ],
      ),
    );
  }
}
