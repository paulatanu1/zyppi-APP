import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/common_widgets/section_card.dart';
import 'package:zippy/core/marketplace/application/marketplace_providers.dart';
import 'package:zippy/core/marketplace/domain/seller_profile.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/launch.dart';
import 'package:zippy/core/widgets/z_motion.dart';

/// A marketplace seller's public details (route `/seller?sellerId=…`):
/// name, rating, address, contact and licences, as the Consumer
/// Protection (E-Commerce) Rules 2020 require Zyppi to show.
class SellerScreen extends ConsumerWidget {
  const SellerScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final profile = ref.watch(sellerProfileProvider(sellerId));

    return Scaffold(
      backgroundColor: z.bg,
      appBar: AppBar(title: Text('sellerDetails'.tr())),
      body: SafeArea(
        child: profile.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(ZSpace.screen),
            children: const [
              ZSkeleton(width: 200, height: 28),
              SizedBox(height: ZSpace.x3),
              ZSkeleton(width: 120, height: 16),
              SizedBox(height: ZSpace.x5),
              ZSkeleton(height: 140, radius: ZRadius.card),
            ],
          ),
          error: (_, _) => _Message(
            text: 'somethingWentWrong'.tr(),
            action: FilledButton(
              onPressed: () => ref.invalidate(sellerProfileProvider(sellerId)),
              child: Text('retry'.tr()),
            ),
          ),
          data: (p) => p == null
              ? _Message(text: 'sellerNotSelling'.tr())
              : _Details(profile: p),
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.profile});

  final SellerProfile profile;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final p = profile;

    Widget row(String label, String? value, {VoidCallback? onTap}) {
      if (value == null || value.isEmpty) return const SizedBox.shrink();
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: t.bodySmall),
        subtitle: Text(value, style: t.labelLarge),
        trailing: onTap == null
            ? null
            : Icon(Icons.call_rounded, color: z.brandText),
        onTap: onTap,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(ZSpace.screen),
      children: [
        Text(p.shopName, style: t.headlineSmall),
        const SizedBox(height: ZSpace.x1),
        Text(
          p.ratingCount > 0
              ? 'sellerRating'.tr(
                  args: [p.ratingAvg.toStringAsFixed(1), '${p.ratingCount}'],
                )
              : 'newSeller'.tr(),
          style: t.bodyMedium,
        ),
        const SizedBox(height: ZSpace.x4),
        SectionCard(
          child: Column(
            children: [
              row('sellerAddress'.tr(), p.address),
              row(
                'sellerPhone'.tr(),
                p.phone,
                onTap: p.phone == null
                    ? null
                    : () => openExternal(Uri(scheme: 'tel', path: p.phone)),
              ),
              row('sellerGstin'.tr(), p.gstin),
              row('sellerFssai'.tr(), p.fssaiNo),
            ],
          ),
        ),
        const SizedBox(height: ZSpace.x3),
        Text('sellerMarketplaceNote'.tr(), style: t.bodySmall),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ZSpace.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: t.titleMedium, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: ZSpace.x4), action!],
          ],
        ),
      ),
    );
  }
}
