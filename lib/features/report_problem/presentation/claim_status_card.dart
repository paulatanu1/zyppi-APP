import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/launch.dart';
import 'package:zippy/core/widgets/z_commerce.dart';
import 'package:zippy/features/report_problem/data/claim_repository.dart';

/// Order details: the latest claim's status, and "Report a problem" while
/// the 2-hour window is open. Nothing for orders that can't be claimed.
class ClaimStatusCard extends ConsumerWidget {
  const ClaimStatusCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final text = Theme.of(context).textTheme;
    final issues = ref.watch(orderIssuesProvider(order.id)).value ?? const [];
    final latest = issues.firstOrNull;
    final canReport = canReportProblem(order, DateTime.now());
    if (latest == null && !canReport) return const SizedBox.shrink();

    final (title, body, color, soft) = switch (latest) {
      null => ('', '', z.ink, z.surface2),
      final i when i.isReturning => (
        'returnInProgress'.tr(),
        'returnInProgressBody'.tr(),
        z.blue,
        z.blueSoft,
      ),
      final i when i.isOpen => (
        'claimUnderReview'.tr(),
        'claimUnderReviewBody'.tr(args: [rupees(i.amountPaise)]),
        z.warn,
        z.warnSoft,
      ),
      final i when i.status == 'rejected' => (
        'claimRejected'.tr(),
        i.rejectReason ?? '',
        z.danger,
        z.dangerSoft,
      ),
      final i => (
        'claimApproved'.tr(),
        [
          if (i.replacementOrderId != null) 'claimApprovedReplacement'.tr(),
          if (i.walletPaise > 0)
            'claimApprovedWallet'.tr(args: [rupees(i.walletPaise)]),
          if (i.refundPaise > 0)
            'claimApprovedRefund'.tr(args: [rupees(i.refundPaise)]),
        ].join(' '),
        z.ok,
        z.okSoft,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (latest != null)
          Container(
            padding: const EdgeInsets.all(ZSpace.x4),
            decoration: BoxDecoration(
              color: soft,
              borderRadius: ZRadius.all(ZRadius.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.report_gmailerrorred_rounded, color: color),
                    const SizedBox(width: ZSpace.x2),
                    Expanded(
                      child: Text(
                        title,
                        style: text.labelLarge?.copyWith(color: color),
                      ),
                    ),
                  ],
                ),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: ZSpace.x2),
                  Text(body, style: text.bodyMedium),
                ],
                if (latest.isReturning)
                  for (final r
                      in ref.watch(orderReturnsProvider(order.id)).value ??
                          const <CustomerReturn>[])
                    _ReturnProgress(ret: r),
                if (latest.replacementOrderId case final id?) ...[
                  const SizedBox(height: ZSpace.x2),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () =>
                          context.push('/orderTrackingScreen?orderId=$id'),
                      child: Text('claimTrackReplacement'.tr()),
                    ),
                  ),
                ],
              ],
            ),
          ),
        if (canReport) ...[
          if (latest != null) const SizedBox(height: ZSpace.x3),
          OutlinedButton.icon(
            icon: const Icon(Icons.report_problem_outlined),
            onPressed: () => context.push('/reportProblem?orderId=${order.id}'),
            label: Text('reportProblem'.tr()),
          ),
          const SizedBox(height: ZSpace.x1),
          Text(
            'claimWindowHint'.tr(),
            textAlign: TextAlign.center,
            style: text.bodySmall,
          ),
        ],
      ],
    );
  }
}

String returnStepLabel(ReturnStep step) => switch (step) {
  ReturnStep.searching => 'returnStepSearching'.tr(),
  ReturnStep.assigned => 'returnStepAssigned'.tr(),
  ReturnStep.atDoor => 'returnStepAtDoor'.tr(),
  ReturnStep.collected => 'returnStepCollected'.tr(),
  ReturnStep.atStore => 'returnStepAtStore'.tr(),
  ReturnStep.received => 'returnStepReceived'.tr(),
  ReturnStep.review => 'returnStepReview'.tr(),
  ReturnStep.failed => 'returnStepFailed'.tr(),
  ReturnStep.cancelled => 'returnStepCancelled'.tr(),
};

/// One pickup: where it is, the rider, and the door code until collected.
class _ReturnProgress extends ConsumerWidget {
  const _ReturnProgress({required this.ret});

  final CustomerReturn ret;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final text = Theme.of(context).textTheme;
    final code = ret.awaitingPickup
        ? ref.watch(returnPickupCodeProvider(ret.id)).value
        : null;
    return Container(
      margin: const EdgeInsets.only(top: ZSpace.x3),
      padding: const EdgeInsets.all(ZSpace.x3),
      decoration: BoxDecoration(
        color: z.surface,
        borderRadius: ZRadius.all(ZRadius.control),
        border: Border.all(color: z.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${'itemCount'.plural(ret.itemCount)} · ${ret.storeName}',
            style: text.labelLarge,
          ),
          const SizedBox(height: ZSpace.x1),
          Text(returnStepLabel(ret.step), style: text.bodyMedium),
          if (code != null) ...[
            const SizedBox(height: ZSpace.x2),
            Row(
              children: [
                Expanded(
                  child: Text('returnPickupCode'.tr(), style: text.bodySmall),
                ),
                Semantics(
                  label: 'returnPickupCode'.tr(),
                  child: Text(
                    code.split('').join(' '),
                    style: text.headlineSmall?.copyWith(color: z.brandText),
                  ),
                ),
              ],
            ),
          ],
          if (ret.riderPhone case final phone?
              when ret.step == ReturnStep.assigned ||
                  ret.step == ReturnStep.atDoor)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.call_outlined),
                onPressed: () => openExternal(phoneUri(phone)),
                label: Text('returnCallRider'.tr(args: [ret.riderName ?? ''])),
              ),
            ),
        ],
      ),
    );
  }
}
