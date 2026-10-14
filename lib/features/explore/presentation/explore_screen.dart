import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/app_skeleton.dart';
import 'package:zippy/core/common_widgets/category_card.dart';
import 'package:zippy/core/common_widgets/common_header.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/common_widgets/text_form_field.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/explore/application/explore_provider.dart';

class ExploreScreen extends ConsumerWidget {
  ExploreScreen({super.key});

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;

    final exploreState = ref.watch(exploreNotifier);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.h),
          child: Column(
            children: [
              CommonHeader(),
              SizedBox(height: 13.h),
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
              SizedBox(height: 10.h),
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
                        SizedBox(height: 10.h),
                        SizedBox(
                          width: 160.w,
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
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 5.h,
                        mainAxisSpacing: 5.h,
                      ),
                      itemCount: exploreState.loading
                          ? 6
                          : exploreState.categories.length,
                      itemBuilder: (context, index) {
                        final category = exploreState.loading
                            ? Category(
                                id: '',
                                name: 'Category name',
                                image: 'assets/images/category.png',
                                colorHex: 'FFEDF7FD',
                                borderColorHex: 'FF52BAF4',
                              )
                            : exploreState.categories[index];

                        return CategoryCard(
                          categoryText: category.name,
                          imageUrl: category.image,
                          backgroundColor: AppColors.fromHex(category.colorHex),
                          borderColor: AppColors.fromHex(
                            category.borderColorHex,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              SizedBox(height: height * 0.08),
            ],
          ),
        ),
      ),
    );
  }
}
