import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/order/data/order_repository_impl.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/order_id.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/report_problem/data/claim_repository.dart';

/// The customer's recent orders that can still be reported (delivered in
/// the last 2 hours, nothing open), newest first.
final returnableOrdersProvider = FutureProvider.autoDispose<List<Order>>((
  ref,
) async {
  final orders = await ref.read(orderRepositoryProvider).getOrders(limit: 10);
  final now = DateTime.now();
  return [
    for (final o in orders)
      if (canReportProblem(o, now)) o,
  ];
});

/// Support chat → "Start a return" under the bot's answer: pick the order
/// (skipped when the chat is about one that can be reported), then the
/// Report a problem steps, linked to this chat.
class StartReturnButton extends ConsumerWidget {
  const StartReturnButton({super.key, required this.chatId, this.orderId});

  final String chatId;
  final String? orderId;

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    final orders = await ref.read(returnableOrdersProvider.future);
    if (!context.mounted) return;
    final chosen = orders.where((o) => o.id == orderId).firstOrNull;
    final picked =
        chosen ??
        (orders.length == 1
            ? orders.first
            : await showModalBottomSheet<Order>(
                context: context,
                showDragHandle: true,
                builder: (_) => _OrderPicker(orders: orders),
              ));
    if (picked == null || !context.mounted) return;
    await context.push(
      Uri(
        path: '/reportProblem',
        queryParameters: {'orderId': picked.id, 'chatId': chatId},
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: ZSpace.x2),
      child: FilledButton.icon(
        icon: const Icon(Icons.assignment_return_outlined),
        onPressed: () => _start(context, ref),
        label: Text('supportStartReturn'.tr()),
      ),
    );
  }
}

class _OrderPicker extends StatelessWidget {
  const _OrderPicker({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final z = context.z;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          ZSpace.screen,
          0,
          ZSpace.screen,
          ZSpace.screen,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('returnPickOrder'.tr(), style: t.titleMedium),
            const SizedBox(height: ZSpace.x3),
            if (orders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: ZSpace.x4),
                child: Text(
                  'returnNoEligibleOrders'.tr(),
                  textAlign: TextAlign.center,
                  style: t.bodyMedium?.copyWith(color: z.ink2),
                ),
              )
            else
              for (final (i, o) in orders.indexed)
                ZEntrance(
                  index: i,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.receipt_long_outlined,
                      color: z.brandText,
                    ),
                    title: Text('#${shortOrderId(o.id)}', style: t.labelLarge),
                    subtitle: Text(
                      '${'itemCount'.plural(o.items.fold<int>(0, (n, i) => n + i.quantity))} · ${PriceTag.format(o.totalPaise)}',
                      style: t.bodySmall,
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: z.ink3),
                    onTap: () => Navigator.pop(context, o),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
