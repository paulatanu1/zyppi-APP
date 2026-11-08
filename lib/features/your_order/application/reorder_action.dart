import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/cart/application/reorder.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/utils/snack_bar.dart';

/// "Reorder" from the orders list or order details: fills the cart and
/// says what happened, with a shortcut to the cart.
Future<void> reorder(BuildContext context, WidgetRef ref, Order order) async {
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);

  try {
    final result = await reorderToCart(
      order: order,
      catalog: ref.read(catalogRepositoryProvider),
      cart: ref.read(cartProvider.notifier),
    );

    final message = result.added == 0
        ? 'reorderNothingAvailable'.tr()
        : result.skipped == 0
        ? 'reorderAdded'.plural(result.added)
        : 'reorderPartial'.tr(args: ['${result.added}', '${result.skipped}']);

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        action: result.added == 0
            ? null
            : SnackBarAction(
                label: 'viewCart'.tr(),
                onPressed: () => router.push('/myCartScreen'),
              ),
      ),
    );
  } catch (error) {
    showError(error);
  }
}
