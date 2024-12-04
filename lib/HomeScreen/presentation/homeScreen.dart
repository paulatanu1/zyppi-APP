import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/CommonWidgets/categoryCard.dart';
import 'package:zippy/CommonWidgets/itemCard.dart';
import 'package:zippy/CommonWidgets/textFormField.dart';
import 'package:zippy/Utils/colors.dart';

class HomeScreen extends StatelessWidget {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        // backgroundColor: const Color.fromARGB(255, 157, 198, 232),
        body: ItemCard(
            productName: 'Fresh Apple Juice', quantity: '2L', price: '80'),

        // ListView(
        //   children: [
        //     SizedBox(height: 20),
        //     TextformField(
        //       textFormFieldController: controller,
        //       labelText: 'Search, oil, rice',
        //       prefixIcon: true,
        //     ),
        //     SizedBox(height: 20),
        //     Padding(
        //       padding: EdgeInsets.symmetric(horizontal: 30.w),
        //       child: SizedBox(
        //         height: 180.h,
        //         child: GridView.builder(
        //           itemCount: 8,
        //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //               crossAxisCount: 2,
        //               mainAxisSpacing: 8.h,
        //               crossAxisSpacing: 25.w),
        //           itemBuilder: (context, index) => CategoryCard(
        //             categoryText: 'Fresh Fruits & Vegetables',
        //             index: index,
        //           ),
        //         ),
        //       ),
        //     ),
        //     SizedBox(height: 20),
        //     ItemCard(),
        //     SizedBox(height: 20),
        //   ],
        // ),
      ),
    );
  }
}
