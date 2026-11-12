import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/widgets/z_brand_texture.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/common_widgets/help_sheet.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/launch.dart';
import 'package:zippy/core/widgets/z_commerce.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/order_tracking/application/order_tracking_provider.dart';
import 'package:zippy/features/order_tracking/widgets/tracking_map.dart';

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

/// docs/screens/light/12-tracking.png: drawn map (see [TrackingMap]) with
/// back and Help, then a sheet with the ETA, status, 4-step progress, rider
/// card and the order summary.
class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  static const double _mapHeight = 380;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final state = ref.watch(orderTrackingProvider(orderId));
    final order = state.order;
    final top = MediaQuery.paddingOf(context).top;

    final Widget sheet;
    if (state.loading && order == null) {
      sheet = const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ZSkeleton(width: 90, height: 12),
          SizedBox(height: ZSpace.x2),
          ZSkeleton(width: 120, height: 36),
          SizedBox(height: ZSpace.x5),
          ZSkeleton(height: 8),
          SizedBox(height: ZSpace.x6),
          ZSkeleton(height: 84, radius: ZRadius.card),
        ],
      );
    } else if (order == null) {
      sheet = Padding(
        padding: const EdgeInsets.symmetric(vertical: ZSpace.x6),
        child: Column(
          children: [
            Text(
              state.error != null
                  ? 'somethingWentWrong'.tr()
                  : 'orderNotFound'.tr(),
              textAlign: TextAlign.center,
              style: t.bodyMedium,
            ),
            if (state.error != null)
              TextButton(
                onPressed: ref
                    .read(orderTrackingProvider(orderId).notifier)
                    .retry,
                child: Text('retry'.tr()),
              ),
          ],
        ),
      );
    } else {
      sheet = _SheetContent(order: order);
    }

    return Scaffold(
      backgroundColor: z.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: top + _mapHeight,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: TrackingMap(
                      status: order?.status ?? OrderStatus.placed,
                    ),
                  ),
                  Positioned(
                    left: ZSpace.screen,
                    top: top + ZSpace.x2,
                    child: _MapButton(
                      label: 'back'.tr(),
                      onTap: () => context.canPop()
                          ? context.pop()
                          : context.go('/navBar'),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: z.ink,
                      ),
                    ),
                  ),
                  Positioned(
                    right: ZSpace.screen,
                    top: top + ZSpace.x2,
                    child: _MapButton(
                      label: 'help'.tr(),
                      onTap: () => showHelpSheet(context, orderId: orderId),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ZSpace.x3,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.help_outline_rounded,
                              size: 20,
                              color: z.ink,
                            ),
                            const SizedBox(width: ZSpace.x1),
                            Text('help'.tr(), style: t.labelLarge),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Sheet overlapping the map by its corner radius.
            Transform.translate(
              offset: const Offset(0, -ZRadius.sheet),
              child: Container(
                decoration: BoxDecoration(
                  color: z.surface,
                  borderRadius: ZRadius.sheetTop,
                ),
                padding: EdgeInsets.fromLTRB(
                  ZSpace.screen + ZSpace.x1,
                  ZSpace.x3,
                  ZSpace.screen + ZSpace.x1,
                  ZSpace.x6 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
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
                    const SizedBox(height: ZSpace.x5),
                    sheet,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White rounded button over the map (44 pt tall).
class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.label,
    required this.onTap,
    required this.child,
  });

  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: ZPressable(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minWidth: ZSize.touch,
            minHeight: ZSize.touch,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: z.surface,
            borderRadius: ZRadius.all(ZRadius.input),
            boxShadow: [
              BoxShadow(
                color: z.shadow,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SheetContent extends StatelessWidget {
  const _SheetContent({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final eta = _etaText(order);
    final current = _timeline.indexOf(order.status);
    final itemCount = order.items.fold<int>(0, (s, i) => s + i.quantity);
    final (badgeBg, badgeFg) = switch (order.status) {
      OrderStatus.outForDelivery => (z.warnSoft, z.warn),
      OrderStatus.delivered => (z.okSoft, z.ok),
      OrderStatus.cancelled => (z.dangerSoft, z.danger),
      _ => (z.brandSoft, z.brandText),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ETA and status on the brand texture.
        ZBrandTexture(
          borderRadius: ZRadius.all(ZRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(ZSpace.x4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (eta != null) ...[
                        Text(
                          'arrivingIn'.tr(),
                          style: t.labelSmall!.copyWith(
                            color: z.headerInk2,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Text(
                          eta,
                          style: t.displaySmall!.copyWith(color: z.headerInk),
                        ),
                      ] else
                        Text(
                          _statusLabel(order.status),
                          style: t.headlineSmall!.copyWith(color: z.headerInk),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: ZSpace.x2),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ZSpace.x3,
                      vertical: ZSpace.x1 + 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: ZRadius.all(ZRadius.chip),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: badgeFg),
                        const SizedBox(width: ZSpace.x1),
                        Flexible(
                          child: Text(
                            _statusLabel(order.status),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.labelMedium!.copyWith(
                              color: badgeFg,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: ZSpace.x4),
        if (order.status == OrderStatus.cancelled)
          Container(
            padding: const EdgeInsets.all(ZSpace.x3),
            decoration: BoxDecoration(
              color: z.dangerSoft,
              borderRadius: ZRadius.all(ZRadius.card),
            ),
            child: Text(
              'orderCancelledInfo'.tr(),
              style: t.bodyMedium!.copyWith(color: z.danger),
            ),
          )
        else
          // 4 bars + labels; the current step's bar is half filled.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < _timeline.length; i++) ...[
                if (i > 0) const SizedBox(width: ZSpace.x2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: ZRadius.all(ZRadius.badge),
                        child: LinearProgressIndicator(
                          value: i < current
                              ? 1
                              : i == current
                              ? (order.status == OrderStatus.delivered ? 1 : .5)
                              : 0,
                          minHeight: 6,
                          color: z.brand,
                          backgroundColor: z.surface3,
                        ),
                      ),
                      const SizedBox(height: ZSpace.x2),
                      Text(
                        _statusLabel(_timeline[i]),
                        style: t.labelMedium!.copyWith(
                          color: i <= current ? z.ink : z.ink3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        const SizedBox(height: ZSpace.x5),
        Container(
          padding: const EdgeInsets.all(ZSpace.x4),
          decoration: BoxDecoration(
            border: Border.all(color: z.line),
            borderRadius: ZRadius.all(ZRadius.card),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: ZSize.touch / 2,
                backgroundColor: z.blueSoft,
                child: order.riderName?.trim().isNotEmpty ?? false
                    ? Text(
                        order.riderName!.trim().characters.first.toUpperCase(),
                        style: t.titleLarge!.copyWith(color: z.blue),
                      )
                    : Icon(Icons.person_outline_rounded, color: z.blue),
              ),
              const SizedBox(width: ZSpace.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.riderName ?? 'riderNotAssigned'.tr(),
                      style: t.titleMedium,
                    ),
                    Text('yourDeliveryPartner'.tr(), style: t.bodySmall),
                  ],
                ),
              ),
              IconButton.outlined(
                tooltip: 'messageSupport'.tr(),
                style: IconButton.styleFrom(
                  foregroundColor: z.ink,
                  side: BorderSide(color: z.line2),
                  minimumSize: const Size.square(ZSize.touch),
                  shape: RoundedRectangleBorder(
                    borderRadius: ZRadius.all(ZRadius.input),
                  ),
                ),
                onPressed: () =>
                    context.push('/supportChat?orderId=${order.id}'),
                icon: const Icon(Icons.chat_bubble_outline_rounded),
              ),
              if (order.riderPhone case final phone? when phone.isNotEmpty) ...[
                const SizedBox(width: ZSpace.x2),
                IconButton.filled(
                  tooltip: 'callRider'.tr(),
                  style: IconButton.styleFrom(
                    backgroundColor: z.ok,
                    foregroundColor: z.onBrand,
                    minimumSize: const Size.square(ZSize.touch),
                    shape: RoundedRectangleBorder(
                      borderRadius: ZRadius.all(ZRadius.input),
                    ),
                  ),
                  onPressed: () => openExternal(phoneUri(phone)),
                  icon: const Icon(Icons.call_outlined),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: ZSpace.x3),
        Material(
          color: z.surface2,
          borderRadius: ZRadius.all(ZRadius.card),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () =>
                context.push('/orderDetailsScreen?orderId=${order.id}'),
            child: Padding(
              padding: const EdgeInsets.all(ZSpace.x3),
              child: Row(
                children: [
                  for (final item in order.items.take(3))
                    Container(
                      width: ZSize.touch - 4,
                      height: ZSize.touch - 4,
                      margin: const EdgeInsets.only(right: ZSpace.x1),
                      padding: const EdgeInsets.all(ZSpace.x1),
                      decoration: BoxDecoration(
                        color: z.surface,
                        borderRadius: ZRadius.all(ZRadius.control),
                      ),
                      child: CatalogImage(
                        image: item.image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  const SizedBox(width: ZSpace.x2),
                  Expanded(
                    child: Text(
                      '${'itemCount'.plural(itemCount)} · ${rupees(order.totalPaise)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.labelLarge,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      'orderInfo'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.labelLarge!.copyWith(color: z.brandText),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
