import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/order/data/order_repository_impl.dart';
import 'package:zippy/core/order/domain/order_repository.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/snack_bar.dart';

/// "Cancel order" under the tracking sheet while the order is still
/// placed. Asks for a reason, then cancels through the server (which
/// re-checks that nothing was packed or picked up). The screen updates by
/// itself from the live order.
class CancelOrderButton extends ConsumerStatefulWidget {
  const CancelOrderButton({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<CancelOrderButton> createState() => _CancelOrderButtonState();
}

class _CancelOrderButtonState extends ConsumerState<CancelOrderButton> {
  bool _busy = false;

  Future<void> _start() async {
    final reason = await showModalBottomSheet<CancelReason>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: ZRadius.sheetTop),
      builder: (_) => const _CancelReasonSheet(),
    );
    if (reason == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(orderRepositoryProvider)
          .cancelOrder(widget.orderId, reason);
      showSuccessToast(message: 'orderCancelledToast'.tr());
    } on OrderCancelTooLate {
      showError('cancelTooLate'.tr());
    } catch (_) {
      showError('somethingWentWrong'.tr());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Padding(
      padding: const EdgeInsets.only(top: ZSpace.x3),
      child: Center(
        child: TextButton(
          onPressed: _busy ? null : _start,
          style: TextButton.styleFrom(
            foregroundColor: z.danger,
            minimumSize: const Size(0, ZSize.touch),
          ),
          child: _busy
              ? SizedBox.square(
                  dimension: ZSpace.x5,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: z.danger,
                  ),
                )
              : Text('cancelOrder'.tr()),
        ),
      ),
    );
  }
}

class _CancelReasonSheet extends StatefulWidget {
  const _CancelReasonSheet();

  @override
  State<_CancelReasonSheet> createState() => _CancelReasonSheetState();
}

class _CancelReasonSheetState extends State<_CancelReasonSheet> {
  CancelReason? _reason;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          ZSpace.screen,
          ZSpace.x5,
          ZSpace.screen,
          ZSpace.x4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('cancelOrderTitle'.tr(), style: t.titleMedium),
            const SizedBox(height: ZSpace.x1),
            Text('cancelOrderNote'.tr(), style: t.bodySmall),
            const SizedBox(height: ZSpace.x3),
            RadioGroup<CancelReason>(
              groupValue: _reason,
              onChanged: (r) => setState(() => _reason = r),
              child: Column(
                children: [
                  for (final r in CancelReason.values)
                    RadioListTile<CancelReason>(
                      value: r,
                      contentPadding: EdgeInsets.zero,
                      activeColor: z.brand,
                      title: Text(r.labelKey.tr(), style: t.bodyMedium),
                    ),
                ],
              ),
            ),
            const SizedBox(height: ZSpace.x3),
            FilledButton(
              onPressed: _reason == null
                  ? null
                  : () => Navigator.pop(context, _reason),
              style: FilledButton.styleFrom(
                backgroundColor: z.danger,
                foregroundColor: z.onBrand,
                minimumSize: const Size.fromHeight(ZSize.touch),
              ),
              child: Text('cancelOrderConfirm'.tr()),
            ),
            const SizedBox(height: ZSpace.x2),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(ZSize.touch),
              ),
              child: Text('keepOrder'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
