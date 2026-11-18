import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/section_card.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_commerce.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/wallet/data/wallet_repository.dart';

/// Account → Zyppi wallet: the balance and every credit and spend.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final text = Theme.of(context).textTheme;
    final balance = ref.watch(walletBalanceProvider);
    final history = ref.watch(walletHistoryProvider);

    return Scaffold(
      backgroundColor: z.bg,
      appBar: AppBar(title: Text('walletTitle'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(ZSpace.screen),
        children: [
          Container(
            padding: const EdgeInsets.all(ZSpace.x5),
            decoration: BoxDecoration(
              color: z.brand,
              borderRadius: ZRadius.all(ZRadius.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: z.onBrand,
                    ),
                    const SizedBox(width: ZSpace.x2),
                    Text(
                      'walletBalance'.tr(),
                      style: text.labelLarge?.copyWith(color: z.onBrand),
                    ),
                  ],
                ),
                const SizedBox(height: ZSpace.x3),
                balance.when(
                  data: (paise) => Text(
                    rupees(paise),
                    style: text.headlineMedium?.copyWith(color: z.onBrand),
                  ),
                  loading: () => const ZSkeleton(width: 120, height: 32),
                  error: (_, _) => Text(
                    '—',
                    style: text.headlineMedium?.copyWith(color: z.onBrand),
                  ),
                ),
                const SizedBox(height: ZSpace.x2),
                Text(
                  'walletExplainer'.tr(),
                  style: text.bodySmall?.copyWith(color: z.onBrand),
                ),
              ],
            ),
          ),
          const SizedBox(height: ZSpace.x3),
          SectionCard(
            title: 'walletHistory'.tr(),
            child: history.when(
              loading: () => Column(
                children: [
                  for (var i = 0; i < 4; i++) ...[
                    if (i > 0) const SizedBox(height: ZSpace.x3),
                    const ZSkeleton(height: 44),
                  ],
                ],
              ),
              error: (_, _) => Column(
                children: [
                  Text('somethingWentWrong'.tr(), style: text.bodyMedium),
                  TextButton(
                    onPressed: () => ref.invalidate(walletHistoryProvider),
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
              data: (entries) => entries.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: ZSpace.x4),
                      child: Center(
                        child: Text(
                          'walletEmpty'.tr(),
                          textAlign: TextAlign.center,
                          style: text.bodyMedium?.copyWith(color: z.ink3),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (final (i, e) in entries.indexed)
                          ZEntrance(
                            index: i,
                            child: _EntryRow(entry: e),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Translated title for a history entry.
String walletEntryTitle(WalletEntry e) => switch (e.type) {
  'spend' when e.isHeld => 'walletEntryHeld'.tr(),
  'spend' => 'walletEntrySpend'.tr(),
  'release' => 'walletEntryRelease'.tr(),
  'cancel' => 'walletEntryCancel'.tr(),
  'claim' => 'walletEntryClaim'.tr(),
  'credit' => 'walletEntryCredit'.tr(),
  _ => e.reason,
};

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});

  final WalletEntry entry;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final text = Theme.of(context).textTheme;
    final credit = entry.isCredit;
    final orderId = entry.orderId;
    final subtitle = [
      if (entry.at != null)
        DateFormat.yMMMd(context.locale.toLanguageTag())
            .add_jm()
            .format(entry.at!.toLocal()),
      // Staff credits carry the reason the customer should see.
      if (entry.type == 'credit' && entry.reason.isNotEmpty) entry.reason,
    ].join(' · ');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: orderId == null
          ? null
          : () => context.push('/orderDetailsScreen?orderId=$orderId'),
      leading: Container(
        width: ZSize.touch,
        height: ZSize.touch,
        decoration: BoxDecoration(
          color: credit ? z.okSoft : z.surface2,
          borderRadius: ZRadius.all(ZRadius.control),
        ),
        child: Icon(
          credit ? Icons.south_west_rounded : Icons.north_east_rounded,
          color: credit ? z.ok : z.ink2,
        ),
      ),
      title: Text(walletEntryTitle(entry), style: text.labelLarge),
      subtitle: subtitle.isEmpty ? null : Text(subtitle, style: text.bodySmall),
      trailing: Text(
        '${credit ? '+' : '−'}${rupees(entry.amountPaise.abs())}',
        style: text.labelLarge?.copyWith(color: credit ? z.ok : z.ink),
      ),
    );
  }
}
