import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/order_placed/application/order_by_id_provider.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

/// docs/mockups/Placed.dc.html — full-bleed pink confirmation.
class OrderPlacedScreen extends ConsumerWidget {
  final String orderId;

  const OrderPlacedScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderByIdProvider(orderId)).value;

    return Scaffold(
      backgroundColor: context.colors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.huge,
            vertical: AppSpacing.giant,
          ),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 132,
                      height: 132,
                      decoration: BoxDecoration(
                        color: context.colors.primaryDark,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            color: context.colors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: context.colors.primaryDark,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.huge),
                    Text(
                      'orderPlaced'.tr(),
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'orderPlacedDescription'.tr(),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        color: context.colors.onPrimaryMuted,
                      ),
                    ),
                    if (order != null) ...[
                      const SizedBox(height: AppSpacing.xxl),
                      _KeyValueRow(
                        label: 'orderId'.tr(),
                        value: '#${order.id}',
                      ),
                      _KeyValueRow(
                        label: '${'paidVia'.tr()} ${order.paymentMethod}',
                        value: PriceTag.format(order.totalPaise),
                      ),
                      _KeyValueRow(
                        label: 'deliverTo'.tr(),
                        value: 'home'.tr(),
                        showDivider: false,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.button,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.accent,
                        foregroundColor: context.colors.ink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.input),
                        ),
                      ),
                      onPressed: () =>
                          context.go('/orderTrackingScreen?orderId=$orderId'),
                      child: Text(
                        'trackOrder'.tr(),
                        style: AppTypography.labelLarge.copyWith(
                          color: context.colors.ink,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/navBar'),
                    child: Text(
                      'backToHome'.tr(),
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _KeyValueRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: context.colors.dividerOnPrimary))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.onPrimaryMuted,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
