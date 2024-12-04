import 'package:go_router/go_router.dart';
import 'package:zippy/Auth/Login/presentation/loginScreen.dart';
import 'package:zippy/Auth/OTPVerification/presentation/otpVerificationScreen.dart';
import 'package:zippy/HomeScreen/presentation/homeScreen.dart';
import 'package:zippy/Intro/presentation/Slider/slider.dart';

//class AppRoutes {
  final GoRouter router =
      GoRouter(initialLocation: '/Slider', routes: <RouteBase>[
    // GoRoute(
    //   path: '/',
    //   name: 'splash',
    //   builder: (context, state) => SplashScreen(),
    // ),
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
      path: '/homeScreen',
      name: 'HomeScreen',
      builder: (context, state) => HomeScreen(),
    ),
  ]);
//}
