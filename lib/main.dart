import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/Utils/constants.dart';
import 'package:zippy/Utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(EasyLocalization(
    supportedLocales: const [
      Locale('en', 'UK'),
      Locale('bn', 'BN'),
      Locale('hi', 'IN'),
      Locale('pa', 'Guru')
    ],
    path: Constants.translationPath,
    child: Zyppi(),
  ));
}

// class Zyppi extends StatefulWidget {
//   ZyppiApp createState() => ZyppiApp();
// }
//
// class ZyppiApp extends State<Zyppi> {
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return ScreenUtilInit(
//       designSize: Size(MediaQuery.of(context).size.height,
//           MediaQuery.of(context).size.width),
//       builder: (context, child) => MaterialApp.router(
//         routerConfig: AppRoutes().router,
//         localizationsDelegates: context.localizationDelegates,
//         supportedLocales: context.supportedLocales,
//         locale: context.locale,
//         debugShowCheckedModeBanner: false,
//       ),
//     );
//   }
// }

class Zyppi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(MediaQuery.of(context).size.height,
          MediaQuery.of(context).size.width),
      builder: (context, child) => MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
