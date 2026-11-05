import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback action;

  const GoogleSignInButton({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(ZRadius.input),
      child: Container(
        height: ZSize.button,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: ZSpace.x4),
        decoration: BoxDecoration(
          color: context.z.surface,
          borderRadius: BorderRadius.circular(ZRadius.input),
          border: Border.all(color: context.z.line2, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/googleIcon.png', width: 20, height: 20),
            const SizedBox(width: ZSpace.x3),
            Flexible(
              child: Text(
                'signInWithGoogle'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
