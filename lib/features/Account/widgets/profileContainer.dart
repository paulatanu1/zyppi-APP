import 'package:flutter/material.dart';
import 'package:zippy/core/constants/colors.dart';
import 'package:zippy/features/Account/widgets/profileContainerItem.dart';

class ProfileContainer extends StatelessWidget {
  final String ContainerName;
  final List containerList;
  final Function()? onClicked;
  const ProfileContainer({super.key, required this.ContainerName, required this.containerList,  this.onClicked});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
            height: height * 0.32,
            width: width,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.lightBlue1,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: Padding(
              padding:  EdgeInsets.only(top: height*0.02),
              child: ListView.builder(
                  itemCount: containerList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ProfileContainerItem(
                      onClicked: onClicked,
                      itemName: containerList[index].toString(),);
                  }),
            )),
        // Positioned text on the border
        Positioned(
          top: -10,
          left: width * 0.1,
          child: Container(
            padding: EdgeInsets.only(
                left: height * 0.025,
                right: height * 0.025,
                top: height * 0.003,
                bottom: height * 0.003),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.lightBlue1,
                width: 1.0,
              ),
              color: AppColors.white,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Text(
              ContainerName,
              style: TextStyle(
                color: AppColors.lightBlack,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
