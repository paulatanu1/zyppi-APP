import 'package:go_router/go_router.dart';
import 'package:zippy/Intro/presentation/Slider/sliderOne.dart';
import 'package:zippy/Intro/presentation/Slider/sliderThree.dart';
import 'package:zippy/Intro/presentation/Slider/sliderTwo.dart';
import 'package:zippy/Intro/presentation/splashScreen.dart';

class AppRoutes {
  final GoRouter router = GoRouter(routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/slider_one',
      name: 'sliderOne',
      builder: (context, state) => SliderOne(),
    ),
    GoRoute(
      path: '/slider_two',
      name: 'sliderTwo',
      builder: (context, state) => SliderTwo(),
    ),
    GoRoute(
      path: '/slider_three',
      name: 'sliderThree',
      builder: (context, state) => SliderThree(),
    )
  ]);
}
