import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/data/provider/sharedPreferenceProvider.dart';
import 'package:zippy/core/features/EditProfile/presentation/editProfileScreen.dart';
import 'package:zippy/core/features/MyAddress/presentation/myAddressScreen.dart';
import 'package:zippy/core/features/YourOrder/presentation/yourOrderScreen.dart';
import 'package:zippy/features/Account/presentation/accountScreen.dart';
import 'package:zippy/features/Auth/Login/presentation/loginScreen.dart';
import 'package:zippy/features/Auth/OTPVerification/presentation/otpVerificationScreen.dart';
import 'package:zippy/features/CategoryDetails/presentation/category_details_screen.dart';
import 'package:zippy/core/commonWidgets/navBar/presentation/navBar.dart';
import 'package:zippy/features/Explore/presentation/exploreScreen.dart';
import 'package:zippy/features/Favourite/presentation/favourite_screen.dart';
import 'package:zippy/features/Filter/presentation/filter_screen.dart';
import 'package:zippy/features/HomeScreen/presentation/homeScreen.dart';
import 'package:zippy/features/Intro/presentation/Slider/slider.dart';
import 'package:zippy/features/MyCart/presentation/my_cart_screen.dart';
import 'package:zippy/features/ProductDetails/presentation/productDetails_screen.dart';
import 'package:zippy/features/SearchAddress/presentation/searchAddressScreen.dart';

class Routes {
  final ProviderContainer container;

  Routes(this.container);

  Future<String> _getInitialRoute() async {
    final sharedPrefState = container.read(sharedPreferenceProvider);
    await container.read(sharedPreferenceProvider.notifier).getLocalStorage();

    final token = sharedPrefState.authToken;
    return (token == null || token.isEmpty) ? '/slider' : '/navBar';
  }

  Future<GoRouter> getRouter() async {
    final initialRoute = await _getInitialRoute();
    // final initialRoute = '/navBar';

    return GoRouter(
      initialLocation: initialRoute,
      routes: <RouteBase>[
        GoRoute(
          path: '/slider',
          name: 'Slider',
          builder: (context, state) => SliderScreen(),
        ),
        GoRoute(
          path: '/loginScreen',
          name: 'LoginScreen',
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: '/otpVerificationScreen',
          name: 'OtpVerificationScreen',
          builder: (context, state) {
            final phoneNumber = state.uri.queryParameters['phoneNumber'];
            return OtpVerificationScreen(phoneNumber: phoneNumber);
          },
        ),
        GoRoute(
          path: '/navBar',
          name: 'NavigationBar',
          builder: (context, state) {
            final index = state.uri.queryParameters['index'] != null
                ? int.parse(state.uri.queryParameters['index']!)
                : 0;
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
        ),
        GoRoute(
            path: '/searchAddressScreen',
            name: 'SearchAddressScreen',
            builder: (context, state) {
              final bool addLocation = state.extra as bool;
              return SearchAddressScreen(addLocation: addLocation);
            }),
        GoRoute(
          path: '/myAddressScreen',
          name: 'MyAddressScreen',
          builder: (context, state) => MyAddressScreen(),
        ),
        GoRoute(
          path: '/yourOrderScreen',
          name: 'YourOrderScreen',
          builder: (context, state) => YourOrderScreen(),
        ),
        GoRoute(
          path: '/editProfileScreen',
          name: 'EditProfileScreen',
          builder: (context, state) => EditProfileScreen(),
        )
      ],
    );
  }
}
