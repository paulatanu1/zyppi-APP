import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/legal/domain/legal_doc.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// "I agree to the Terms of Use, Privacy Policy and Refund Policy", with
/// each document opening in the in-app reader. Unticked by default: the
/// customer has to tick it themselves.
class LegalConsentRow extends StatelessWidget {
  const LegalConsentRow({
    super.key,
    required this.value,
    required this.onChanged,
    this.showError = false,
    this.types = LegalTypes.forCustomer,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  /// Highlights the row after the customer tried to continue without it.
  final bool showError;
  final List<String> types;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              side: BorderSide(
                color: showError && !value ? z.danger : z.ink3,
                width: 1.5,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: ZSpace.x1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      button: true,
                      child: GestureDetector(
                        onTap: () => onChanged(!value),
                        child: Text('legalAgree'.tr(), style: t.bodyMedium),
                      ),
                    ),
                    Wrap(
                      spacing: ZSpace.x1,
                      children: [
                        for (final type in types)
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: ZSpace.x1,
                              ),
                              minimumSize: const Size(0, ZSize.touch),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => context.push(
                              Uri(
                                path: '/legal',
                                queryParameters: {'type': type},
                              ).toString(),
                            ),
                            child: Text(LegalTypes.labelKey(type).tr()),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (showError && !value)
          Padding(
            padding: const EdgeInsets.only(left: ZSpace.x6 + ZSpace.x6),
            child: Text(
              'legalAgreeRequired'.tr(),
              style: t.bodySmall!.copyWith(color: z.danger),
            ),
          ),
      ],
    );
  }
}
