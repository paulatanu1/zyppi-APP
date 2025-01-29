import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/core/commonWidgets/primaryButton.dart';
import 'package:zippy/core/constants/colors.dart';
import 'package:zippy/core/sharedProviders/Location/provider/checkLocationPermissionProvider.dart';
import 'package:zippy/core/sharedProviders/Location/provider/requestLocationProvider.dart';

class LocationAndSavedAddressWidget extends ConsumerWidget {
  final bool? isLocationEnabled;

  LocationAndSavedAddressWidget({required this.isLocationEnabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final checkLocation = ref.watch(checkLocationPermission);
    

    // TODO: implement build
    return Container(
      width: double.infinity,
      height: height * 0.09,
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(width * 0.05)),
          border: Border.all(color: AppColors.borderColor, width: 1.5)),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: isLocationEnabled == true
                ? Image.asset('assets/icons/locationPin.png')
                : Padding(
                    padding: EdgeInsets.fromLTRB(width * 0.028, height * 0.01,
                        width * 0.028, height * 0.03),
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                          color: AppColors.bottomSheet,
                          borderRadius:
                              BorderRadius.all(Radius.circular(width * 0.02))),
                    ),
                  ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                  // color: Colors.green,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(width * 0.05),
                      bottomRight: Radius.circular(width * 0.05))),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: height * 0.005, bottom: height * 0.005),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              constraints: BoxConstraints(maxWidth: 500),
                              child: Text(
                                  isLocationEnabled == true
                                      ? checkLocation.isEnabled == true 
                                          ? 'Device location enabled'
                                          : 'Device location not enabled'
                                      : 'Home',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                      fontSize: 25)),
                            ),
                          ),
                          SizedBox(height: height * 0.005),
                          Flexible(
                            flex: 1,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: EdgeInsets.only(right: width * 0.1),
                                child: Text(
                                    'Enable for a better delivery experience',
                                    style: TextStyle(
                                        fontFamily: 'Poppins', fontSize: 20)),
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.005),
                          Flexible(
                            flex: 1,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: EdgeInsets.only(right: width * 0.1),
                                child: Text(
                                    'Enable for a better delivery experience',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                        fontSize: 18)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: isLocationEnabled == true
                        ? Padding(
                            padding: EdgeInsets.only(
                                left: width * 0.05,
                                top: height * 0.018,
                                right: width * 0.02,
                                bottom: height * 0.018),
                            child: PrimaryButton(
                              buttonTitle:
                                  checkLocation.isEnabled == true ? 'Enabled' : 'Enable',
                              buttonColor: checkLocation == true
                                  ? AppColors.borderColor
                                  : AppColors.blue,
                              fontSize: 12,
                              borderRadius: width * 0.03,
                              action: checkLocation.isEnabled == true
                                  ? () {}
                                  : () => ref
                                      .read(checkAndRequestLocation.notifier)
                                      .checkAndRequestLocationPermission(),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.more_vert,
                                      color: AppColors.blue)),
                            ],
                          ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
