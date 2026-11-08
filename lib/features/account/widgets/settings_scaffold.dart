import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_motion.dart';

/// App bar + loading (skeleton) / error-with-retry / data for the Account
/// sub-screens, so each one gets all the async states CLAUDE.md requires.
class SettingsScaffold<T> extends StatelessWidget {
  final String title;
  final AsyncValue<T> async;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;

  const SettingsScaffold({
    super.key,
    required this.title,
    required this.async,
    required this.onRetry,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final z = context.z;

    return Scaffold(
      backgroundColor: z.bg,
      appBar: AppBar(title: Text(title)),
      body: async.when(
        // Keep showing the last data while a save refreshes it.
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        data: builder,
        loading: () => ListView(
          padding: const EdgeInsets.all(ZSpace.screen),
          children: const [
            ZSkeleton(height: 16, width: 220, radius: ZRadius.badge),
            SizedBox(height: ZSpace.x4),
            ZSkeleton(height: 72, radius: ZRadius.card),
            SizedBox(height: ZSpace.x3),
            ZSkeleton(height: 72, radius: ZRadius.card),
            SizedBox(height: ZSpace.x3),
            ZSkeleton(height: 72, radius: ZRadius.card),
          ],
        ),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'somethingWentWrong'.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(onPressed: onRetry, child: Text('retry'.tr())),
            ],
          ),
        ),
      ),
    );
  }
}
