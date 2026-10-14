import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/app_skeleton.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/order_tracking/application/order_tracking_provider.dart';

const _timeline = [
  OrderStatus.placed,
  OrderStatus.packed,
  OrderStatus.outForDelivery,
  OrderStatus.delivered,
];

String _statusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.placed:
      return 'orderStatusPlaced'.tr();
    case OrderStatus.packed:
      return 'orderStatusPacked'.tr();
    case OrderStatus.outForDelivery:
      return 'orderStatusOutForDelivery'.tr();
    case OrderStatus.delivered:
      return 'orderStatusDelivered'.tr();
    case OrderStatus.cancelled:
      return 'orderStatusCancelled'.tr();
  }
}

/// docs/mockups/Tracking.dc.html, minus the decorative map/rider-route
/// illustration.
class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderTrackingProvider(orderId));
    final order = state.order;

    return Scaffold(
      backgroundColor: AppColors.primaryTint,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.go('/navBar'),
                    icon: const Icon(Icons.close),
                  ),
                  TextButton(onPressed: () {}, child: Text('help'.tr())),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.sheetTop),
                    topRight: Radius.circular(AppRadius.sheetTop),
                  ),
                ),
                child: AppSkeleton(
                  enabled: state.loading,
                  child: order == null
                      ? Center(
                          child: Text(
                            'somethingWentWrong'.tr(),
                            style: AppTypography.bodyMedium,
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'arrivingIn'.tr(),
                                        style: AppTypography.labelSmall
                                            .copyWith(color: AppColors.muted),
                                      ),
                                      Text(
                                        order.status == OrderStatus.delivered
                                            ? _statusLabel(order.status)
                                            : '6 min',
                                        style: AppTypography.headlineSmall,
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.lg,
                                      vertical: AppSpacing.sm,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryTint,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.chip,
                                      ),
                                    ),
                                    child: Text(
                                      _statusLabel(order.status),
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.line),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.card,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 22,
                                      backgroundColor: AppColors.divider,
                                      child: Icon(
                                        Icons.person_outline,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.lg),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'riderNamePlaceholder'.tr(),
                                            style: AppTypography.bodyMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          Text(
                                            'yourDeliveryPartner'.tr(),
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                                  color: AppColors.muted,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: AppColors.primary,
                                      child: const Icon(
                                        Icons.call,
                                        color: AppColors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              ..._timeline.map((status) {
                                final currentIndex = _timeline.indexOf(
                                  order.status,
                                );
                                final stepIndex = _timeline.indexOf(status);
                                final isDone = stepIndex <= currentIndex;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.sm,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isDone
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: isDone
                                            ? AppColors.primary
                                            : AppColors.grey,
                                      ),
                                      const SizedBox(width: AppSpacing.lg),
                                      Text(
                                        _statusLabel(status),
                                        style: AppTypography.bodyLarge.copyWith(
                                          color: isDone
                                              ? AppColors.ink
                                              : AppColors.muted,
                                          fontWeight: isDone
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
