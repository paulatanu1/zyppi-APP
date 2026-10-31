import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/cart/presentation/floating_cart_bar.dart';
import 'package:zippy/core/common_widgets/app_skeleton.dart';
import 'package:zippy/core/common_widgets/home_screen_header.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/home_screen/application/home_sections_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zippy/features/home_screen/widgets/sections/home_section_widget.dart';

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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HomeScreenHeader(),
                  const SizedBox(height: AppSpacing.base),
                  sectionsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                      child: AppSkeleton(
                        enabled: true,
                        child: SizedBox(height: 400),
                      ),
                    ),
                    error: (error, stackTrace) => Padding(
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
                    data: (data) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final section in data.sections) ...[
                          HomeSectionWidget(
                            section: section,
                            categoriesById: data.categoriesById,
                            productsById: data.productsById,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                        const SizedBox(height: 100),
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
