import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/utils/launch.dart';
import 'package:zippy/core/utils/order_id.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/common_widgets/help_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/app_skeleton.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/order_tracking/application/order_tracking_provider.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

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

/// Minutes left on the delivery slot's promise ("8 min"), "Arriving soon"
/// once it's passed, or null when there's nothing to promise (delivered,
/// cancelled, or no slot ETA known).
String? _etaText(Order order) {
  if (order.status == OrderStatus.delivered ||
      order.status == OrderStatus.cancelled) {
    return null;
  }
  final eta = order.etaMinutes;
  if (eta == null) return null;

  final due = order.placedAt.add(Duration(minutes: eta));
  final left = due.difference(DateTime.now()).inMinutes;
  return left > 0 ? 'minutesShort'.tr(args: ['$left']) : 'arrivingSoon'.tr();
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
      backgroundColor: context.z.brandSoft,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(ZSpace.x2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.go('/navBar'),
                    icon: const Icon(Icons.close),
                    tooltip: 'close'.tr(),
                  ),
                  TextButton(
                    onPressed: () =>
                        showHelpSheet(context, orderId: shortOrderId(orderId)),
                    child: Text('help'.tr()),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.z.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(ZRadius.sheet),
                    topRight: Radius.circular(ZRadius.sheet),
                  ),
                ),
                child: AppSkeleton(
                  enabled: state.loading,
                  child: order == null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.error != null
                                    ? 'somethingWentWrong'.tr()
                                    : 'orderNotFound'.tr(),
                                style: AppTypography.bodyMedium,
                              ),
                              if (state.error != null)
                                TextButton(
                                  onPressed: ref
                                      .read(
                                        orderTrackingProvider(orderId).notifier,
                                      )
                                      .retry,
                                  child: Text('retry'.tr()),
                                ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(ZSpace.x4),
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
                                      if (_etaText(order) case final eta?) ...[
                                        Text(
                                          'arrivingIn'.tr(),
                                          style: AppTypography.labelSmall
                                              .copyWith(color: context.z.ink2),
                                        ),
                                        Text(
                                          eta,
                                          style: AppTypography.headlineSmall,
                                        ),
                                      ] else
                                        Text(
                                          _statusLabel(order.status),
                                          style: AppTypography.headlineSmall,
                                        ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: ZSpace.x3,
                                      vertical: ZSpace.x2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.z.brandSoft,
                                      borderRadius: BorderRadius.circular(
                                        ZRadius.chip,
                                      ),
                                    ),
                                    child: Text(
                                      _statusLabel(order.status),
                                      style: AppTypography.labelSmall.copyWith(
                                        color: context.z.brandPress,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: ZSpace.x4),
                              Container(
                                padding: const EdgeInsets.all(ZSpace.x3),
                                decoration: BoxDecoration(
                                  border: Border.all(color: context.z.line),
                                  borderRadius: BorderRadius.circular(
                                    ZRadius.card,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: context.colors.divider,
                                      child: Icon(
                                        Icons.person_outline,
                                        color: context.z.ink2,
                                      ),
                                    ),
                                    const SizedBox(width: ZSpace.x3),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.riderName ??
                                                'riderNotAssigned'.tr(),
                                            style: AppTypography.bodyMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          Text(
                                            'yourDeliveryPartner'.tr(),
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                                  color: context.z.ink2,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (order.riderPhone case final phone?
                                        when phone.isNotEmpty)
                                      IconButton.filled(
                                        tooltip: 'callRider'.tr(),
                                        onPressed: () =>
                                            openExternal(phoneUri(phone)),
                                        icon: const Icon(Icons.call, size: 18),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: ZSpace.x4),
                              if (order.status == OrderStatus.cancelled)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(ZSpace.x3),
                                  decoration: BoxDecoration(
                                    color: context.z.dangerSoft,
                                    borderRadius: BorderRadius.circular(
                                      ZRadius.card,
                                    ),
                                  ),
                                  child: Text(
                                    'orderCancelledInfo'.tr(),
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: context.z.danger,
                                    ),
                                  ),
                                )
                              else
                                ..._timeline.map((status) {
                                  final currentIndex = _timeline.indexOf(
                                    order.status,
                                  );
                                  final stepIndex = _timeline.indexOf(status);
                                  final isDone = stepIndex <= currentIndex;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: ZSpace.x2,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isDone
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: isDone
                                              ? context.z.brand
                                              : context.z.ink3,
                                        ),
                                        const SizedBox(width: ZSpace.x3),
                                        Text(
                                          _statusLabel(status),
                                          style: AppTypography.bodyLarge
                                              .copyWith(
                                                color: isDone
                                                    ? context.z.ink
                                                    : context.z.ink2,
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
