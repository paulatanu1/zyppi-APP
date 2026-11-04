import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/your_order/application/orders_provider.dart';
import 'package:zippy/features/your_order/widgets/your_order_widget.dart';

/// docs/mockups/Orders.dc.html.
class YourOrderScreen extends ConsumerWidget {
  const YourOrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: context.z.surface2,
      appBar: AppBar(title: Text('yourOrder'.tr())),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ordersAsync.when(
                skipLoadingOnRefresh: true,
                loading: () => ListView(
                  padding: const EdgeInsets.all(ZSpace.x3),
                  children: [
                    for (var i = 0; i < 3; i++)
                      const Padding(
                        padding: EdgeInsets.only(bottom: ZSpace.x3),
                        child: ZSkeleton(height: 132, radius: ZRadius.card),
                      ),
                  ],
                ),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'somethingWentWrong'.tr(),
                        style: AppTypography.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => ref.invalidate(ordersProvider),
                        child: Text('retry'.tr()),
                      ),
                    ],
                  ),
                ),
                data: (orders) => orders.isEmpty
                    ? Center(
                        child: Text(
                          'noOrdersYet'.tr(),
                          style: AppTypography.bodyMedium,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.refresh(ordersProvider.future),
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            vertical: ZSpace.x3,
                          ),
                          itemCount: orders.length,
                          itemBuilder: (context, index) =>
                              YourOrderWidget(order: orders[index]),
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
