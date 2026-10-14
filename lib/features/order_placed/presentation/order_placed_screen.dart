import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/order_placed/application/order_by_id_provider.dart';

class OrderPlacedScreen extends ConsumerWidget {
  final String orderId;

  const OrderPlacedScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderByIdProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 96, color: AppColors.green),
              const SizedBox(height: 24),
              Text('orderPlaced'.tr(), style: AppTypography.headlineSmall),
              const SizedBox(height: 12),
              Text(
                'orderPlacedDescription'.tr(),
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
              if (order != null) ...[
                const SizedBox(height: 16),
                PriceTag(
                  pricePaise: order.totalPaise,
                  priceStyle: AppTypography.titleLarge,
                ),
              ],
              const SizedBox(height: 32),
              PrimaryButton(
                buttonTitle: 'trackOrder'.tr(),
                action: () =>
                    context.go('/orderTrackingScreen?orderId=$orderId'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/navBar'),
                child: Text('backToHome'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
