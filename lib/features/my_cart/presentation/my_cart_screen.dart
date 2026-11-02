import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/cart/application/cart_state.dart';
import 'package:zippy/core/common_widgets/app_skeleton.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/common_widgets/text_form_field.dart';
import 'package:zippy/core/domain/coupon.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/my_cart/widgets/bill_details.dart';
import 'package:zippy/features/my_cart/widgets/my_cart_item.dart';
import 'package:zippy/features/my_cart/widgets/tip_selector.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

class MyCartScreen extends ConsumerWidget {
  const MyCartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = MediaQuery.of(context).size.height;
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(title: Text('myCart'.tr())),
      body: SafeArea(top: false, child: _buildBody(context, ref, cart, height)),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    CartState cart,
    double height,
  ) {
    if (cart.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('somethingWentWrong'.tr(), style: AppTypography.bodyMedium),
            SizedBox(height: height * 0.015),
            SizedBox(
              width: 160,
              child: PrimaryButton(
                buttonTitle: 'retry'.tr(),
                action: () => ref.read(cartProvider.notifier).retry(),
              ),
            ),
          ],
        ),
      );
    }

    if (!cart.loading && cart.lines.isEmpty) {
      return Center(
        child: Text('emptyCart'.tr(), style: AppTypography.bodyMedium),
      );
    }

    return AppSkeleton(
      enabled: cart.loading,
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (cart.bill.savingsPaise > 0)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.base,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.primaryTint,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                  child: Text(
                    'savingsBanner'.tr(
                      args: [PriceTag.format(cart.bill.savingsPaise)],
                    ),
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ...cart.lines.map((line) => MyCartItem(line: line)),
            BillDetails(bill: cart.bill),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _CouponField(appliedCoupon: cart.appliedCoupon),
            ),
            TipSelector(
              tipPaise: cart.tipPaise,
              onChanged: (tip) => ref.read(cartProvider.notifier).setTip(tip),
            ),
            SizedBox(height: height * 0.02),
            Padding(
              padding: EdgeInsets.only(
                left: height * 0.02,
                right: height * 0.02,
              ),
              child: PrimaryButton(
                buttonTitle: 'proceedToCheckout'.tr(),
                action: () => context.push('/checkoutScreen'),
              ),
            ),
            SizedBox(height: height * 0.04),
          ],
        ),
      ),
    );
  }
}

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
    final cart = ref.watch(cartProvider);
    final coupon = widget.appliedCoupon;

    if (coupon != null) {
      // Applied, but the cart is below the coupon's minimum: say how much
      // more is needed instead of claiming a discount that isn't there.
      final shortBy = (coupon.minOrderPaise ?? 0) - cart.bill.itemTotalPaise;

      return Row(
        children: [
          Expanded(
            child: Text(
              shortBy > 0
                  ? 'couponAddMore'.tr(
                      namedArgs: {
                        'amount': PriceTag.format(shortBy),
                        'code': coupon.code,
                      },
                    )
                  : '${coupon.code} · ${'couponApplied'.tr()}',
              style: AppTypography.bodyMedium.copyWith(
                color: shortBy > 0
                    ? context.colors.muted
                    : context.colors.green,
              ),
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
          spacing: AppSpacing.sm,
          children: [
            Expanded(
              child: TextformField(
                textFormFieldController: _controller,
                labelText: 'couponCode'.tr(),
              ),
            ),
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
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              // couponError holds a translation key.
              error.tr(),
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.danger,
              ),
            ),
          ),
      ],
    );
  }
}
