import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// Re-themes a subtree with the logo-purple brand ([ZColors.violetLight] /
/// [ZColors.violetDark]), keeping the current light/dark choice. Trial:
/// used on Home (and the nav bar while Home is selected) only, so other
/// screens keep the magenta brand until the look is approved.
class ZBrandScope extends StatelessWidget {
  const ZBrandScope.violet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: dark ? ZyppiTheme.violetDark : ZyppiTheme.violetLight,
      child: child,
    );
  }
}
