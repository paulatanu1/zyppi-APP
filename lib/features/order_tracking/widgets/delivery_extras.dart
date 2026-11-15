import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/launch.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/order_tracking/data/delivery_info_repository.dart';

/// Under the rider card on the tracking sheet: the 4-digit delivery code
/// to tell the rider, how far away they are (opens the phone's maps app),
/// and rating the rider once delivered.
class DeliveryExtras extends ConsumerWidget {
  const DeliveryExtras({
    super.key,
    required this.orderId,
    required this.status,
    required this.hasRider,
  });

  final String orderId;
  final OrderStatus status;
  final bool hasRider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open =
        status != OrderStatus.delivered && status != OrderStatus.cancelled;
    final code = open ? ref.watch(handoverCodeProvider(orderId)).value : null;
    final live = status == OrderStatus.outForDelivery
        ? ref.watch(riderLiveProvider(orderId)).value
        : null;
    final canRate = status == OrderStatus.delivered && hasRider;
    final rated = canRate ? ref.watch(riderRatedProvider(orderId)).value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (live != null) ...[
          const SizedBox(height: ZSpace.x3),
          _RiderDistance(live: live),
        ],
        if (code != null) ...[
          const SizedBox(height: ZSpace.x3),
          DeliveryCodeCard(code: code),
        ],
        if (rated == false) ...[
          const SizedBox(height: ZSpace.x3),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(ZSize.button),
            ),
            onPressed: () => showRateRiderSheet(context, ref, orderId),
            icon: const Icon(Icons.star_outline_rounded),
            label: Text('rateYourRider'.tr()),
          ),
        ],
      ],
    );
  }
}

class DeliveryCodeCard extends StatelessWidget {
  const DeliveryCodeCard({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return Semantics(
      label: 'deliveryCodeSemantics'.tr(args: [code.split('').join(' ')]),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(ZSpace.x4),
        decoration: BoxDecoration(
          color: z.brandSoft,
          borderRadius: ZRadius.all(ZRadius.card),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'deliveryCodeTitle'.tr(),
                    style: t.labelLarge!.copyWith(color: z.brandText),
                  ),
                  Text('deliveryCodeHint'.tr(), style: t.bodySmall),
                ],
              ),
            ),
            Text(
              code,
              style: t.headlineMedium!.copyWith(
                color: z.brandText,
                letterSpacing: ZSpace.x2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiderDistance extends StatelessWidget {
  const _RiderDistance({required this.live});

  final RiderLive live;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final km = (live.distanceM / 1000).toStringAsFixed(1);
    final stale = live.staleAt(DateTime.now());
    return Container(
      padding: const EdgeInsets.all(ZSpace.x4),
      decoration: BoxDecoration(
        border: Border.all(color: z.line),
        borderRadius: ZRadius.all(ZRadius.card),
      ),
      child: Row(
        children: [
          Icon(Icons.delivery_dining_rounded, color: z.blue),
          const SizedBox(width: ZSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  live.distanceM < 150
                      ? 'riderNearby'.tr()
                      : 'riderDistance'.tr(args: [km, '${live.etaMinutes}']),
                  style: t.titleSmall,
                ),
                if (stale) Text('riderSignalOld'.tr(), style: t.bodySmall),
              ],
            ),
          ),
          TextButton(
            onPressed: () => openExternal(
              Uri.https('www.google.com', '/maps/search/', {
                'api': '1',
                'query': '${live.lat},${live.lng}',
              }),
            ),
            child: Text('seeOnMap'.tr()),
          ),
        ],
      ),
    );
  }
}

const riderRatingTags = [
  'polite',
  'on_time',
  'careful',
  'late',
  'rude',
  'damaged',
];

Future<void> showRateRiderSheet(
  BuildContext context,
  WidgetRef ref,
  String orderId,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(borderRadius: ZRadius.sheetTop),
    builder: (_) => _RateSheet(orderId: orderId),
  );
}

class _RateSheet extends ConsumerStatefulWidget {
  const _RateSheet({required this.orderId});

  final String orderId;

  @override
  ConsumerState<_RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends ConsumerState<_RateSheet> {
  int _stars = 0;
  final _tags = <String>{};
  bool _busy = false;

  Future<void> _send() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(deliveryInfoRepositoryProvider)
          .rateRider(widget.orderId, _stars, _tags.toList());
      if (mounted) Navigator.pop(context);
      showSuccessToast(message: 'thanksForRating'.tr());
    } catch (e) {
      showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          ZSpace.screen,
          0,
          ZSpace.screen,
          ZSpace.x4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'rateYourRider'.tr(),
              style: t.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ZSpace.x3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    tooltip: 'starsLabel'.plural(i),
                    iconSize: ZSize.touch,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => _stars = i);
                    },
                    icon: Icon(
                      i <= _stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: i <= _stars ? z.deal : z.ink3,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: ZSpace.x3),
            Wrap(
              spacing: ZSpace.x2,
              runSpacing: ZSpace.x2,
              alignment: WrapAlignment.center,
              children: [
                for (final tag in riderRatingTags)
                  FilterChip(
                    label: Text('riderTag_$tag'.tr()),
                    selected: _tags.contains(tag),
                    onSelected: (v) =>
                        setState(() => v ? _tags.add(tag) : _tags.remove(tag)),
                  ),
              ],
            ),
            const SizedBox(height: ZSpace.x4),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(ZSize.button),
              ),
              onPressed: _stars == 0 || _busy ? null : _send,
              child: Text('sendRating'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
