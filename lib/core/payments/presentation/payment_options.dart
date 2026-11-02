import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/common_widgets/section_card.dart';

/// The values stay exactly what the backend expects (create-phonepe-order,
/// placeOrder's paymentMethod, users.preferredPaymentMethod);
/// only the display text is translated.
const upiPaymentMethod = 'UPI';
const cardPaymentMethod = 'Credit or debit card';
const codPaymentMethod = 'Cash on delivery';

typedef _Option = ({
  String method,
  String titleKey,
  String subtitleKey,
  IconData icon,
});

const List<_Option> _options = [
  (
    method: upiPaymentMethod,
    titleKey: 'payUpi',
    subtitleKey: 'payUpiSubtitle',
    icon: Icons.phone_android_outlined,
  ),
  (
    method: cardPaymentMethod,
    titleKey: 'payCard',
    subtitleKey: 'payCardSubtitle',
    icon: Icons.credit_card_outlined,
  ),
  (
    method: codPaymentMethod,
    titleKey: 'payCod',
    subtitleKey: 'payCodSubtitle',
    icon: Icons.payments_outlined,
  ),
];

/// The methods this build offers ([Env.onlinePaymentsEnabled]).
List<String> get availablePaymentMethods => Env.onlinePaymentsEnabled
    ? [for (final o in _options) o.method]
    : const [codPaymentMethod];

/// What checkout starts with when the user has no usable preference.
String get defaultPaymentMethod =>
    Env.onlinePaymentsEnabled ? upiPaymentMethod : codPaymentMethod;

/// Translated short name for a payment method value, e.g. for the Pay
/// button's "Pay ₹477 with UPI".
String paymentMethodTitle(String method) {
  for (final option in _options) {
    if (option.method == method) return option.titleKey.tr();
  }
  return method;
}

/// Needs no network data, so it renders immediately while the address and
/// slot cards are still loading.
class PaymentOptions extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const PaymentOptions({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final text = Theme.of(context).textTheme;

    return SectionCard(
      title: 'paymentMethod'.tr(),
      child: Column(
        children: [
          for (final (index, option)
              in _options
                  .where((o) => availablePaymentMethods.contains(o.method))
                  .indexed) ...[
            if (index > 0) const SizedBox(height: ZSpace.x3),
            SelectableTile(
              selected: option.method == selected,
              onTap: () => onSelect(option.method),
              child: Row(
                children: [
                  _RadioDot(selected: option.method == selected),
                  const SizedBox(width: ZSpace.x3),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: z.surface2,
                      borderRadius: ZRadius.all(ZRadius.control),
                    ),
                    child: Icon(option.icon, color: z.ink, size: 20),
                  ),
                  const SizedBox(width: ZSpace.x3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(option.titleKey.tr(), style: text.labelLarge),
                        const SizedBox(height: 2),
                        Text(option.subtitleKey.tr(), style: text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;

  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    final z = context.z;

    return AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : ZMotion.press,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? z.brand : z.surface,
        border: Border.all(color: selected ? z.brand : z.line2, width: 2),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: z.onBrand,
                ),
              ),
            )
          : null,
    );
  }
}
