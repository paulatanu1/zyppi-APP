import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/cart/application/cart_state.dart';
import 'package:zippy/core/domain/coupon.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/address_label.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/core/widgets/z_commerce.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/my_cart/widgets/bill_details.dart';
import 'package:zippy/features/my_cart/widgets/my_cart_item.dart';
import 'package:zippy/features/my_cart/widgets/tip_selector.dart';

/// docs/screens/light/09-cart.png. Both a tab and a pushed route
/// (`/myCartScreen`); the back arrow only shows when pushed. The
/// free-delivery / minimum-order bar follows `config/delivery`. Left out
/// until the data exists: Share.
class MyCartScreen extends ConsumerWidget {
  const MyCartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final hasLines =
        !cart.loading && cart.error == null && cart.lines.isNotEmpty;

    return Scaffold(
      backgroundColor: context.z.bg,
      appBar: AppBar(title: Text('yourCart'.tr())),
      body: _body(context, ref, cart),
      bottomNavigationBar: hasLines ? _CheckoutBar(cart: cart) : null,
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
              Icon(Icons.shopping_bag_outlined, size: 48, color: z.ink3),
              const SizedBox(height: ZSpace.x3),
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

    final itemCount = cart.lines.fold<int>(0, (sum, l) => sum + l.quantity);

    return ListView(
      padding: const EdgeInsets.all(ZSpace.screen),
      children: [
        if (cart.bill.savingsPaise > 0) ...[
          _Card(
            color: z.okSoft,
            borderColor: z.okSoft,
            child: Row(
              children: [
                Icon(Icons.savings_outlined, color: z.ok, size: 20),
                const SizedBox(width: ZSpace.x3),
                Expanded(
                  child: Text(
                    'savingsBanner'.tr(args: [rupees(cart.bill.savingsPaise)]),
                    style: t.labelMedium!.copyWith(color: z.ok),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ZSpace.x3),
        ],
        ZDeliveryProgress(
          itemTotalPaise: cart.bill.itemTotalPaise,
          delivery: cart.delivery,
        ),
        if (cart.delivery.minOrderPaise > 0 ||
            cart.delivery.hasFreeDeliveryGoal)
          const SizedBox(height: ZSpace.x3),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('deliveryEta'.tr(), style: t.titleMedium),
                  ),
                  Text('itemCount'.plural(itemCount), style: t.bodySmall),
                ],
              ),
              const SizedBox(height: ZSpace.x2),
              for (final line in cart.lines)
                MyCartItem(key: ValueKey(line.variant.id), line: line),
            ],
          ),
        ),
        const SizedBox(height: ZSpace.x3),
        _Card(child: _CouponField(appliedCoupon: cart.appliedCoupon)),
        const SizedBox(height: ZSpace.x3),
        _Card(
          child: BillDetails(
            bill: cart.bill,
            tipSelector: TipSelector(
              tipPaise: cart.tipPaise,
              onChanged: (tip) => ref.read(cartProvider.notifier).setTip(tip),
            ),
          ),
        ),
        const SizedBox(height: ZSpace.x4),
      ],
    );
  }
}

/// White rounded section card.
class _Card extends StatelessWidget {
  const _Card({required this.child, this.color, this.borderColor});

  final Widget child;
  final Color? color, borderColor;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Container(
      padding: const EdgeInsets.all(ZSpace.x4),
      decoration: BoxDecoration(
        color: color ?? z.surface,
        borderRadius: ZRadius.all(ZRadius.card),
        border: Border.all(color: borderColor ?? z.line),
      ),
      child: child,
    );
  }
}

/// "DELIVER TO · HOME / Ranchi Road, Purulia" and the "₹477 TOTAL ·
/// Checkout ›" button.
class _CheckoutBar extends ConsumerWidget {
  const _CheckoutBar({required this.cart});

  final CartState cart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final location = ref.watch(currentLocation);
    final label = location.label == null
        ? 'currentLocation'.tr()
        : addressLabelText(location.label!);
    final belowMinimum =
        cart.delivery.remainingForMinimum(cart.bill.itemTotalPaise) > 0;

    return Container(
      decoration: BoxDecoration(
        color: z.surface,
        border: Border(top: BorderSide(color: z.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(ZSpace.x3),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: ZSpace.x1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
              ),
              const SizedBox(width: ZSpace.x3),
              // Up to two thirds of the bar; the label shrinks to fit at
              // large text sizes.
              Flexible(
                flex: 2,
                child: Semantics(
                  button: true,
                  child: ZPressable(
                    // Below the minimum order the button explains why
                    // instead of opening checkout.
                    onTap: belowMinimum
                        ? () => showError(
                            'errorMinOrder'.tr(
                              args: [rupees(cart.delivery.minOrderPaise)],
                            ),
                          )
                        : () => context.push('/checkoutScreen'),
                    child: AnimatedContainer(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : ZMotion.ui,
                      constraints: const BoxConstraints(
                        minHeight: ZSize.button,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: ZSpace.x4,
                        vertical: ZSpace.x2,
                      ),
                      decoration: BoxDecoration(
                        color: belowMinimum ? z.ink3 : z.brand,
                        borderRadius: ZRadius.all(ZRadius.button),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rupees(cart.bill.totalPaise),
                                  style: t.labelLarge!.copyWith(
                                    color: z.onBrand,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'total'.tr(),
                                  style: t.labelSmall!.copyWith(
                                    color: z.headerInk2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: ZSpace.x4),
                            Text(
                              'checkout'.tr(),
                              style: t.titleMedium!.copyWith(color: z.onBrand),
                            ),
                            Icon(Icons.chevron_right_rounded, color: z.onBrand),
                          ],
                        ),
                      ),
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
    await ref.read(cartProvider.notifier).applyCoupon(code);
    if (mounted) setState(() => _applying = false);
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final cart = ref.watch(cartProvider);
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
      final shortBy = (coupon.minOrderPaise ?? 0) - cart.bill.itemTotalPaise;

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

    final error = cart.couponError;

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
