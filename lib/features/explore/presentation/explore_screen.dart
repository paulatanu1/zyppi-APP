import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/app_skeleton.dart';
import 'package:zippy/core/common_widgets/category_card.dart';
import 'package:zippy/core/common_widgets/common_header.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/common_widgets/text_form_field.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/explore/application/explore_provider.dart';

class ExploreScreen extends ConsumerWidget {
  ExploreScreen({super.key});

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exploreState = ref.watch(exploreNotifier);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonHeader(),
              const SizedBox(height: AppSpacing.lg),
              GestureDetector(
                onTap: () => context.push('/searchScreen'),
                child: AbsorbPointer(
                  child: TextformField(
                    prefixIcon: true,
                    textFormFieldController: searchController,
                    labelText: 'searchStore'.tr(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (exploreState.error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'somethingWentWrong'.tr(),
                          style: AppTypography.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          width: 160,
                          child: PrimaryButton(
                            buttonTitle: 'retry'.tr(),
                            action: () =>
                                ref.read(exploreNotifier.notifier).retry(),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: AppSkeleton(
                    enabled: exploreState.loading,
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.lg,
                            childAspectRatio: 0.78,
                          ),
                      itemCount: exploreState.loading
                          ? 8
                          : exploreState.categories.length,
                      itemBuilder: (context, index) {
                        final category = exploreState.loading
                            ? Category(
                                id: '',
                                name: 'Category',
                                image: 'assets/images/category.png',
                                colorHex: 'FFEDF7FD',
                                borderColorHex: 'FF52BAF4',
                              )
                            : exploreState.categories[index];

                        return CategoryCard(
                          categoryText: category.name,
                          imageUrl: category.image,
                          backgroundColor: AppColors.fromHex(category.colorHex),
                          onTap: exploreState.loading
                              ? null
                              : () => context.push(
                                  '/categoryDetailsScreen?categoryId=${category.id}',
                                ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
