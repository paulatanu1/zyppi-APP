import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/constants/colors.dart';
import 'package:zippy/features/HomeScreen/provider/addressProvider.dart';
import 'package:zippy/features/HomeScreen/widgets/searchPlacesWidget.dart';
import 'package:zippy/features/SearchAddress/provider/placePredictionProvider.dart';

class SearchAddressScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final address = ref.watch(addressProvider);
    final placePrediction = ref.watch(placePredictionProvider);

    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(height * 0.02),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.arrow_back_ios, color: AppColors.blue)),
                  Expanded(child: SearchPlacesWidget(isHome: false)),
                ],
              ),
              SizedBox(height: height * 0.01),
              Visibility(
                  visible: address.isSearchBoxClicked ?? false,
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(color: AppColors.borderColor)),
                    child: ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index) => GestureDetector(
                              onTap: () => ref
                                  .read(placePredictionProvider.notifier)
                                  .placeDetails(
                                      placeId: placePrediction.placePrediction
                                              ?.predictions?[index].placeId ??
                                          placePrediction.placePrediction
                                              ?.predictions?[index].reference,
                                      selectedAddress: placePrediction
                                          .placePrediction
                                          ?.predictions?[index]
                                          .description)
                                  .then((_) => ref
                                      .read(addressProvider.notifier)
                                      .searchBoxClick(false))
                                  .then((_) => context.pop()),
                              child: Padding(
                                padding: EdgeInsets.all(width * 0.01),
                                child: Row(
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      fit: FlexFit.tight,
                                      child: Icon(Icons.location_pin,
                                          color: AppColors.blue),
                                    ),
                                    Flexible(
                                      flex: 7,
                                      fit: FlexFit.tight,
                                      child: Text(placePrediction
                                              .placePrediction
                                              ?.predictions?[index]
                                              .description ??
                                          ''),
                                    )
                                  ],
                                ),
                              ),
                            ),
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: placePrediction
                                .placePrediction?.predictions?.length ??
                            0),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
