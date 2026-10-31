import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/app_skeleton.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/common_widgets/text_form_field.dart';
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

  Widget _buildBody(BuildContext context, WidgetRef ref, cart, double height) {
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
  final dynamic appliedCoupon;

  const _CouponField({required this.appliedCoupon});

  @override
  ConsumerState<_CouponField> createState() => _CouponFieldState();
}

class _CouponFieldState extends ConsumerState<_CouponField> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget.appliedCoupon != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              '${widget.appliedCoupon.code} · ${'couponApplied'.tr()}',
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.green,
              ),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(cartProvider.notifier).removeCoupon(),
            child: Text('close'.tr()),
          ),
        ],
      );
    }

    return Row(
      spacing: AppSpacing.sm,
      children: [
        Expanded(
          child: TextformField(
            textFormFieldController: _controller,
            labelText: 'couponCode'.tr(),
          ),
        ),
        TextButton(
          onPressed: () =>
              ref.read(cartProvider.notifier).applyCoupon(_controller.text),
          child: Text('applyCoupon'.tr()),
        ),
      ],
    );
  }
}
