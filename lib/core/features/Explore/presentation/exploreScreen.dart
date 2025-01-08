import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/core/features/CommonWidgets/categoryCard.dart';
import 'package:zippy/core/features/CommonWidgets/commonHeader.dart';
import 'package:zippy/core/features/CommonWidgets/textFormField.dart';
import 'package:zippy/core/features/Explore/provider/exploreProvider.dart';
import 'package:zippy/Utils/colors.dart';

class ExploreScreen extends ConsumerWidget {
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
                        borderColor: exploreItems.explore[index].borderColor ??
                            AppColors.grey);
                  },
                ),
              ),
              SizedBox(height: height * 0.08)
            ],
          ),
        ),
      ),
    );
  }
}
