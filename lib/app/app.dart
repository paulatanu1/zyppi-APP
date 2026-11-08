import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/theme/theme_mode_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/snack_bar.dart';

class Zyppi extends ConsumerWidget {
  final GoRouter router;

  const Zyppi({super.key, required this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp.router(
        routerConfig: router,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: ZyppiTheme.light,
        darkTheme: ZyppiTheme.dark,
        themeMode: themeMode,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        // Status- and navigation-bar styling follow the active theme
        // (bootstrap only sets the initial light-theme style). This region
        // spans the whole screen, so it also owns the Android nav bar —
        // the .light/.dark presets would otherwise force it black.
        builder: (context, child) {
          final dark = Theme.of(context).brightness == Brightness.dark;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value:
                (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
                    .copyWith(
                      statusBarColor: Colors.transparent,
                      systemNavigationBarColor: context.z.surface,
                      systemNavigationBarIconBrightness: dark
                          ? Brightness.light
                          : Brightness.dark,
                    ),
            child: child!,
          );
        },
      ),
    );
  }
}
