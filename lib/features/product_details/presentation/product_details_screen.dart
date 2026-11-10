import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_commerce.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/product_details/application/product_detail_provider.dart';
import 'package:zippy/features/product_details/widgets/product_slider.dart';

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

    return Scaffold(
      backgroundColor: z.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ProductSlider(productId: productId, heroTag: heroTag),
          ),
          SliverToBoxAdapter(
            // The white sheet overlaps the photo panel by its corner radius.
            child: Transform.translate(
              offset: const Offset(0, -ZRadius.sheet),
              // Material (not a coloured box) so the expansion tile's ink
              // shows.
              child: Material(
                color: z.surface,
                borderRadius: ZRadius.sheetTop,
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
                          selectedIndex: selectedIndex,
                          onSelectVariant: notifier.selectVariant,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: product == null
          ? null
          : _BottomBar(product: product, variant: variant),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({
    required this.product,
    required this.variant,
    required this.selectedIndex,
    required this.onSelectVariant,
  });

  final Product product;
  final ProductVariant? variant;
  final int selectedIndex;
  final ValueChanged<int> onSelectVariant;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final v = variant;
    final off = v?.mrpPaise != null && v!.mrpPaise! > v.pricePaise
        ? (((v.mrpPaise! - v.pricePaise) * 100) / v.mrpPaise!).round()
        : null;
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
              Text(rupees(v.pricePaise), style: t.headlineMedium),
              if (off != null) ...[
                Text('mrpPrice'.tr(args: [rupees(v.mrpPaise!)]), style: t.mrp),
                ZOffBadge(off),
              ],
            ],
          ),
          const SizedBox(height: ZSpace.x1),
          Text('inclusiveOfTaxes'.tr(), style: t.bodySmall),
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
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<ProductVariant> variants;
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
                          rupees(variants[i].pricePaise),
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
  const _BottomBar({required this.product, required this.variant});

  final Product product;
  final ProductVariant? variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final v = variant;
    final cart = ref.read(cartProvider.notifier);
    final quantity = v == null
        ? 0
        : ref.watch(
            cartProvider.select(
              (c) => c.lines
                  .where(
                    (l) => l.product.id == product.id && l.variant.id == v.id,
                  )
                  .fold<int>(0, (sum, l) => sum + l.quantity),
            ),
          );

    return Container(
      decoration: BoxDecoration(
        color: z.surface,
        border: Border(top: BorderSide(color: z.line)),
      ),
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
                          Text(rupees(v.pricePaise), style: t.titleLarge),
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
                          onPressed: () =>
                              cart.addItem(product: product, variant: v),
                          child: Text(
                            'addToBasket'.tr(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ZAddStepper(
                        quantity: quantity,
                        height: ZSize.button,
                        minWidth: 132,
                        // Live quantity: quick taps must all count.
                        onAdd: () => cart.setQuantity(
                          product: product,
                          variant: v,
                          quantity: cart.quantityOf(product.id, v.id) + 1,
                        ),
                        onRemove: () => cart.setQuantity(
                          product: product,
                          variant: v,
                          quantity: cart.quantityOf(product.id, v.id) - 1,
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
