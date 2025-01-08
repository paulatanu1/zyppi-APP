import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/features/CommonWidgets/primaryButton.dart';
import 'package:zippy/core/features/Favourite/widgets/favourite_item.dart';
import 'package:zippy/Utils/colors.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

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
                'favourite'.tr(),
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
                  physics: BouncingScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (BuildContext context, int index) {
                    return FavouriteItem();
                  }),
            ),
            Padding(
              padding: EdgeInsets.all(height * 0.025),
              child: PrimaryButton(
                  buttonTitle: 'addAllToCart'.tr(), action: () {}),
            ),
            SizedBox(height: height * 0.08)
          ],
        ),
      ),
    );
  }
}
