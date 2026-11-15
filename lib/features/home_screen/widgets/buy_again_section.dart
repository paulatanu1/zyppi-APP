import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/cart/presentation/catalog_product_card.dart';
import 'package:zippy/core/theme/zyppi_tokens.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/core/widgets/z_product_card.dart';
import 'package:zippy/features/home_screen/application/buy_again_provider.dart';

/// "Buy again" carousel at the top of Home (Blinkit/Zepto pattern). Hidden
/// until there is something to show.
class BuyAgainSection extends ConsumerWidget {
  const BuyAgainSection({super.key});

  static const double _cardWidth = 150;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(buyAgainProvider).value ?? const [];
    if (products.isEmpty) return const SizedBox.shrink();

    return ZEntrance(
      child: Padding(
        padding: const EdgeInsets.only(bottom: ZSpace.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ZSpace.screen),
              child: ZSectionHeader('buyAgain'.tr()),
            ),
            SizedBox(
              height: ZProductCard.height(context),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: ZSpace.screen),
                itemCount: products.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: ZSpace.x3),
                itemBuilder: (context, index) => CatalogProductCard(
                  product: products[index],
                  width: _cardWidth,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
