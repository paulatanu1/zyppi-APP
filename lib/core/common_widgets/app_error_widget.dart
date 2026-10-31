import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';

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
        margin: const EdgeInsets.all(AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: context.colors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: context.colors.muted),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                'somethingWentWrong'.tr(),
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
