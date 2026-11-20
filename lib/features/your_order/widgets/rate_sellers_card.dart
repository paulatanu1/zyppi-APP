import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/domain/order_item.dart';
import 'package:zippy/core/marketplace/domain/offer.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/order_tracking/data/delivery_info_repository.dart';

/// After delivery: 1–5 stars for each marketplace seller in the order
/// (their ratings decide which offers customers see first). Hidden when
/// there's no outside seller or every one is rated.
class RateSellersCard extends ConsumerStatefulWidget {
  const RateSellersCard({
    super.key,
    required this.orderId,
    required this.items,
  });

  final String orderId;
  final List<OrderItem> items;

  @override
  ConsumerState<RateSellersCard> createState() => _RateSellersCardState();
}

class _RateSellersCardState extends ConsumerState<RateSellersCard> {
  final _busy = <String>{};

  Future<void> _rate(String sellerId, int stars) async {
    setState(() => _busy.add(sellerId));
    try {
      await ref.read(deliveryInfoRepositoryProvider).rateSellers(
        widget.orderId,
        {sellerId: stars},
      );
      ref.invalidate(ratedSellersProvider(widget.orderId));
      showSuccessToast(message: 'rateSellerThanks'.tr());
    } catch (_) {
      showError('somethingWentWrong'.tr());
    } finally {
      if (mounted) setState(() => _busy.remove(sellerId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final sellers = <String, String>{
      for (final i in widget.items)
        if (i.sellerId != null && i.sellerId != zyppiSellerId)
          i.sellerId!: i.sellerName ?? '',
    };
    final rated = ref.watch(ratedSellersProvider(widget.orderId)).value;
    if (rated == null) return const SizedBox.shrink();
    final todo = sellers.entries.where((e) => !rated.contains(e.key)).toList();
    if (todo.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(ZSpace.x4),
      decoration: BoxDecoration(
        color: z.surface,
        borderRadius: ZRadius.all(ZRadius.card),
        boxShadow: z.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('rateSellersTitle'.tr(), style: t.titleMedium),
          for (final e in todo)
            Padding(
              padding: const EdgeInsets.only(top: ZSpace.x2),
              child: Row(
                children: [
                  Expanded(child: Text(e.value, style: t.labelLarge)),
                  for (var s = 1; s <= 5; s++)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'rateNStars'.plural(s),
                      onPressed: _busy.contains(e.key)
                          ? null
                          : () => _rate(e.key, s),
                      icon: Icon(Icons.star_border_rounded, color: z.warn),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
