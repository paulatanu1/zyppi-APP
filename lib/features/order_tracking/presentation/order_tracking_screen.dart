import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/common_widgets/app_skeleton.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/theme/app_colors.dart';
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

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderTrackingProvider(orderId));
    final order = state.order;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: Text('trackOrder'.tr())),
      body: AppSkeleton(
        enabled: state.loading,
        child: order == null
            ? Center(
                child: Text(
                  'somethingWentWrong'.tr(),
                  style: AppTypography.bodyMedium,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'yourDeliveryPartner'.tr(),
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    ..._timeline.map((status) {
                      final currentIndex = _timeline.indexOf(order.status);
                      final stepIndex = _timeline.indexOf(status);
                      final isDone = stepIndex <= currentIndex;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              isDone
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isDone ? AppColors.green : AppColors.grey,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _statusLabel(status),
                              style: AppTypography.bodyLarge.copyWith(
                                color: isDone ? AppColors.ink : AppColors.muted,
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
    );
  }
}
