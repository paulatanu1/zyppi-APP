import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/core/features/CommonWidgets/itemCard.dart';

class HomePageProducts extends StatelessWidget {
  final Function()? onClicked;
  HomePageProducts({super.key, this.onClicked});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: width * 0.04,
          mainAxisSpacing: height * 0.02,
          childAspectRatio: 0.75),
      itemCount: 9,
      itemBuilder: (context, index) {
        return ItemCard(
            onClicked: onClicked,
            productName: 'Fresh Apple Juice',
            quantity: '2L',
            price: '80');
      },
    );
  }
}
