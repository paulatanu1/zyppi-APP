import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/constants/colors.dart';
import 'package:zippy/core/sharedProviders/Location/provider/getCurrentLocationProvider.dart';

class AddAndCurrentWidget extends ConsumerWidget {
  bool isAddAddress;

  AddAndCurrentWidget({required this.isAddAddress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    // TODO: implement build
    return GestureDetector(
        onTap: () => isAddAddress == false
            ? ref.read(currentLocation.notifier).getCurrentLocation()
            : context.pushNamed('SearchAddressScreen', extra: isAddAddress),
        child: Container(
          height: height * 0.065,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.all(Radius.circular(width * 0.04)),
            border: Border.all(color: AppColors.borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: Center(
                  child: isAddAddress == false
                      ? Padding(
                          padding: EdgeInsets.fromLTRB(width * 0.028,
                              height * 0.01, width * 0.028, height * 0.01),
                          child: Container(
                            height: height,
                            decoration: BoxDecoration(
                                color: AppColors.bottomSheet,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(width * 0.02))),
                          ),
                        )
                      : Icon(Icons.add, color: AppColors.blue),
                ),
              ),
              Flexible(
                flex: 6,
                fit: FlexFit.tight,
                child: isAddAddress == false
                    ? Text(
                        'Use current location',
                        style: TextStyle(
                            color: AppColors.blue,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add new address',
                            style: TextStyle(
                                color: AppColors.blue,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600),
                          ),
                          Icon(Icons.arrow_forward_ios, color: AppColors.blue)
                        ],
                      ),
              ),
            ],
          ),
        ));
  }
}
