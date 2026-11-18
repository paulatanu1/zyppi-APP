import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/common_widgets/section_card.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/order/application/order_by_id_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/core/widgets/z_commerce.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/report_problem/data/claim_repository.dart';

/// Photos larger than this after compression are refused by the server.
const _maxPhotoBytes = 2 * 1024 * 1024;

/// Translated message for a reportOrderIssue error code.
String claimErrorMessage(Object error) {
  final code = error is FirebaseFunctionsException ? error.message ?? '' : '';
  return switch (code) {
    'CLAIM_WINDOW_OVER' => 'claimErrorWindow'.tr(),
    'CLAIM_OPEN' => 'claimErrorOpen'.tr(),
    'PHOTO_REQUIRED' => 'claimErrorPhoto'.tr(),
    'TOO_MANY_UNITS' => 'claimErrorUnits'.tr(),
    'INVALID_PHOTO' || 'TOO_MANY_PHOTOS' => 'claimErrorPhotoBad'.tr(),
    _ => 'somethingWentWrong'.tr(),
  };
}

String claimKindLabel(ClaimKind k) => switch (k) {
  ClaimKind.missing => 'claimKindMissing'.tr(),
  ClaimKind.wrong => 'claimKindWrong'.tr(),
  ClaimKind.damaged => 'claimKindDamaged'.tr(),
  ClaimKind.expired => 'claimKindExpired'.tr(),
};

/// Order details → Report a problem (2 hours after delivery): which items,
/// what's wrong, photos, and wallet credit / refund / replacement.
class ReportProblemScreen extends ConsumerWidget {
  const ReportProblemScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final order = ref.watch(orderByIdProvider(orderId));
    return Scaffold(
      backgroundColor: z.bg,
      appBar: AppBar(title: Text('reportProblem'.tr())),
      body: order.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(ZSpace.screen),
          children: const [
            ZSkeleton(height: 160, radius: ZRadius.card),
            SizedBox(height: ZSpace.x3),
            ZSkeleton(height: 120, radius: ZRadius.card),
          ],
        ),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('somethingWentWrong'.tr()),
              TextButton(
                onPressed: () => ref.invalidate(orderByIdProvider(orderId)),
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ),
        data: (o) => o == null
            ? Center(child: Text('orderNotFound'.tr()))
            : !canReportProblem(o, DateTime.now())
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(ZSpace.screen),
                  child: Text(
                    'claimErrorWindow'.tr(),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : _ReportForm(order: o),
      ),
    );
  }
}

class _ReportForm extends ConsumerStatefulWidget {
  const _ReportForm({required this.order});

  final Order order;

  @override
  ConsumerState<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends ConsumerState<_ReportForm> {
  final _qty = <int, int>{};
  final _kind = <int, ClaimKind>{};
  final _photos = <Uint8List>[];
  final _note = TextEditingController();
  ClaimResolution _resolution = ClaimResolution.wallet;
  bool _sending = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  List<ClaimLineInput> get _lines => [
    for (final e in _qty.entries)
      if (e.value > 0)
        ClaimLineInput(
          index: e.key,
          quantity: e.value,
          kind: _kind[e.key] ?? ClaimKind.damaged,
        ),
  ];

  bool get _needsPhoto => _lines.any((l) => l.kind != ClaimKind.missing);

  Future<void> _addPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text('claimTakePhoto'.tr()),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text('claimChoosePhoto'.tr()),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 70,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.length > _maxPhotoBytes) {
        showError('claimErrorPhotoBad'.tr());
        return;
      }
      if (mounted) setState(() => _photos.add(bytes));
    } catch (_) {
      showError('claimErrorPhotoBad'.tr());
    }
  }

  Future<void> _submit() async {
    if (_lines.isEmpty) {
      showError('claimPickItem'.tr());
      return;
    }
    if (_needsPhoto && _photos.isEmpty) {
      showError('claimErrorPhoto'.tr());
      return;
    }
    setState(() => _sending = true);
    try {
      await ref
          .read(claimRepositoryProvider)
          .report(
            orderId: widget.order.id,
            lines: _lines,
            photos: _photos,
            note: _note.text.trim(),
            resolution: _resolution,
          );
      ref.invalidate(orderByIdProvider(widget.order.id));
      showSuccessToast(message: 'claimSent'.tr());
      if (mounted) context.pop();
    } catch (error) {
      showError(claimErrorMessage(error));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final text = Theme.of(context).textTheme;
    final order = widget.order;
    final resolutions = [
      ClaimResolution.wallet,
      if (canRefundToOriginal(order)) ClaimResolution.original,
      ClaimResolution.replacement,
    ];

    return ListView(
      padding: const EdgeInsets.all(ZSpace.screen),
      children: [
        Text('claimIntro'.tr(), style: text.bodyMedium),
        const SizedBox(height: ZSpace.x3),
        SectionCard(
          title: 'claimWhichItems'.tr(),
          child: Column(
            children: [
              for (final (i, item) in order.items.indexed)
                if (unitsLeftToClaim(order, i) > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: ZSpace.x2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: ZSize.touch,
                              height: ZSize.touch,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: z.surface2,
                                borderRadius: ZRadius.all(ZRadius.control),
                              ),
                              child: item.image == null
                                  ? Icon(
                                      Icons.shopping_basket_outlined,
                                      color: z.ink3,
                                    )
                                  : CatalogImage(
                                      image: item.image,
                                      fit: BoxFit.contain,
                                    ),
                            ),
                            const SizedBox(width: ZSpace.x3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: text.labelLarge),
                                  Text(
                                    '${item.unit} × ${item.quantity}',
                                    style: text.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            ZAddStepper(
                              quantity: _qty[i] ?? 0,
                              onAdd: () {
                                final now = _qty[i] ?? 0;
                                if (now < unitsLeftToClaim(order, i)) {
                                  setState(() => _qty[i] = now + 1);
                                }
                              },
                              onRemove: () => setState(
                                () =>
                                    _qty[i] = ((_qty[i] ?? 0) - 1).clamp(0, 99),
                              ),
                            ),
                          ],
                        ),
                        if ((_qty[i] ?? 0) > 0) ...[
                          const SizedBox(height: ZSpace.x2),
                          Wrap(
                            spacing: ZSpace.x2,
                            runSpacing: ZSpace.x2,
                            children: [
                              for (final k in ClaimKind.values)
                                ZChip(
                                  label: claimKindLabel(k),
                                  selected:
                                      (_kind[i] ?? ClaimKind.damaged) == k,
                                  onTap: () => setState(() => _kind[i] = k),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: ZSpace.x3),
        SectionCard(
          title: 'claimPhotos'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _needsPhoto
                    ? 'claimPhotosRequired'.tr()
                    : 'claimPhotosOptional'.tr(),
                style: text.bodySmall,
              ),
              const SizedBox(height: ZSpace.x3),
              Wrap(
                spacing: ZSpace.x2,
                runSpacing: ZSpace.x2,
                children: [
                  for (final (i, p) in _photos.indexed)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: ZRadius.all(ZRadius.control),
                          child: Image.memory(
                            p,
                            width: 76,
                            height: 76,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: 'remove'.tr(),
                            icon: Icon(Icons.cancel_rounded, color: z.onBrand),
                            onPressed: () =>
                                setState(() => _photos.removeAt(i)),
                          ),
                        ),
                      ],
                    ),
                  if (_photos.length < maxClaimPhotos)
                    ZPressable(
                      onTap: _addPhoto,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: z.surface2,
                          borderRadius: ZRadius.all(ZRadius.control),
                          border: Border.all(color: z.line2),
                        ),
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          color: z.ink2,
                          semanticLabel: 'claimAddPhoto'.tr(),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: ZSpace.x3),
        SectionCard(
          title: 'claimNote'.tr(),
          child: TextField(
            controller: _note,
            maxLength: 500,
            maxLines: 3,
            decoration: InputDecoration(hintText: 'claimNoteHint'.tr()),
          ),
        ),
        const SizedBox(height: ZSpace.x3),
        SectionCard(
          title: 'claimWhatBack'.tr(),
          child: RadioGroup<ClaimResolution>(
            groupValue: _resolution,
            onChanged: (v) => setState(() => _resolution = v ?? _resolution),
            child: Column(
              children: [
                for (final r in resolutions)
                  RadioListTile<ClaimResolution>(
                    contentPadding: EdgeInsets.zero,
                    value: r,
                    title: Text(switch (r) {
                      ClaimResolution.wallet => 'claimBackWallet'.tr(),
                      ClaimResolution.original => 'claimBackOriginal'.tr(),
                      ClaimResolution.replacement =>
                        'claimBackReplacement'.tr(),
                    }, style: text.labelLarge),
                    subtitle: Text(switch (r) {
                      ClaimResolution.wallet => 'claimBackWalletSub'.tr(),
                      ClaimResolution.original => 'claimBackOriginalSub'.tr(),
                      ClaimResolution.replacement =>
                        'claimBackReplacementSub'.tr(),
                    }, style: text.bodySmall),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: ZSpace.x4),
        FilledButton(
          onPressed: _sending ? null : _submit,
          child: _sending
              ? SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: z.onBrand,
                  ),
                )
              : Text('claimSubmit'.tr()),
        ),
        const SizedBox(height: ZSpace.x2),
        Text(
          'claimReviewNote'.tr(),
          textAlign: TextAlign.center,
          style: text.bodySmall,
        ),
      ],
    );
  }
}
