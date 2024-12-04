import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/CommonWidgets/addButton.dart';
import 'package:zippy/Utils/colors.dart';

class ItemCard extends StatelessWidget {
  final String? productName;
  final String? quantity;
  final String? price;

  ItemCard({required this.productName, this.quantity, this.price});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: 120.h,
      width: 360.w,
      margin: EdgeInsets.only(left: 10.w, top: 10.h, right: 10.w),
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 25.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.sp),
          border: Border.all(color: AppColors.grey)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 3,
            fit: FlexFit.loose,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/item.png'),
                Text(productName ?? '',
                    // textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 30.sp,
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins')),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(quantity ?? '',
                        style: TextStyle(
                            fontSize: 30.sp,
                            color: AppColors.grey,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins')),
                  ],
                )
              ],
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₹${price ?? ''}',
                    style: TextStyle(
                        fontSize: 40.sp,
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins')),
                AddButton()
              ],
            ),
          )
        ],
      ),
    );
  }
}
