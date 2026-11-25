import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/cart/domain/cart_line.dart';
import 'package:zippy/core/marketplace/application/marketplace_providers.dart';
import 'package:zippy/core/marketplace/domain/offer.dart';
import 'package:zippy/core/marketplace/presentation/sold_by.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_commerce.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/product_details/application/product_detail_provider.dart';
import 'package:zippy/features/product_details/widgets/product_slider.dart';
import 'package:zippy/features/product_details/widgets/sellers_sheet.dart';

/// docs/screens/light/07-product.png. Left out until the catalog has the
/// data: origin / shelf life / storage tiles, "Fresh today", "Best value",
/// extra photos, "Often bought together" and share.
class ProductDetailsScreen extends ConsumerWidget {
  final String productId;

  /// The tapped card's hero tag, so its photo flies into [ProductSlider].
  final String? heroTag;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productDetailProvider(productId));
    final notifier = ref.read(productDetailProvider(productId).notifier);
    final product = state.product;
    final z = context.z;
    final t = Theme.of(context).textTheme;

    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('somethingWentWrong'.tr(), style: t.bodyMedium),
              const SizedBox(height: ZSpace.x3),
              FilledButton(
                onPressed: notifier.retry,
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    // Loaded, but no such (active) product — e.g. an old link or a
    // product taken off sale.
    if (!state.loading && product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(ZSpace.x6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_rounded, size: 48, color: z.ink3),
                const SizedBox(height: ZSpace.x3),
                Text(
                  'productNotFound'.tr(),
                  style: t.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ZSpace.x3),
                TextButton(
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/navBar'),
                  child: Text('back'.tr()),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final variants = product?.variants ?? const <ProductVariant>[];
    final selectedIndex = variants.isEmpty
        ? 0
        : state.selectedVariantIndex.clamp(0, variants.length - 1);
    final variant = variants.isEmpty ? null : variants[selectedIndex];
    final areaId = ref.watch(shoppingAreaIdProvider);
    // Every seller of this pack size here, best first (empty: Zyppi only,
    // priced from the variant as before the marketplace).
    final offers = variant == null
        ? const <Offer>[]
        : (ref.watch(productOffersProvider(productId)).value ?? const [])
              .where((o) => o.variantId == variant.id)
              .toList();
    final chosen = product == null || variant == null
        ? null
        : chooseOffer(
            offers,
            picked: state.pickedOfferId,
            best: product.bestOfferFor(areaId, variant.id)?.offerId,
          );

    return Scaffold(
      backgroundColor: z.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ProductSlider(productId: productId, heroTag: heroTag),
          ),
          SliverToBoxAdapter(
            // Floating Cards: the details sit on the page under the rounded
            // photo panel. Material (not a coloured box) so the expansion
            // tile's ink shows.
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  ZSpace.screen,
                  ZSpace.x5,
                  ZSpace.screen,
                  0,
                ),
                child: state.loading || product == null
                    ? const _InfoSkeleton()
                    : _Info(
                        product: product,
                        variant: variant,
                        areaId: areaId,
                        offers: offers,
                        chosen: chosen,
                        selectedIndex: selectedIndex,
                        onSelectVariant: notifier.selectVariant,
                        onPickOffer: (o) => notifier.pickOffer(o.id),
                      ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: product == null
          ? null
          : _BottomBar(product: product, variant: variant, offer: chosen),
    );
  }
}

/// The offer the details screen sells: the customer's pick, else the
/// area's best match if it's in stock, else the first in stock, else the
/// first. Null when nobody offers it here (the variant's own price).
Offer? chooseOffer(
  List<Offer> offers, {
  required String? picked,
  required String? best,
}) {
  if (offers.isEmpty) return null;
  return offers.where((o) => o.id == picked).firstOrNull ??
      offers.where((o) => o.id == best && o.inStock).firstOrNull ??
      offers.where((o) => o.inStock).firstOrNull ??
      offers.first;
}

class _Info extends StatelessWidget {
  const _Info({
    required this.product,
    required this.variant,
    required this.areaId,
    required this.offers,
    required this.chosen,
    required this.selectedIndex,
    required this.onSelectVariant,
    required this.onPickOffer,
  });

  final Product product;
  final ProductVariant? variant;
  final String? areaId;
  final List<Offer> offers;
  final Offer? chosen;
  final int selectedIndex;
  final ValueChanged<int> onSelectVariant;
  final ValueChanged<Offer> onPickOffer;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final v = variant;
    final price = chosen?.pricePaise ?? v?.pricePaise ?? 0;
    final mrp = chosen?.mrpPaise ?? v?.mrpPaise;
    final off = mrp != null && mrp > price
        ? (((mrp - price) * 100) / mrp).round()
        : null;
    final others = offers.length - 1;
    final description = product.description?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ZEtaBadge(),
        const SizedBox(height: ZSpace.x2),
        Text(product.name, style: t.headlineSmall),
        const SizedBox(height: ZSpace.x2),
        if (v == null)
          Text(
            'productUnavailable'.tr(),
            style: t.bodyMedium!.copyWith(color: z.danger),
          )
        else ...[
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: ZSpace.x2,
            runSpacing: ZSpace.x1,
            children: [
              Text(rupees(price), style: t.headlineMedium),
              if (off != null) ...[
                Text('mrpPrice'.tr(args: [rupees(mrp!)]), style: t.mrp),
                ZOffBadge(off),
              ],
            ],
          ),
          const SizedBox(height: ZSpace.x1),
          Text('inclusiveOfTaxes'.tr(), style: t.bodySmall),
          if (chosen case final o?) ...[
            const SizedBox(height: ZSpace.x3),
            Row(
              children: [
                Expanded(
                  child: SoldByLink(
                    sellerId: o.sellerId,
                    sellerName: o.sellerName,
                    rating: o.ratingCount > 0 ? o.sellerRating : null,
                  ),
                ),
                if (others > 0)
                  TextButton(
                    onPressed: () => showSellersSheet(
                      context,
                      offers: offers,
                      selectedId: o.id,
                      onPick: onPickOffer,
                    ),
                    child: Text('moreSellers'.plural(others)),
                  ),
              ],
            ),
            if (!o.inStock)
              Text(
                'outOfStock'.tr(),
                style: t.bodySmall!.copyWith(color: z.danger),
              ),
          ],
        ],
        if (product.variants.length > 1) ...[
          const SizedBox(height: ZSpace.x6),
          Text(
            'packSize'.tr().toUpperCase(),
            style: t.labelSmall!.copyWith(color: z.ink3, letterSpacing: 1.1),
          ),
          const SizedBox(height: ZSpace.x3),
          _PackSizes(
            variants: product.variants,
            prices: [
              for (final pv in product.variants)
                cardPrice(product, pv, areaId).price,
            ],
            selectedIndex: selectedIndex,
            onSelect: onSelectVariant,
          ),
        ],
        if (description.isNotEmpty) ...[
          const SizedBox(height: ZSpace.x4),
          Divider(color: z.line),
          Theme(
            // No extra divider lines from the expansion tile itself.
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: ZSpace.x3),
              controlAffinity: ListTileControlAffinity.leading,
              expandedAlignment: Alignment.centerLeft,
              title: Text('aboutThisItem'.tr(), style: t.titleMedium),
              children: [Text(description, style: t.bodyMedium)],
            ),
          ),
          Divider(color: z.line),
        ],
        const SizedBox(height: ZSpace.x6),
      ],
    );
  }
}

/// Pack-size cards, three per row: size and price; the selected one is
/// tinted with a brand border.
class _PackSizes extends StatelessWidget {
  const _PackSizes({
    required this.variants,
    required this.prices,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<ProductVariant> variants;

  /// Per variant: the area's best price.
  final List<int> prices;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 2 * ZSpace.x3) / 3;
        return Wrap(
          spacing: ZSpace.x3,
          runSpacing: ZSpace.x3,
          children: [
            for (var i = 0; i < variants.length; i++)
              Semantics(
                selected: i == selectedIndex,
                child: ZPressable(
                  onTap: () => onSelect(i),
                  child: Container(
                    width: width,
                    constraints: const BoxConstraints(minHeight: ZSize.input),
                    padding: const EdgeInsets.symmetric(
                      horizontal: ZSpace.x3,
                      vertical: ZSpace.x2,
                    ),
                    decoration: BoxDecoration(
                      color: i == selectedIndex ? z.brandSoft : z.surface,
                      borderRadius: ZRadius.all(ZRadius.tile),
                      border: Border.all(
                        color: i == selectedIndex ? z.brand : z.line,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(variants[i].label, style: t.labelLarge),
                        Text(
                          rupees(prices[i]),
                          style: t.bodySmall!.copyWith(color: z.ink2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Price · "1 kg · inclusive of taxes" on the left; on the right "Add to
/// basket", which becomes a − n + stepper on the cart line once added.
class _BottomBar extends ConsumerWidget {
  const _BottomBar({
    required this.product,
    required this.variant,
    required this.offer,
  });

  final Product product;
  final ProductVariant? variant;

  /// The seller being bought from; null = Zyppi (no marketplace offers).
  final Offer? offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final v = variant;
    final cart = ref.read(cartProvider.notifier);
    final pick = offer?.pick;
    final price = offer?.pricePaise ?? v?.pricePaise ?? 0;
    final soldOut = offer != null && !offer!.inStock;
    // This seller's line only: the same pack from another seller is a
    // separate cart line.
    final key = v == null ? '' : CartLine.keyFor(v.id, cartKeyPick(pick));
    final quantity = v == null
        ? 0
        : ref.watch(
            cartProvider.select(
              (c) => c.lines
                  .where((l) => l.product.id == product.id && l.key == key)
                  .fold<int>(0, (sum, l) => sum + l.quantity),
            ),
          );

    return Container(
      decoration: BoxDecoration(color: z.surface, boxShadow: z.barShadow),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            ZSpace.screen,
            ZSpace.x3,
            ZSpace.screen,
            ZSpace.x3,
          ),
          child: Row(
            children: [
              Expanded(
                child: v == null
                    ? Text('productUnavailable'.tr(), style: t.bodyMedium)
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rupees(price), style: t.titleLarge),
                          Text(
                            'variantInclTaxes'.tr(args: [v.label]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.bodySmall,
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: ZSpace.x3),
              if (v != null)
                quantity == 0
                    // Flexible: at large text sizes the label wraps
                    // instead of pushing the bar off-screen.
                    ? Flexible(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, ZSize.button),
                          ),
                          onPressed: soldOut
                              ? null
                              : () => cart.addItem(
                                  product: product,
                                  variant: v,
                                  offer: pick,
                                ),
                          child: Text(
                            (soldOut ? 'outOfStock' : 'addToBasket').tr(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ZAddStepper(
                        quantity: quantity,
                        height: ZSize.button,
                        minWidth: 132,
                        canAdd: quantity < CartNotifier.maxPerItem,
                        // Live quantity: quick taps must all count.
                        onAdd: () => cart.setQuantity(
                          product: product,
                          variant: v,
                          offer: pick,
                          quantity:
                              cart.quantityOf(product.id, v.id, offer: pick) +
                              1,
                        ),
                        onRemove: () => cart.setQuantity(
                          product: product,
                          variant: v,
                          offer: pick,
                          quantity:
                              cart.quantityOf(product.id, v.id, offer: pick) -
                              1,
                        ),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoSkeleton extends StatelessWidget {
  const _InfoSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZSkeleton(width: 72, height: 18, radius: ZRadius.badge),
        SizedBox(height: ZSpace.x3),
        ZSkeleton(width: 220, height: 26),
        SizedBox(height: ZSpace.x3),
        ZSkeleton(width: 120, height: 28),
        SizedBox(height: ZSpace.x6),
        Row(
          children: [
            Expanded(
              child: ZSkeleton(height: ZSize.input, radius: ZRadius.tile),
            ),
            SizedBox(width: ZSpace.x3),
            Expanded(
              child: ZSkeleton(height: ZSize.input, radius: ZRadius.tile),
            ),
            SizedBox(width: ZSpace.x3),
            Expanded(
              child: ZSkeleton(height: ZSize.input, radius: ZRadius.tile),
            ),
          ],
        ),
        SizedBox(height: ZSpace.x6),
      ],
    );
  }
}
