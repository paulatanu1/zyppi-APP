import 'package:go_router/go_router.dart';
import 'package:zippy/Auth/Login/presentation/signUpScreen.dart';
import 'package:zippy/Intro/presentation/Slider/slider.dart';
import 'package:zippy/Intro/presentation/splashScreen.dart';

class AppRoutes {
  final GoRouter router = GoRouter(
      initialLocation: '/Slider',
      routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/Slider',
      name: 'Slider',
      builder: (context, state) => Slider(),
    ),
    GoRoute(
      path: '/signupScreen',
      name: 'SignupScreen',
      builder: (context, state) => SignupScreen(),
    ),

  ]);
}
