import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/your_order/application/orders_provider.dart';
import 'package:zippy/features/your_order/widgets/your_order_widget.dart';

/// docs/mockups/Orders.dc.html.
class YourOrderScreen extends ConsumerWidget {
  const YourOrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xxxl,
                AppSpacing.xxl,
                AppSpacing.xl,
              ),
              child: Text('yourOrder'.tr(), style: AppTypography.headlineSmall),
            ),
            Expanded(
              child: ordersAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (error, stackTrace) => Center(
                  child: Text(
                    'somethingWentWrong'.tr(),
                    style: AppTypography.bodyMedium,
                  ),
                ),
                data: (orders) => orders.isEmpty
                    ? Center(
                        child: Text(
                          'noOrdersYet'.tr(),
                          style: AppTypography.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.base,
                        ),
                        itemCount: orders.length,
                        itemBuilder: (context, index) =>
                            YourOrderWidget(order: orders[index]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
