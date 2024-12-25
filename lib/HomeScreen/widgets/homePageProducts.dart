import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/CommonWidgets/itemCard.dart';

class HomePageProducts extends StatelessWidget {
  final Function()? onClicked;
  HomePageProducts({super.key,this.onClicked});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.h,
          mainAxisSpacing: 8.h,
          childAspectRatio: 0.8),
      itemCount: 9,
      itemBuilder: (context, index) {
        return ItemCard(
          onClicked: onClicked,
            productName: 'Fresh Apple Juice', quantity: '2L', price: '80');
      },
    );
  }
}
