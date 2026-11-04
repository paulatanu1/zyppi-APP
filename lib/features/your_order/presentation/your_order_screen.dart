import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/your_order/application/orders_provider.dart';
import 'package:zippy/features/your_order/widgets/your_order_widget.dart';

/// On-screen filter for the orders list (not persisted).
enum _OrdersFilter { all, active, delivered, cancelled }

extension on _OrdersFilter {
  String get label => switch (this) {
    _OrdersFilter.all => 'ordersAll'.tr(),
    _OrdersFilter.active => 'ordersActive'.tr(),
    _OrdersFilter.delivered => 'orderStatusDelivered'.tr(),
    _OrdersFilter.cancelled => 'orderStatusCancelled'.tr(),
  };

  bool matches(Order order) => switch (this) {
    _OrdersFilter.all => true,
    _OrdersFilter.active => isActiveOrder(order.status),
    _OrdersFilter.delivered => order.status == OrderStatus.delivered,
    _OrdersFilter.cancelled => order.status == OrderStatus.cancelled,
  };
}

/// docs/screens/light/13-orders.png.
class YourOrderScreen extends ConsumerStatefulWidget {
  const YourOrderScreen({super.key});

  @override
  ConsumerState<YourOrderScreen> createState() => _YourOrderScreenState();
}

class _YourOrderScreenState extends ConsumerState<YourOrderScreen> {
  _OrdersFilter _filter = _OrdersFilter.all;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final ordersAsync = ref.watch(ordersProvider);

    Widget message(String text, {Widget? action}) => Center(
      child: Padding(
        padding: const EdgeInsets.all(ZSpace.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: z.ink3),
            const SizedBox(height: ZSpace.x3),
            Text(text, textAlign: TextAlign.center, style: t.bodyMedium),
            ?action,
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: z.bg,
      appBar: AppBar(title: Text('yourOrder'.tr())),
      body: SafeArea(
        top: false,
        child: ordersAsync.when(
          skipLoadingOnRefresh: true,
          loading: () => ListView(
            padding: const EdgeInsets.all(ZSpace.screen),
            children: [
              for (var i = 0; i < 3; i++)
                const Padding(
                  padding: EdgeInsets.only(bottom: ZSpace.x3),
                  child: ZSkeleton(height: 150, radius: ZRadius.card),
                ),
            ],
          ),
          error: (error, stackTrace) => message(
            'somethingWentWrong'.tr(),
            action: TextButton(
              onPressed: () => ref.invalidate(ordersProvider),
              child: Text('retry'.tr()),
            ),
          ),
          data: (orders) {
            if (orders.isEmpty) return message('noOrdersYet'.tr());
            final shown = orders.where(_filter.matches).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: ZSpace.x3),
                SizedBox(
                  height: ZSize.touch,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: ZSpace.screen,
                    ),
                    children: [
                      for (final f in _OrdersFilter.values) ...[
                        if (f != _OrdersFilter.all)
                          const SizedBox(width: ZSpace.x2),
                        ZChip(
                          label: f.label,
                          selected: f == _filter,
                          onTap: () => setState(() => _filter = f),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => ref.refresh(ordersProvider.future),
                    child: shown.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: 240,
                                child: message('noOrdersInFilter'.tr()),
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(ZSpace.screen),
                            itemCount: shown.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: ZSpace.x3),
                            itemBuilder: (context, index) =>
                                YourOrderWidget(order: shown[index]),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
