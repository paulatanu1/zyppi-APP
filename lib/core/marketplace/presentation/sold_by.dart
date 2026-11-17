import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/marketplace/domain/offer.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// "Sold by Sima Store" — opens the seller's page (name, address,
/// contact, as the Consumer Protection (E-Commerce) Rules require). Zyppi's
/// own stock shows "Sold by Zyppi" without a link.
class SoldByLink extends StatelessWidget {
  const SoldByLink({
    super.key,
    required this.sellerId,
    required this.sellerName,
    this.rating,
  });

  final String sellerId;
  final String sellerName;

  /// Shown as "★ 4.6" when the seller has ratings.
  final double? rating;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final zyppi = sellerId == zyppiSellerId;
    final name = zyppi ? 'Zyppi' : sellerName;
    // The name sits inside the sentence: word order differs by language.
    final label = Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'soldBy'.tr(args: [name])),
          if (rating != null && rating! > 0)
            TextSpan(text: '  ★ ${rating!.toStringAsFixed(1)}'),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: t.bodySmall!.copyWith(
        color: zyppi ? z.ink2 : z.brandText,
        fontWeight: zyppi ? null : FontWeight.w600,
      ),
    );
    if (zyppi) return label;
    return Semantics(
      link: true,
      child: InkWell(
        onTap: () => context.push(
          Uri(
            path: '/seller',
            queryParameters: {'sellerId': sellerId},
          ).toString(),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: ZSpace.x1),
          child: label,
        ),
      ),
    );
  }
}
