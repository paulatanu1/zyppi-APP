import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/address_repository_impl.dart';
import 'package:zippy/core/data/provider/addresses_provider.dart';
import 'package:zippy/core/domain/address.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/address_label.dart';
import 'package:zippy/core/utils/snack_bar.dart';

enum _Action { setDefault, edit, delete }

/// My Address row menu: set as default, edit, delete.
class AddressActions extends ConsumerWidget {
  final Address address;

  const AddressActions({super.key, required this.address});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_Action>(
      tooltip: 'addressActions'.tr(),
      onSelected: (action) => switch (action) {
        _Action.setDefault => _run(
          ref,
          () => ref.read(addressRepositoryProvider).setDefault(address.id),
        ),
        _Action.edit => _edit(context, ref),
        _Action.delete => _delete(context, ref),
      },
      itemBuilder: (_) => [
        if (!address.isDefault)
          PopupMenuItem(
            value: _Action.setDefault,
            child: Text('setAsDefault'.tr()),
          ),
        PopupMenuItem(value: _Action.edit, child: Text('edit'.tr())),
        PopupMenuItem(
          value: _Action.delete,
          child: Text('delete'.tr(), style: TextStyle(color: context.z.danger)),
        ),
      ],
    );
  }

  Future<void> _run(WidgetRef ref, Future<void> Function() action) async {
    try {
      await action();
      ref.invalidate(addressesProvider);
    } catch (error) {
      showError(error);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('deleteAddressTitle'.tr()),
        content: Text(
          'deleteAddressBody'.tr(args: [addressLabelText(address.label)]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: context.z.danger),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _run(
      ref,
      () => ref.read(addressRepositoryProvider).deleteAddress(address.id),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final updated = await showModalBottomSheet<Address>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: ZRadius.sheetTop),
      builder: (_) => _EditAddressSheet(address: address),
    );
    if (updated == null) return;

    await _run(
      ref,
      () => ref.read(addressRepositoryProvider).updateAddress(updated),
    );
  }
}

/// Label, address line and landmark. The location itself (and so its
/// service area) can't change here — add a new address for that.
class _EditAddressSheet extends StatefulWidget {
  final Address address;

  const _EditAddressSheet({required this.address});

  @override
  State<_EditAddressSheet> createState() => _EditAddressSheetState();
}

class _EditAddressSheetState extends State<_EditAddressSheet> {
  late final _line1 = TextEditingController(text: widget.address.line1);
  late final _landmark = TextEditingController(
    text: widget.address.landmark ?? '',
  );
  late String _label = addressLabels.contains(widget.address.label)
      ? widget.address.label
      : addressLabels.last;
  String? _line1Error;

  @override
  void dispose() {
    _line1.dispose();
    _landmark.dispose();
    super.dispose();
  }

  void _save() {
    final line1 = _line1.text.trim();
    if (line1.isEmpty) {
      setState(() => _line1Error = 'enterAddressLine'.tr());
      return;
    }
    final landmark = _landmark.text.trim();
    Navigator.pop(
      context,
      widget.address.copyWith(
        label: _label,
        line1: line1,
        landmark: landmark.isEmpty ? null : landmark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        ZSpace.screen,
        ZSpace.x5,
        ZSpace.screen,
        ZSpace.x4 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('editAddress'.tr(), style: text.titleMedium),
            const SizedBox(height: ZSpace.x4),
            Wrap(
              spacing: ZSpace.x2,
              children: [
                for (final value in addressLabels)
                  ChoiceChip(
                    label: Text(addressLabelText(value)),
                    selected: _label == value,
                    onSelected: (_) => setState(() => _label = value),
                  ),
              ],
            ),
            const SizedBox(height: ZSpace.x3),
            TextField(
              controller: _line1,
              decoration: InputDecoration(
                labelText: 'addressLine'.tr(),
                errorText: _line1Error,
              ),
              onChanged: (_) {
                if (_line1Error != null) setState(() => _line1Error = null);
              },
            ),
            const SizedBox(height: ZSpace.x3),
            TextField(
              controller: _landmark,
              decoration: InputDecoration(labelText: 'landmarkOptional'.tr()),
            ),
            const SizedBox(height: ZSpace.x4),
            FilledButton(onPressed: _save, child: Text('save'.tr())),
          ],
        ),
      ),
    );
  }
}
