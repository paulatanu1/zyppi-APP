import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/core/common_widgets/category_card.dart';
import 'package:zippy/core/common_widgets/common_header.dart';
import 'package:zippy/core/common_widgets/text_form_field.dart';
import 'package:zippy/features/explore/application/explore_provider.dart';
import 'package:zippy/core/constants/colors.dart';

class ExploreScreen extends ConsumerWidget {
  ExploreScreen({super.key});

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;

    final exploreItems = ref.watch(exploreNotifier);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.h),
          child: Column(
            children: [
              CommonHeader(),
              SizedBox(height: 13.h),
              TextformField(
                //Here
                prefixIcon: true,
                textFormFieldController: searchController,
                labelText: 'searchStore'.tr(),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: GridView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5.h,
                    mainAxisSpacing: 5.h,
                  ),
                  itemCount: exploreItems.explore.length,
                  itemBuilder: (context, index) {
                    return CategoryCard(
                      categoryText: exploreItems.explore[index].name ?? '',
                      imageUrl: exploreItems.explore[index].image ?? '',
                      backgroundColor:
                          exploreItems.explore[index].color ?? AppColors.grey,
                      borderColor:
                          exploreItems.explore[index].borderColor ??
                          AppColors.grey,
                    );
                  },
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
