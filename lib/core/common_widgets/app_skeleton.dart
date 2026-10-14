import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:zippy/core/theme/app_colors.dart';

/// Loading skeleton for async screens (CLAUDE.md: every async screen has
/// loading/empty/error/data states). Wrap the screen's real layout with
/// fake data; [enabled] false reveals the real content unchanged.
class AppSkeleton extends StatelessWidget {
  final bool enabled;
  final Widget child;

  const AppSkeleton({super.key, required this.enabled, required this.child});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: enabled,
      effect: const ShimmerEffect(
        baseColor: AppColors.divider,
        highlightColor: AppColors.surface,
      ),
      child: child,
    );
  }
}
