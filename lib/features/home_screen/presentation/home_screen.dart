import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/cart/presentation/floating_cart_bar.dart';
import 'package:zippy/core/common_widgets/app_skeleton.dart';
import 'package:zippy/core/common_widgets/home_screen_header.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/zyppi_tokens.dart';
import 'package:zippy/features/home_screen/application/home_sections_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zippy/features/home_screen/widgets/sections/category_tabs_section.dart';
import 'package:zippy/features/home_screen/widgets/sections/home_section_widget.dart';
import 'package:zippy/features/home_screen/widgets/sections/section_data.dart';

/// Backend/admin-driven Home screen — renders `home_sections` in order
/// (see docs/PLAN.md's Blinkit-referenced redesign note). The delivery
/// header and search stay fixed app chrome, not admin content.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(homeSectionsProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
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
                return ref
                    .read(homeSectionsProvider.future)
                    .then((_) {}, onError: (_) {});
              },
              // Slivers so a `config.sticky` category_tabs section can pin.
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  const SliverToBoxAdapter(child: HomeScreenHeader()),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.base),
                  ),
                  ...sectionsAsync.when(
                    loading: () => [
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxl,
                          ),
                          child: AppSkeleton(
                            enabled: true,
                            child: SizedBox(height: 400),
                          ),
                        ),
                      ),
                    ],
                    error: (error, stackTrace) => [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          child: Column(
                            children: [
                              Text(
                                'somethingWentWrong'.tr(),
                                style: AppTypography.bodyMedium,
                              ),
                              const SizedBox(height: AppSpacing.base),
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
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xxl),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.storefront_outlined,
                                  size: 48,
                                  color: context.colors.muted,
                                ),
                                const SizedBox(height: AppSpacing.base),
                                Text(
                                  'homeEmpty'.tr(),
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: context.colors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      for (final section in data.sections) ...[
                        if (section.type == 'category_tabs' &&
                            section.config.boolean('sticky') == true)
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: StickyCategoryTabsDelegate(section),
                          )
                        else
                          SliverToBoxAdapter(
                            child: HomeSectionWidget(
                              section: section,
                              categoriesById: data.categoriesById,
                              productsById: data.productsById,
                            ),
                          ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: AppSpacing.xxl),
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
