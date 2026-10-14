import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/presentation/floating_cart_bar.dart';
import 'package:zippy/core/common_widgets/home_screen_header.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/home_screen/widgets/categories.dart';
import 'package:zippy/features/home_screen/widgets/home_page_products.dart';
import 'package:zippy/features/home_screen/widgets/promo_banner.dart';

/// docs/mockups/Main.dc.html.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HomeScreenHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xxl,
                      AppSpacing.xl,
                      AppSpacing.xxl,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PromoBanner(),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          'shopByCategory'.tr(),
                          style: AppTypography.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.base),
                        const Categories(),
                        const SizedBox(height: AppSpacing.xxl),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'dealsForYou'.tr(),
                              style: AppTypography.titleMedium,
                            ),
                            GestureDetector(
                              onTap: () => context.push('/exploreScreen'),
                              child: Text(
                                'seeAll'.tr(),
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.base),
                        HomePageProducts(
                          onClicked: (productId) => context.push(
                            '/productDetailsScreen?productId=$productId',
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            bottom: AppSpacing.giant,
            child: const FloatingCartBar(),
          ),
        ],
      ),
    );
  }
}
