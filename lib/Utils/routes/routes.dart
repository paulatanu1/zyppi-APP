import 'package:go_router/go_router.dart';
import 'package:zippy/core/features/Account/presentation/accountScreen.dart';
import 'package:zippy/core/features/Auth/Login/presentation/loginScreen.dart';
import 'package:zippy/core/features/Auth/OTPVerification/presentation/otpVerificationScreen.dart';
import 'package:zippy/core/features/CategoryDetails/presentation/category_details_screen.dart';
import 'package:zippy/core/features/CommonWidgets/navBar/presentation/navBar.dart';
import 'package:zippy/core/features/Explore/presentation/exploreScreen.dart';
import 'package:zippy/core/features/Favourite/presentation/favourite_screen.dart';
import 'package:zippy/core/features/Filter/presentation/filter_screen.dart';
import 'package:zippy/core/features/HomeScreen/presentation/homeScreen.dart';
import 'package:zippy/core/features/Intro/presentation/Slider/slider.dart';
import 'package:zippy/core/features/MyCart/presentation/my_cart_screen.dart';
import 'package:zippy/core/features/ProductDetails/presentation/productDetails_screen.dart';

//class AppRoutes {
final GoRouter router =
    GoRouter(initialLocation: '/navBar', routes: <RouteBase>[
  GoRoute(
    path: '/slider',
    name: 'Slider',
    builder: (context, state) => Slider(),
  ),
  GoRoute(
    path: '/loginScreen',
    name: 'LoginScreen',
    builder: (context, state) => LoginScreen(),
  ),
  GoRoute(
    path: '/otpVerificationScreen',
    name: 'OtpVerificationScreen',
    builder: (context, state) => OtpVerificationScreen(),
  ),
  GoRoute(
    path: '/navBar',
    name: 'NavigationBar',
    builder: (context, state) {
      final index = state.uri.queryParameters['index'] != null ? int.parse(state.uri.queryParameters['index']!) : 0;
      return NavBar(initialIndex: index);
    },
  ),
  GoRoute(
    path: '/homeScreen',
    name: 'HomeScreen',
    builder: (context, state) => HomeScreen(),
  ),
  GoRoute(
    path: '/exploreScreen',
    name: 'ExploreScreen',
    builder: (context, state) => ExploreScreen(),
  ),
  GoRoute(
    path: '/productDetailsScreen',
    name: 'ProductDetailsScreen',
    builder: (context, state) => ProductDetailsScreen(),
  ),
  GoRoute(
    path: '/categoryDetailsScreen',
    name: 'CategoryDetailsScreen',
    builder: (context, state) => CategoryDetailsScreen(),
  ),
  GoRoute(
    path: '/filterScreen',
    name: 'FilterScreen',
    builder: (context, state) => FilterScreen(),
  ),
  GoRoute(
    path: '/favouriteScreen',
    name: 'FavouriteScreen',
    builder: (context, state) => FavouriteScreen(),
  ),
  GoRoute(
    path: '/myCartScreen',
    name: 'MyCartScreen',
    builder: (context, state) => MyCartScreen(),
  ),
  GoRoute(
    path: '/accountScreen',
    name: 'AccountScreen',
    builder: (context, state) => AccountScreen(),
  )
]);
//}
