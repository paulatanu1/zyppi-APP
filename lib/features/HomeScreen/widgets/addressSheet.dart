import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/features/HomeScreen/widgets/addAndCurrentWidget.dart';
import 'package:zippy/features/HomeScreen/widgets/locationAndSavedAddressWidget.dart';
import 'package:zippy/core/constants/colors.dart';
import 'package:zippy/features/HomeScreen/widgets/searchPlacesWidget.dart';

void bottomSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows the bottom sheet to grow dynamically
    backgroundColor: AppColors.bottomSheet,
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppColors.bottomSheet,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(MediaQuery.of(context).size.width * 0.1),
            topRight: Radius.circular(MediaQuery.of(context).size.width * 0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LocationAndSavedAddressWidget(isLocationEnabled: true),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                child: Text(
                  'Select Address',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            SearchPlacesWidget(isHome: true),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            AddAndCurrentWidget(isAddAddress: false),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            AddAndCurrentWidget(isAddAddress: true),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                child: Text(
                  'Your saved addresses',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            LocationAndSavedAddressWidget(isLocationEnabled: false),
          ],
        ),
      );
      //   },
      // );
    },
  );
}
