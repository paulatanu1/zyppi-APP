import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors_ext.dart';
import 'zyppi_colors.dart';
import 'zyppi_tokens.dart';
import 'zyppi_typography.dart';

export 'zyppi_colors.dart';
export 'zyppi_tokens.dart';
export 'zyppi_typography.dart';

/// App themes. Use in MaterialApp.router:
///   theme: ZyppiTheme.light, darkTheme: ZyppiTheme.dark, themeMode: `<from settings>`
abstract final class ZyppiTheme {
  static final ThemeData light = _build(ZColors.light, Brightness.light);
  static final ThemeData dark = _build(ZColors.dark, Brightness.dark);

  static ThemeData _build(ZColors c, Brightness b) {
    final text = zyppiTextTheme(c.ink, c.ink2, c.ink3);
    final scheme = ColorScheme(
      brightness: b,
      primary: c.brand,
      onPrimary: c.onBrand,
      primaryContainer: c.brandSoft,
      onPrimaryContainer: c.brandText,
      secondary: c.blue,
      onSecondary: Colors.white,
      secondaryContainer: c.blueSoft,
      onSecondaryContainer: c.blueText,
      tertiary: c.deal,
      onTertiary: c.dealInk,
      error: c.danger,
      onError: Colors.white,
      surface: c.surface,
      onSurface: c.ink,
      onSurfaceVariant: c.ink2,
      surfaceContainerLowest: c.bg,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surface2,
      surfaceContainerHigh: c.surface2,
      surfaceContainerHighest: c.surface3,
      outline: c.line2,
      outlineVariant: c.line,
      shadow: Colors.black,
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: ZRadius.all(ZRadius.button),
    );
    final buttonText = text.labelLarge!.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.16,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      fontFamily: ZFonts.body,
      textTheme: text,
      extensions: [
        c,
        b == Brightness.light ? AppColorsExt.light : AppColorsExt.dark,
      ],
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        shape: Border(bottom: BorderSide(color: c.line)),
        systemOverlayStyle: b == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.brand,
          foregroundColor: c.onBrand,
          minimumSize: const Size.fromHeight(ZSize.button),
          shape: buttonShape,
          textStyle: buttonText,
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.brand,
          foregroundColor: c.onBrand,
          minimumSize: const Size.fromHeight(ZSize.button),
          shape: buttonShape,
          textStyle: buttonText,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.ink,
          backgroundColor: c.surface,
          minimumSize: const Size.fromHeight(ZSize.button),
          shape: buttonShape,
          side: BorderSide(color: c.line2, width: 1.5),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.brandText,
          textStyle: text.labelMedium!.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: text.bodyMedium!.copyWith(color: c.ink3),
        border: OutlineInputBorder(
          borderRadius: ZRadius.all(ZRadius.input),
          borderSide: BorderSide(color: c.line2, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: ZRadius.all(ZRadius.input),
          borderSide: BorderSide(color: c.line2, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ZRadius.all(ZRadius.input),
          borderSide: BorderSide(color: c.brandText, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: ZRadius.all(ZRadius.card),
          side: BorderSide(color: c.line),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: c.ink,
        side: BorderSide(color: c.line),
        shape: const StadiumBorder(),
        labelStyle: text.labelMedium,
        secondaryLabelStyle: text.labelMedium!.copyWith(color: c.bg),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: c.line2,
        shape: const RoundedRectangleBorder(borderRadius: ZRadius.sheetTop),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.ink,
        contentTextStyle: text.labelMedium!.copyWith(color: c.bg),
        shape: RoundedRectangleBorder(borderRadius: ZRadius.all(14)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.brand,
        linearTrackColor: c.surface3,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
