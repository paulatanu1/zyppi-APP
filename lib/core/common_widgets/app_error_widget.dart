import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// Shown in place of a widget that threw while building, in release builds
/// only (installed as `ErrorWidget.builder` in bootstrap.dart) — debug keeps
/// Flutter's red error screen. Crashlytics still records the error.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        margin: const EdgeInsets.all(ZSpace.x2),
        padding: const EdgeInsets.all(ZSpace.x3),
        decoration: BoxDecoration(
          color: context.z.surface,
          borderRadius: BorderRadius.circular(ZRadius.card),
          border: Border.all(color: context.z.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: context.z.ink2),
            const SizedBox(width: ZSpace.x2),
            Flexible(
              child: Text(
                'somethingWentWrong'.tr(),
                style: AppTypography.bodySmall.copyWith(color: context.z.ink2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
