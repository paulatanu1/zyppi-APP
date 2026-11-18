import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/common_widgets/section_card.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_commerce.dart';

/// Checkout: "Use Zyppi wallet" with the balance and how much of it this
/// order takes. Hidden by the caller when the balance is 0.
class WalletPayCard extends StatelessWidget {
  const WalletPayCard({
    super.key,
    required this.balancePaise,
    required this.appliedPaise,
    required this.use,
    required this.onChanged,
  });

  final int balancePaise;
  final int appliedPaise;
  final bool use;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final text = Theme.of(context).textTheme;
    return SectionCard(
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: use,
        onChanged: onChanged,
        secondary: Container(
          width: ZSize.touch,
          height: ZSize.touch,
          decoration: BoxDecoration(
            color: z.okSoft,
            borderRadius: ZRadius.all(ZRadius.control),
          ),
          child: Icon(Icons.account_balance_wallet_outlined, color: z.ok),
        ),
        title: Text('useWallet'.tr(), style: text.labelLarge),
        subtitle: Text(
          use
              ? 'walletWillUse'.tr(
                  args: [rupees(appliedPaise), rupees(balancePaise)],
                )
              : 'walletAvailable'.tr(args: [rupees(balancePaise)]),
          style: text.bodySmall,
        ),
      ),
    );
  }
}
