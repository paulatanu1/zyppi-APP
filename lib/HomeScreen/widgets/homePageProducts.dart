import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/CommonWidgets/itemCard.dart';

class HomePageProducts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // return ItemCard(
    //         productName: 'Fresh Apple Juice', quantity: '2L', price: '80');
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.h,
          mainAxisSpacing: 8.h,
          childAspectRatio: 0.66),
      itemCount: 9,
      itemBuilder: (context, index) {
        return ItemCard(
            productName: 'Fresh Apple Juice', quantity: '2L', price: '80');
      },
    );
  }
}
