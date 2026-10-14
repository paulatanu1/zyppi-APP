import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/features/edit_profile/presentation/edit_profile_screen.dart';
import 'package:zippy/features/my_address/presentation/my_address_screen.dart';
import 'package:zippy/features/your_order/presentation/your_order_screen.dart';
import 'package:zippy/features/account/presentation/account_screen.dart';
import 'package:zippy/features/auth/login/presentation/login_screen.dart';
import 'package:zippy/features/auth/otp_verification/presentation/otp_verification_screen.dart';
import 'package:zippy/features/category_details/presentation/category_details_screen.dart';
import 'package:zippy/core/common_widgets/nav_bar/presentation/nav_bar.dart';
import 'package:zippy/features/explore/presentation/explore_screen.dart';
import 'package:zippy/features/favourite/presentation/favourite_screen.dart';
import 'package:zippy/features/filter/presentation/filter_screen.dart';
import 'package:zippy/features/home_screen/presentation/home_screen.dart';
import 'package:zippy/features/intro/presentation/slider/slider.dart';
import 'package:zippy/features/my_cart/presentation/my_cart_screen.dart';
import 'package:zippy/features/product_details/presentation/product_details_screen.dart';
import 'package:zippy/features/search_address/presentation/search_address_screen.dart';

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
          },
        ),
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
        ),
      ],
    );
  }
}
