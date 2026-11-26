import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/legal/domain/legal_doc.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// "By continuing, you agree to Zyppi's Terms of Use, Privacy Policy and
/// Refund Policy" under the sign-in buttons, each document opening in the
/// in-app reader. No checkbox: tapping a sign-in button is the consent,
/// and the legal gate records it right after sign-in.
class LegalConsentNotice extends StatelessWidget {
  const LegalConsentNotice({super.key, this.types = LegalTypes.forCustomer});

  final List<String> types;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final linkStyle = t.bodySmall!.copyWith(
      color: z.brandText,
      fontWeight: FontWeight.w700,
    );
    return Column(
      children: [
        Text(
          'legalByContinuing'.tr(),
          textAlign: TextAlign.center,
          style: t.bodySmall!.copyWith(color: z.ink2),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: ZSpace.x1,
          children: [
            for (final type in types)
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: ZSpace.x1),
                  minimumSize: const Size(0, ZSize.touch),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => context.push(
                  Uri(
                    path: '/legal',
                    queryParameters: {'type': type},
                  ).toString(),
                ),
                child: Text(LegalTypes.labelKey(type).tr(), style: linkStyle),
              ),
          ],
        ),
      ],
    );
  }
}
