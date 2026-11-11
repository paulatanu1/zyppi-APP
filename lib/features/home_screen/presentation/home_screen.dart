import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/cart/presentation/floating_cart_bar.dart';
import 'package:zippy/core/common_widgets/home_screen_header.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/data/delivery_config_repository.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/core/widgets/z_product_card.dart';
import 'package:zippy/features/home_screen/application/buy_again_provider.dart';
import 'package:zippy/features/home_screen/application/home_sections_provider.dart';
import 'package:zippy/features/home_screen/widgets/buy_again_section.dart';
import 'package:zippy/core/data/search_suggestions_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zippy/features/home_screen/widgets/sections/category_tabs_section.dart';
import 'package:zippy/features/home_screen/widgets/sections/home_section_widget.dart';
import 'package:zippy/features/home_screen/widgets/sections/section_data.dart';

/// Backend/admin-driven Home screen — renders `home_sections` in order
/// (see docs/PLAN.md's Blinkit-referenced redesign note). The delivery
/// header and search stay fixed app chrome, not admin content.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (!_scroll.hasClients) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.jumpTo(0);
    } else {
      _scroll.animateTo(0, duration: ZMotion.sheet, curve: ZMotion.emphasized);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sectionsAsync = ref.watch(homeSectionsProvider);
    // A `config.sticky` category_tabs section pins with the search bar.
    final stickyTabs = sectionsAsync.value?.sections
        .where(_isStickyTabs)
        .firstOrNull;

    return Scaffold(
      backgroundColor: context.z.bg,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            // Pull down to refresh: drops the cached catalog too, so new
            // prices/products show without restarting the app.
            child: RefreshIndicator(
              onRefresh: () {
                ref.read(catalogRepositoryProvider).invalidate();
                ref.invalidate(homeSectionsProvider);
                // Picks up a changed delivery fee / free-delivery threshold.
                ref.invalidate(deliveryConfigProvider);
                ref.invalidate(buyAgainProvider);
                return ref
                    .read(homeSectionsProvider.future)
                    .then((_) {}, onError: (_) {});
              },
              // Slivers so a `config.sticky` category_tabs section can pin.
              child: CustomScrollView(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  const SliverToBoxAdapter(child: HomeScreenHeader()),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: HomePinnedHeaderDelegate(
                      tabs: stickyTabs,
                      onSearch: () => context.push('/searchScreen'),
                      onAllTap: _scrollToTop,
                      searchHints:
                          ref.watch(searchSuggestionsProvider).value ??
                          const [],
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: ZSpace.x3)),
                  ...sectionsAsync.when(
                    loading: () => [
                      const SliverToBoxAdapter(child: _HomeSkeleton()),
                    ],
                    error: (error, stackTrace) => [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(ZSpace.x4),
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
                      // The user's own past buys come first.
                      const SliverToBoxAdapter(child: BuyAgainSection()),
                      if (data.sections.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(ZSpace.x4),
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
                      for (final section in data.sections.where(
                        (s) => s != stickyTabs,
                      )) ...[
                        SliverToBoxAdapter(
                          child: HomeSectionWidget(
                            section: section,
                            categoriesById: data.categoriesById,
                            productsById: data.productsById,
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
          ),
          const ZStatusBarStrip(),
          Positioned(
            left: ZSpace.screen,
            right: ZSpace.screen,
            // 12px above the nav bar, per docs/mockups/zyppi.css .cartbar.
            bottom: ZSpace.x3,
            child: const FloatingCartBar(),
          ),
        ],
      ),
    );
  }
}

bool _isStickyTabs(HomeSection s) =>
    s.type == 'category_tabs' && s.config.boolean('sticky') == true;

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
