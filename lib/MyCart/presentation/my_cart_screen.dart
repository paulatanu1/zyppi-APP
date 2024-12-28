import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/CommonWidgets/primaryButton.dart';
import 'package:zippy/MyCart/widgets/my_cart_item.dart';
import 'package:zippy/Utils/colors.dart';

class MyCartScreen extends StatelessWidget {
  const MyCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Text(
                'myCart'.tr(),
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: AppColors.darkBlue,
                    fontStyle: FontStyle.italic,
                    fontSize: 20),
              ),
            ),
            SizedBox(
              height: height * 0.025,
            ),
            Divider(
              height: 1,
              color: AppColors.grey5,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (BuildContext context, int index) {
                    return MyCartItem(
                      crossIconClicked: () {},
                    );
                  }),
            ),
            Padding(
              padding:
                  EdgeInsets.only(left: height * 0.02, right: height * 0.02),
              child: PrimaryButton(
                  buttonTitle: 'goToCheckout'.tr(), action: () {}),
            ),
            SizedBox(height: height * 0.1)
          ],
        ),
      ),
    );
  }
}
