import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/constants/colors.dart';
import 'package:zippy/core/constants/googleApiKey.dart';
import 'package:zippy/features/HomeScreen/provider/addressProvider.dart';
import 'package:zippy/features/SearchAddress/provider/placePredictionProvider.dart';

// class SearchPlacesWidget extends ConsumerWidget {
//   bool? isHome;

//   SearchPlacesWidget({required this.isHome});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;

//     final addressNotifier = ref.read(addressProvider.notifier);

//     // TODO: implement build
//     return Container(
//       height: height * 0.065,
//       width: double.infinity,
//       decoration: BoxDecoration(
//           color: AppColors.white,
//           borderRadius: BorderRadius.all(Radius.circular(width * 0.04)),
//           border: Border.all(color: AppColors.borderColor, width: 1.5)),
//       child: Row(
//         children: [
//           Flexible(
//             flex: 1,
//             fit: FlexFit.loose,
//             child: Center(child: Image.asset('assets/icons/searchAddress.png')),
//           ),
//           Flexible(
//             flex: 6,
//             fit: FlexFit.tight,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search for area, street name...',
//                       hintStyle: TextStyle(
//                           color: AppColors.grey, fontFamily: 'Poppins'),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.zero,
//                     ),
//                     onChanged: (value) {
//                       addressNotifier.searchBoxClick(value.isNotEmpty);
//                     },
//                     style:
//                         TextStyle(fontFamily: 'Poppins', color: Colors.black),
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

class SearchPlacesWidget extends ConsumerStatefulWidget {
  final bool? isHome;

  const SearchPlacesWidget({required this.isHome, Key? key}) : super(key: key);

  @override
  ConsumerState<SearchPlacesWidget> createState() => _SearchPlacesWidgetState();
}

class _SearchPlacesWidgetState extends ConsumerState<SearchPlacesWidget> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final addressNotifier = ref.read(addressProvider.notifier);
    final placePrediction = ref.watch(placePredictionProvider);

    return GestureDetector(
      onTap: () =>
          widget.isHome! ? context.pushNamed('SearchAddressScreen') : () {},
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
                child: Image.asset('assets/icons/searchAddress.png'),
              ),
            ),
            Flexible(
              flex: 6,
              fit: FlexFit.tight,
              child: widget.isHome!
                  ? Text(
                      placePrediction.selectedAddress ??
                          'Search for area, street name...',
                      style: TextStyle(
                          color: AppColors.grey,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis),
                    )
                  : TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for area, street name...',
                        hintStyle: TextStyle(
                          color: AppColors.grey,
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          ref
                              .read(placePredictionProvider.notifier)
                              .placePrediction(input: value);
                        }
                        {
                          addressNotifier.searchBoxClick(value.isNotEmpty);
                        }
                      },
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.black,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
