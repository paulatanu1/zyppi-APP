import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/Utils/colors.dart';

class HomeScreenHeader extends StatefulWidget {
  const HomeScreenHeader({super.key});

  @override
  State<HomeScreenHeader> createState() => _HomeScreenHeaderState();
}

class _HomeScreenHeaderState extends State<HomeScreenHeader> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
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
                height: 20.h,
                width: 60.h,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child:Column(
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
                              fontSize: 35.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 10.h,
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                    ),
                  ],
                ),
                _isExpanded
                    ? Text(
                  "AF 305, Hanpara, kestopur, Hanpara, 7001....",
                  style: TextStyle(
                    fontSize: 25.sp,
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
                    : SizedBox.shrink(),
              ],
            )

          ),
        ],
      ),
    );
  }
}
