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
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/order_tracking/application/order_tracking_provider.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

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
      backgroundColor: context.colors.primaryTint,
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
                  color: context.colors.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.sheetTop),
                    topRight: Radius.circular(AppRadius.sheetTop),
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
                                      if (_etaText(order) case final eta?) ...[
                                        Text(
                                          'arrivingIn'.tr(),
                                          style: AppTypography.labelSmall
                                              .copyWith(
                                                color: context.colors.muted,
                                              ),
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
                                      horizontal: AppSpacing.lg,
                                      vertical: AppSpacing.sm,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.colors.primaryTint,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.chip,
                                      ),
                                    ),
                                    child: Text(
                                      _statusLabel(order.status),
                                      style: AppTypography.labelSmall.copyWith(
                                        color: context.colors.primaryDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: context.colors.line,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.card,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: context.colors.divider,
                                      child: Icon(
                                        Icons.person_outline,
                                        color: context.colors.muted,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.lg),
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
                                                  color: context.colors.muted,
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
                              const SizedBox(height: AppSpacing.xxl),
                              if (order.status == OrderStatus.cancelled)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  decoration: BoxDecoration(
                                    color: context.colors.dangerTint,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.card,
                                    ),
                                  ),
                                  child: Text(
                                    'orderCancelledInfo'.tr(),
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: context.colors.danger,
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
                                      vertical: AppSpacing.sm,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isDone
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: isDone
                                              ? context.colors.primary
                                              : context.colors.faint,
                                        ),
                                        const SizedBox(width: AppSpacing.lg),
                                        Text(
                                          _statusLabel(status),
                                          style: AppTypography.bodyLarge
                                              .copyWith(
                                                color: isDone
                                                    ? context.colors.ink
                                                    : context.colors.muted,
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
