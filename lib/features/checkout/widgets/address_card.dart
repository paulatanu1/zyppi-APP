import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/domain/address.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/address_label.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/core/common_widgets/section_card.dart';

IconData _labelIcon(String label) => switch (label) {
  'Home' => Icons.home_outlined,
  'Work' => Icons.work_outline_rounded,
  _ => Icons.place_outlined,
};

/// "Deliver to · Home" card with Change, plus its empty and loading forms.
class AddressCard extends StatelessWidget {
  final Address address;
  final List<Address> addresses;
  final ValueChanged<String> onSelect;
  final VoidCallback onAddNew;

  const AddressCard({
    super.key,
    required this.address,
    required this.addresses,
    required this.onSelect,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final text = Theme.of(context).textTheme;

    return SectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconTile(icon: _labelIcon(address.label)),
          const SizedBox(width: ZSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'deliverToLabel'
                      .tr(args: [addressLabelText(address.label)])
                      .toUpperCase(),
                  style: text.labelSmall,
                ),
                const SizedBox(height: ZSpace.x1),
                Text(
                  address.line1,
                  style: text.labelLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    address.area,
                    '${address.city} ${address.postalCode}'.trim(),
                  ].where((s) => s.isNotEmpty).join(' · '),
                  style: text.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: ZSpace.x2),
              minimumSize: const Size(ZSize.touch, ZSize.touch),
              foregroundColor: z.brandText,
            ),
            onPressed: () => _showAddressSheet(context),
            child: Text('change'.tr()),
          ),
        ],
      ),
    );
  }

  void _showAddressSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: ZRadius.sheetTop),
      builder: (sheetContext) {
        final z = sheetContext.z;
        final text = Theme.of(sheetContext).textTheme;

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
                Text('selectAddress'.tr(), style: text.titleMedium),
                const SizedBox(height: ZSpace.x3),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: addresses.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: ZSpace.x2),
                    itemBuilder: (_, index) {
                      final item = addresses[index];
                      final selected = item.id == address.id;

                      return SelectableTile(
                        selected: selected,
                        onTap: () {
                          onSelect(item.id);
                          Navigator.pop(sheetContext);
                        },
                        child: Row(
                          children: [
                            Icon(
                              _labelIcon(item.label),
                              color: selected ? z.brandText : z.ink2,
                            ),
                            const SizedBox(width: ZSpace.x3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    addressLabelText(item.label),
                                    style: text.labelLarge,
                                  ),
                                  Text(
                                    '${item.line1}, ${item.area}, ${item.city}',
                                    style: text.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (selected)
                              Icon(Icons.check_circle_rounded, color: z.brand),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: ZSpace.x3),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    onAddNew();
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: Text('addNewAddress'.tr()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Shown when the user has no saved address yet.
class AddressEmptyCard extends StatelessWidget {
  final VoidCallback onAddNew;

  const AddressEmptyCard({super.key, required this.onAddNew});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _IconTile(icon: Icons.add_location_alt_outlined),
              const SizedBox(width: ZSpace.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('addDeliveryAddress'.tr(), style: text.labelLarge),
                    const SizedBox(height: 2),
                    Text('addDeliveryAddressHint'.tr(), style: text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ZSpace.x4),
          OutlinedButton.icon(
            onPressed: onAddNew,
            icon: const Icon(Icons.add_rounded),
            label: Text('addNewAddress'.tr()),
          ),
        ],
      ),
    );
  }
}

/// Card-shaped placeholder with the same footprint as [AddressCard].
class AddressCardSkeleton extends StatelessWidget {
  const AddressCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ZSkeleton(width: 44, height: 44, radius: ZRadius.control),
          SizedBox(width: ZSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ZSkeleton(width: 120, height: 11, radius: ZRadius.badge),
                SizedBox(height: ZSpace.x2),
                ZSkeleton(height: 15, radius: ZRadius.badge),
                SizedBox(height: ZSpace.x2),
                ZSkeleton(width: 180, height: 12, radius: ZRadius.badge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  final IconData icon;

  const _IconTile({required this.icon});

  @override
  Widget build(BuildContext context) {
    final z = context.z;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: z.brandSoft,
        borderRadius: ZRadius.all(ZRadius.control),
      ),
      child: Icon(icon, color: z.brandText),
    );
  }
}
