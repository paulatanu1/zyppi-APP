import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_typography.dart';

/// docs/mockups/Category.dc.html's page title (`<h1 class="h">`, 19px/700).
class CommonHeader extends StatelessWidget {
  const CommonHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text("findProducts".tr(), style: AppTypography.titleLarge)],
    );
  }
}
