import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/core/constants/colors.dart';
import 'package:zippy/core/sharedProviders/Location/provider/getCurrentLocationProvider.dart';
import 'package:zippy/features/HomeScreen/provider/addressProvider.dart';
import 'package:zippy/features/HomeScreen/widgets/addressSheet.dart';

class HomeScreenHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getCurrentLocation = ref.watch(currentLocation);
    final address = ref.watch(addressProvider);

    return SizedBox(
      width: double.infinity,
      child: Row(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(4.h),
            ),
            child: Padding(
              padding: EdgeInsets.all(3.h),
              child: Image.asset(
                "assets/images/Zyppi_logo_white.png",
                height: 18.h,
                width: 45.h,
              ),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
              child: GestureDetector(
            onTap: () => bottomSheet(context, ref),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'deliveryTo'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 30.sp,
                          color: AppColors.black,
                          fontFamily: "Poppins",
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'home'.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                              color: AppColors.black,
                              fontSize: 30.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 10.h,
                    )
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  getCurrentLocation.isDetecting == true
                      ? ''
                      : getCurrentLocation.address ?? '',
                  style: TextStyle(
                    fontSize: 25.sp,
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
