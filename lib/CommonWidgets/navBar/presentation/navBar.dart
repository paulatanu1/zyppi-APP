import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/Account/presentation/accountScreen.dart';
import 'package:zippy/CommonWidgets/navBar/provider/navBarProvider.dart';
import 'package:zippy/Explore/presentation/exploreScreen.dart';
import 'package:zippy/Favourite/presentation/favourite_screen.dart';
import 'package:zippy/HomeScreen/presentation/homeScreen.dart';
import 'package:zippy/MyCart/presentation/my_cart_screen.dart';
import 'package:zippy/Utils/colors.dart';

class NavBar extends ConsumerWidget {
  final int initialIndex;

  NavBar({this.initialIndex = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = MediaQuery.of(context).size.height;
    final currentIndex = ref.watch(navBarProvider);
    final changeIndex = ref.read(navBarProvider.notifier);

    final items = List.generate(
      5,
      (i) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/${[
              'homeIcon',
              'exploreIcon',
              'cartIcon',
              'favouriteIcon',
              'profileIcon'
            ][i]}.png',
            height: height * 0.04,
          ),
          if (currentIndex != i) SizedBox(height: 0.2),
          if (currentIndex != i)
            Text(
              ['Home', 'Explore', 'Cart', 'Favourite', 'Account'][i],
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins'),
            ),
        ],
      ),
    );

    final screens = [
      HomeScreen(),
      ExploreScreen(), //This is the page in question
      MyCartScreen(),
      FavouriteScreen(),
      AccountScreen()
    ];

    // TODO: implement build
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // This will exit the app on Android
        return true;
      },
      child: Scaffold(
          extendBody: false,
          body: Stack(
            children: [
              screens[currentIndex],
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(80),
                          topRight: Radius.circular(200))),
                  child: CurvedNavigationBar(
                    items: items,
                    index: currentIndex,
                    height: 55,
                    color: AppColors.blue,
                    backgroundColor: Colors.transparent,
                    onTap: (index) => changeIndex.updateIndex(index),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
