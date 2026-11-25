import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/cart/application/cart_state.dart';
import 'package:zippy/core/domain/coupon.dart';
import 'package:zippy/core/marketplace/application/marketplace_providers.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/address_label.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/core/widgets/z_commerce.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/my_cart/widgets/bill_details.dart';
import 'package:zippy/features/my_cart/widgets/my_cart_item.dart';
import 'package:zippy/features/my_cart/widgets/tip_selector.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/core/common_widgets/nav_bar/provider/nav_bar_provider.dart';
import 'package:zippy/features/home_screen/widgets/address_sheet.dart';

/// Cart B (Floating Cards): deliver-to card on top, the lines, the
/// free-delivery bar, coupon and tip side by side, and a sticky sheet with
/// a one-line bill (expands to the full bill) and Checkout. Both a tab and
/// a pushed route (`/myCartScreen`). The free-delivery / minimum-order bar
/// follows `config/delivery`.
class MyCartScreen extends ConsumerWidget {
  const MyCartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final t = Theme.of(context).textTheme;
    final hasLines =
        !cart.loading && cart.error == null && cart.lines.isNotEmpty;
    final itemCount = cart.lines.fold<int>(0, (sum, l) => sum + l.quantity);

    return Scaffold(
      backgroundColor: context.z.bg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('yourCart'.tr()),
            if (hasLines)
              Text(
                '${'itemCount'.plural(itemCount)} · ${'deliveryEta'.tr()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.bodySmall,
              ),
          ],
        ),
        actions: [
          if (hasLines && cart.bill.savingsPaise > 0)
            Padding(
              padding: const EdgeInsets.only(right: ZSpace.screen),
              // Shrinks rather than pushing the title off at large text.
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _SavePill(savingsPaise: cart.bill.savingsPaise),
                ),
              ),
            ),
        ],
      ),
      body: _body(context, ref, cart),
      bottomNavigationBar: hasLines ? _CheckoutSheet(cart: cart) : null,
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, CartState cart) {
    final z = context.z;
    final t = Theme.of(context).textTheme;

    if (cart.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('somethingWentWrong'.tr(), style: t.bodyMedium),
            const SizedBox(height: ZSpace.x3),
            FilledButton(
              onPressed: () => ref.read(cartProvider.notifier).retry(),
              child: Text('retry'.tr()),
            ),
          ],
        ),
      );
    }

    if (cart.loading) return const _CartSkeleton();

    if (cart.lines.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(ZSpace.x6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: z.brandSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_basket_outlined,
                  size: 52,
                  color: z.brandText,
                ),
              ),
              const SizedBox(height: ZSpace.x4),
              Text(
                'emptyCart'.tr(),
                textAlign: TextAlign.center,
                style: t.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        ZSpace.screen,
        ZSpace.x2,
        ZSpace.screen,
        ZSpace.x4,
      ),
      children: [
        const _DeliverToCard(),
        const SizedBox(height: ZSpace.x3),
        _Card(
          padding: const EdgeInsets.fromLTRB(
            ZSpace.x4,
            ZSpace.x2,
            ZSpace.x4,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final line in cart.lines)
                MyCartItem(key: ValueKey(line.variant.id), line: line),
              Center(
                child: TextButton.icon(
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : ref.read(navBarProvider.notifier).updateIndex(0),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text('addMoreItems'.tr()),
                ),
              ),
            ],
          ),
        ),
        if (cart.delivery.minOrderPaise > 0 ||
            cart.delivery.hasFreeDeliveryGoal)
          const SizedBox(height: ZSpace.x3),
        ZDeliveryProgress(
          itemTotalPaise: cart.bill.itemTotalPaise,
          delivery: cart.delivery,
        ),
        const SizedBox(height: ZSpace.x3),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _CouponCard(coupon: cart.appliedCoupon)),
              const SizedBox(width: ZSpace.x3),
              Expanded(child: _TipCard(tipPaise: cart.tipPaise)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Floating section card (radius 22, no border).
class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(ZSpace.x4),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return DecoratedBox(
      decoration: z.card(),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: ZRadius.all(ZRadius.card)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// A rounded-square icon on a soft tint (cards' leading icons).
class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.fg, required this.bg});

  final IconData icon;
  final Color fg, bg;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: ZRadius.all(ZRadius.control),
    ),
    child: Icon(icon, color: fg, size: 20),
  );
}

/// "You save ₹50" next to the title.
class _SavePill extends StatelessWidget {
  const _SavePill({required this.savingsPaise});

  final int savingsPaise;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: z.okSoft,
        borderRadius: ZRadius.all(ZRadius.chip),
      ),
      child: Text(
        'youSave'.tr(args: [rupees(savingsPaise)]),
        style: Theme.of(context).textTheme.labelMedium!
            .copyWith(color: z.ok, fontWeight: FontWeight.w800),
      ),
    );
  }
}

/// "DELIVER TO · HOME / Ranchi Road, Purulia · Change" (opens the same
/// address sheet as Home).
class _DeliverToCard extends ConsumerWidget {
  const _DeliverToCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final location = ref.watch(currentLocation);
    final label = location.label == null
        ? 'currentLocation'.tr()
        : addressLabelText(location.label!);
    return _Card(
      padding: const EdgeInsets.all(ZSpace.x3),
      onTap: () => bottomSheet(context, ref),
      child: Row(
        children: [
          _IconTile(
            icon: Icons.home_outlined,
            fg: z.brandText,
            bg: z.brandSoft,
          ),
          const SizedBox(width: ZSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'deliverToLabel'.tr(args: [label]).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelSmall!.copyWith(color: z.ink3),
                ),
                Text(
                  location.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelLarge,
                ),
              ],
            ),
          ),
          const SizedBox(width: ZSpace.x2),
          Text(
            'change'.tr(),
            style: t.labelLarge!.copyWith(
              color: z.brandText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Half-width card: the applied coupon, or an invitation to enter one.
/// Opens the coupon field in a sheet.
class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.coupon});

  final Coupon? coupon;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final code = coupon?.code;
    return _Card(
      padding: const EdgeInsets.all(ZSpace.x3),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        // Edge-to-edge: keep the field above Android's navigation bar, and
        // above the keyboard while typing.
        builder: (context) => Padding(
          padding: EdgeInsets.fromLTRB(
            ZSpace.screen,
            0,
            ZSpace.screen,
            ZSpace.x6 +
                max(
                  MediaQuery.viewInsetsOf(context).bottom,
                  MediaQuery.viewPaddingOf(context).bottom,
                ),
          ),
          child: Consumer(
            builder: (context, ref, _) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('coupons'.tr(), style: t.titleMedium),
                const SizedBox(height: ZSpace.x3),
                _CouponField(
                  appliedCoupon: ref.watch(
                    cartProvider.select((c) => c.appliedCoupon),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          _IconTile(icon: Icons.local_offer_outlined, fg: z.ok, bg: z.okSoft),
          const SizedBox(width: ZSpace.x2),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'coupons'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelLarge,
                ),
                Text(
                  code ?? 'couponsHint'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodySmall!.copyWith(
                    color: code == null ? z.ink3 : z.ok,
                    fontWeight: code == null ? null : FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Half-width card: the rider tip; opens the tip boxes in a sheet.
class _TipCard extends ConsumerWidget {
  const _TipCard({required this.tipPaise});

  final int tipPaise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return _Card(
      padding: const EdgeInsets.all(ZSpace.x3),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        builder: (context) => Padding(
          padding: EdgeInsets.fromLTRB(
            ZSpace.screen,
            0,
            ZSpace.screen,
            ZSpace.x6 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          child: Consumer(
            builder: (context, ref, _) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('tip'.tr(), style: t.titleMedium),
                const SizedBox(height: ZSpace.x2),
                TipSelector(
                  tipPaise: ref.watch(cartProvider.select((c) => c.tipPaise)),
                  onChanged: (tip) =>
                      ref.read(cartProvider.notifier).setTip(tip),
                ),
              ],
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          _IconTile(
            icon: Icons.favorite_border_rounded,
            fg: z.brandText,
            bg: z.brandSoft,
          ),
          const SizedBox(width: ZSpace.x2),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'tipRider'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelLarge,
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        tipPaise == 0 ? 'tipNone'.tr() : rupees(tipPaise),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySmall!.copyWith(
                          color: tipPaise == 0 ? z.ink3 : z.brandText,
                          fontWeight: tipPaise == 0 ? null : FontWeight.w800,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: z.ink3,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The sticky sheet: "Items ₹447 · Delivery ₹25 · Handling ₹5 · Bill ▴"
/// (expands to the full bill) and the "₹477 TO PAY · Checkout ›" button.
class _CheckoutSheet extends ConsumerStatefulWidget {
  const _CheckoutSheet({required this.cart});

  final CartState cart;

  @override
  ConsumerState<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends ConsumerState<_CheckoutSheet> {
  bool _billOpen = false;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final cart = widget.cart;
    final bill = cart.bill;
    final belowMinimum =
        cart.delivery.remainingForMinimum(bill.itemTotalPaise) > 0;
    final areaId = ref.watch(shoppingAreaIdProvider);
    final hasOutOfStock = cart.lines.any(
      (l) => !variantInStock(l.product, l.variant.id, areaId),
    );
    final blocked = belowMinimum || hasOutOfStock;
    final motion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : ZMotion.ui;

    return Container(
      decoration: BoxDecoration(
        color: z.surface,
        borderRadius: ZRadius.sheetTop,
        boxShadow: z.barShadow,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            ZSpace.screen,
            ZSpace.x2,
            ZSpace.screen,
            ZSpace.x3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: z.line2,
                    borderRadius: ZRadius.all(2),
                  ),
                ),
              ),
              AnimatedSize(
                duration: motion,
                curve: ZMotion.standard,
                alignment: Alignment.bottomCenter,
                child: _billOpen
                    ? Padding(
                        padding: const EdgeInsets.only(top: ZSpace.x3),
                        child: BillDetails(bill: bill),
                      )
                    : const SizedBox(width: double.infinity),
              ),
              Semantics(
                button: true,
                expanded: _billOpen,
                child: InkWell(
                  onTap: () => setState(() => _billOpen = !_billOpen),
                  borderRadius: ZRadius.all(ZRadius.control),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: ZSize.touch),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'billSummary'.tr(
                              args: [
                                rupees(bill.itemTotalPaise),
                                bill.deliveryFeePaise == 0
                                    ? 'free'.tr()
                                    : rupees(bill.deliveryFeePaise),
                                rupees(bill.handlingFeePaise),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: t.bodySmall!.copyWith(color: z.ink2),
                          ),
                        ),
                        const SizedBox(width: ZSpace.x2),
                        Text(
                          'billShort'.tr(),
                          style: t.labelLarge!.copyWith(
                            color: z.brandText,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Icon(
                          _billOpen
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.keyboard_arrow_up_rounded,
                          size: 20,
                          color: z.brandText,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: ZSpace.x1),
              Semantics(
                button: true,
                child: ZPressable(
                  // Below the minimum order the button explains why instead
                  // of opening checkout.
                  onTap: hasOutOfStock
                      ? () => showError('errorCartOutOfStock'.tr())
                      : belowMinimum
                      ? () => showError(
                          'errorMinOrder'.tr(
                            args: [rupees(cart.delivery.minOrderPaise)],
                          ),
                        )
                      : () => context.push('/checkoutScreen'),
                  child: AnimatedContainer(
                    duration: motion,
                    constraints: const BoxConstraints(minHeight: ZSize.button),
                    padding: const EdgeInsets.symmetric(
                      horizontal: ZSpace.x4,
                      vertical: ZSpace.x2,
                    ),
                    decoration: BoxDecoration(
                      color: blocked ? z.ink3 : z.brand,
                      borderRadius: ZRadius.all(ZRadius.button),
                    ),
                    child: Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rupees(bill.totalPaise),
                              style: t.labelLarge!.copyWith(
                                color: z.onBrand,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'toPay'.tr().toUpperCase(),
                              style: t.labelSmall!.copyWith(
                                color: z.headerInk2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: ZSpace.x3),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'checkout'.tr(),
                                  style: t.titleMedium!.copyWith(
                                    color: z.onBrand,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: z.onBrand,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartSkeleton extends StatelessWidget {
  const _CartSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(ZSpace.screen),
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        ZSkeleton(height: 220, radius: ZRadius.card),
        SizedBox(height: ZSpace.x3),
        ZSkeleton(height: 72, radius: ZRadius.card),
        SizedBox(height: ZSpace.x3),
        ZSkeleton(height: 240, radius: ZRadius.card),
      ],
    );
  }
}

/// Coupon entry (the bill reacts to it). Once applied: the code with
/// "Remove", or how much more is needed for its minimum order.
class _CouponField extends ConsumerStatefulWidget {
  final Coupon? appliedCoupon;

  const _CouponField({required this.appliedCoupon});

  @override
  ConsumerState<_CouponField> createState() => _CouponFieldState();
}

class _CouponFieldState extends ConsumerState<_CouponField> {
  final _controller = TextEditingController();
  bool _applying = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final code = _controller.text.trim();
    if (code.isEmpty) return;
    setState(() => _applying = true);
    await ref
        .read(cartProvider.notifier)
        .applyCoupon(
          code,
          serviceAreaId: ref.read(currentLocation).serviceArea?.id,
        );
    if (mounted) setState(() => _applying = false);
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final (:couponError, :itemTotalPaise) = ref.watch(
      cartProvider.select(
        (c) =>
            (couponError: c.couponError, itemTotalPaise: c.bill.itemTotalPaise),
      ),
    );
    final coupon = widget.appliedCoupon;

    final icon = Container(
      width: ZSize.touch,
      height: ZSize.touch,
      decoration: BoxDecoration(
        color: z.okSoft,
        borderRadius: ZRadius.all(ZRadius.control),
      ),
      child: Icon(Icons.local_offer_outlined, color: z.ok, size: 20),
    );

    if (coupon != null) {
      // Applied, but the cart is below the coupon's minimum: say how much
      // more is needed instead of claiming a discount that isn't there.
      final shortBy = (coupon.minOrderPaise ?? 0) - itemTotalPaise;

      return Row(
        children: [
          icon,
          const SizedBox(width: ZSpace.x3),
          Expanded(
            child: Text(
              shortBy > 0
                  ? 'couponAddMore'.tr(
                      namedArgs: {
                        'amount': rupees(shortBy),
                        'code': coupon.code,
                      },
                    )
                  : '${coupon.code} · ${'couponApplied'.tr()}',
              style: t.labelLarge!.copyWith(color: shortBy > 0 ? z.ink2 : z.ok),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(cartProvider.notifier).removeCoupon(),
            child: Text('remove'.tr()),
          ),
        ],
      );
    }

    final error = couponError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            icon,
            const SizedBox(width: ZSpace.x3),
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _apply(),
                decoration: InputDecoration(
                  hintText: 'couponCode'.tr(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: ZSpace.x2),
            _applying
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : TextButton(
                    onPressed: _apply,
                    child: Text('applyCoupon'.tr()),
                  ),
          ],
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: ZSpace.x2),
            child: Text(
              // couponError holds a translation key.
              error.tr(),
              style: t.bodySmall!.copyWith(color: z.danger),
            ),
          ),
      ],
    );
  }
}
