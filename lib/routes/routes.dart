import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/routes/router_refresh_listenable.dart';
import 'package:zippy/features/edit_profile/presentation/edit_profile_screen.dart';
import 'package:zippy/features/my_address/presentation/my_address_screen.dart';
import 'package:zippy/features/your_order/presentation/order_details_screen.dart';
import 'package:zippy/features/your_order/presentation/your_order_screen.dart';
import 'package:zippy/features/account/presentation/account_privacy_screen.dart';
import 'package:zippy/features/account/presentation/account_screen.dart';
import 'package:zippy/features/account/presentation/notification_settings_screen.dart';
import 'package:zippy/features/account/presentation/payment_settings_screen.dart';
import 'package:zippy/features/auth/guest/presentation/guest_upgrade_screen.dart';
import 'package:zippy/features/auth/login/presentation/login_screen.dart';
import 'package:zippy/features/auth/otp_verification/presentation/otp_verification_screen.dart';
import 'package:zippy/features/category_details/presentation/category_details_screen.dart';
import 'package:zippy/core/common_widgets/nav_bar/presentation/nav_bar.dart';
import 'package:zippy/design_v2/home_v2_screen.dart';
import 'package:zippy/features/checkout/presentation/checkout_screen.dart';
import 'package:zippy/features/explore/presentation/explore_screen.dart';
import 'package:zippy/features/favourite/presentation/favourite_screen.dart';
import 'package:zippy/features/filter/presentation/filter_screen.dart';
import 'package:zippy/features/home_screen/presentation/home_screen.dart';
import 'package:zippy/features/intro/presentation/slider/slider.dart';
import 'package:zippy/features/launch/presentation/launch_screen.dart';
import 'package:zippy/core/theme/zyppi_tokens.dart';
import 'package:zippy/features/my_cart/presentation/my_cart_screen.dart';
import 'package:zippy/features/order_placed/presentation/order_placed_screen.dart';
import 'package:zippy/features/order_tracking/presentation/order_tracking_screen.dart';
import 'package:zippy/features/product_details/presentation/product_details_screen.dart';
import 'package:zippy/features/search/presentation/search_screen.dart';
import 'package:zippy/features/search_address/presentation/search_address_screen.dart';
import 'package:zippy/features/support_chat/presentation/support_chat_screen.dart';

const _unauthenticatedRoutes = {
  '/slider',
  '/loginScreen',
  '/otpVerificationScreen',
};

class Routes {
  final ProviderContainer container;

  Routes(this.container);

  late final GoRouterRefreshListenable _refreshListenable =
      GoRouterRefreshListenable(container);

  String? _redirect(GoRouterState state) {
    // The launch animation picks Home or Onboarding itself when it ends.
    if (state.matchedLocation == '/launch') return null;

    // Design playground: dev builds only, never an auth bypass elsewhere.
    if (state.matchedLocation == '/design-v2' && Env.flavor == 'dev') {
      return null;
    }

    final token = container.read(sharedPreferenceProvider).authToken;
    final isLoggedIn = token != null && token.isNotEmpty;
    final isUnauthenticatedRoute = _unauthenticatedRoutes.contains(
      state.matchedLocation,
    );

    if (!isLoggedIn && !isUnauthenticatedRoute) return '/slider';
    if (isLoggedIn && isUnauthenticatedRoute) return '/navBar';

    return null;
  }

  Future<GoRouter> getRouter() async {
    await container.read(sharedPreferenceProvider.notifier).getLocalStorage();

    return GoRouter(
      initialLocation: '/launch',
      refreshListenable: _refreshListenable,
      redirect: (context, state) => _redirect(state),
      routes: <RouteBase>[
        GoRoute(
          path: '/launch',
          name: 'Launch',
          builder: (context, state) => const LaunchScreen(),
        ),
        GoRoute(
          path: '/slider',
          name: 'Slider',
          pageBuilder: (context, state) => _fade(state, SliderScreen()),
        ),
        GoRoute(
          path: '/loginScreen',
          name: 'LoginScreen',
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: '/otpVerificationScreen',
          name: 'OtpVerificationScreen',
          // Without a number there's nothing to verify; start over.
          redirect: (context, state) =>
              (state.uri.queryParameters['phoneNumber'] ?? '').isEmpty
              ? '/loginScreen'
              : null,
          builder: (context, state) => OtpVerificationScreen(
            phoneNumber: state.uri.queryParameters['phoneNumber']!,
          ),
        ),
        GoRoute(
          path: '/navBar',
          name: 'NavigationBar',
          pageBuilder: (context, state) {
            final index =
                int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
            return _fade(state, NavBar(initialIndex: index));
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
          builder: (context, state) {
            final productId = state.uri.queryParameters['productId'] ?? '';
            return ProductDetailsScreen(
              productId: productId,
              heroTag: state.uri.queryParameters['hero'],
            );
          },
        ),
        GoRoute(
          path: '/categoryDetailsScreen',
          name: 'CategoryDetailsScreen',
          builder: (context, state) {
            final categoryId = state.uri.queryParameters['categoryId'] ?? '';
            return CategoryDetailsScreen(categoryId: categoryId);
          },
        ),
        GoRoute(
          path: '/filterScreen',
          name: 'FilterScreen',
          builder: (context, state) => FilterScreen(
            categoryId: state.uri.queryParameters['categoryId'] ?? '',
          ),
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
            // Missing extra (e.g. a deep link or a caller that forgot it)
            // must not crash the screen; default to "save a new address".
            final addLocation = state.extra as bool? ?? true;
            return SearchAddressScreen(addLocation: addLocation);
          },
        ),
        GoRoute(
          path: '/guestUpgradeScreen',
          name: 'GuestUpgradeScreen',
          builder: (context, state) => const GuestUpgradeScreen(),
        ),
        GoRoute(
          path: '/paymentSettingsScreen',
          name: 'PaymentSettingsScreen',
          builder: (context, state) => const PaymentSettingsScreen(),
        ),
        GoRoute(
          path: '/notificationSettingsScreen',
          name: 'NotificationSettingsScreen',
          builder: (context, state) => const NotificationSettingsScreen(),
        ),
        GoRoute(
          path: '/accountPrivacyScreen',
          name: 'AccountPrivacyScreen',
          builder: (context, state) => const AccountPrivacyScreen(),
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
        GoRoute(
          path: '/searchScreen',
          name: 'SearchScreen',
          builder: (context, state) => SearchScreen(),
        ),
        GoRoute(
          path: '/checkoutScreen',
          name: 'CheckoutScreen',
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: '/orderPlacedScreen',
          name: 'OrderPlacedScreen',
          builder: (context, state) {
            final orderId = state.uri.queryParameters['orderId'] ?? '';
            return OrderPlacedScreen(orderId: orderId);
          },
        ),
        GoRoute(
          path: '/orderDetailsScreen',
          name: 'OrderDetailsScreen',
          builder: (context, state) => OrderDetailsScreen(
            orderId: state.uri.queryParameters['orderId'] ?? '',
          ),
        ),
        GoRoute(
          path: '/orderTrackingScreen',
          name: 'OrderTrackingScreen',
          builder: (context, state) {
            final orderId = state.uri.queryParameters['orderId'] ?? '';
            return OrderTrackingScreen(orderId: orderId);
          },
        ),
        GoRoute(
          path: '/supportChat',
          name: 'SupportChatScreen',
          builder: (context, state) =>
              SupportChatScreen(orderId: state.uri.queryParameters['orderId']),
        ),
        if (Env.flavor == 'dev')
          GoRoute(
            path: '/design-v2',
            name: 'DesignV2Home',
            builder: (context, state) => const HomeV2Screen(),
          ),
      ],
    );
  }
}

/// Cross-fade in (used out of the launch screen, and after sign-in), or a
/// plain cut when the user has asked for reduced motion.
CustomTransitionPage<void> _fade(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: ZMotion.page,
      transitionsBuilder: (context, animation, _, child) => FadeTransition(
        opacity: MediaQuery.disableAnimationsOf(context)
            ? kAlwaysCompleteAnimation
            : CurvedAnimation(parent: animation, curve: ZMotion.standard),
        child: child,
      ),
    );
