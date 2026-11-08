import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/domain/delivery_slot.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/core/common_widgets/section_card.dart';

/// docs/mockups/Checkout.dc.html's two-tile Express/Schedule toggle;
/// picking "Schedule" reveals the concrete scheduled windows below it.
class DeliveryTimeCard extends StatelessWidget {
  final List<DeliverySlot> slots;
  final DeliverySlot? selectedSlot;
  final ValueChanged<String> onSelect;

  const DeliveryTimeCard({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final expressSlot = slots.where((s) => s.isExpress).firstOrNull;
    final scheduledSlots = slots.where((s) => !s.isExpress).toList();
    final isScheduleSelected = selectedSlot != null && !selectedSlot!.isExpress;

    return SectionCard(
      title: 'deliveryTime'.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (expressSlot != null)
                  Expanded(
                    child: _SlotTile(
                      title: '⚡ ${'express'.tr()}',
                      subtitle: expressSlot.label,
                      selected: selectedSlot?.id == expressSlot.id,
                      onTap: () => onSelect(expressSlot.id),
                    ),
                  ),
                if (expressSlot != null && scheduledSlots.isNotEmpty)
                  const SizedBox(width: ZSpace.x3),
                if (scheduledSlots.isNotEmpty)
                  Expanded(
                    child: _SlotTile(
                      title: 'scheduleLabel'.tr(),
                      subtitle: isScheduleSelected
                          ? selectedSlot!.label
                          : scheduledSlots.first.label,
                      selected: isScheduleSelected,
                      onTap: () => onSelect(
                        isScheduleSelected
                            ? selectedSlot!.id
                            : scheduledSlots.first.id,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isScheduleSelected && scheduledSlots.length > 1) ...[
            const SizedBox(height: ZSpace.x3),
            Wrap(
              spacing: ZSpace.x2,
              runSpacing: ZSpace.x2,
              children: [
                for (final slot in scheduledSlots)
                  ChoiceChip(
                    label: Text(slot.label),
                    selected: selectedSlot?.id == slot.id,
                    onSelected: (_) => onSelect(slot.id),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SlotTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SelectableTile(
      selected: selected,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.labelLarge),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: text.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Same footprint as [DeliveryTimeCard]: title + two option tiles.
class DeliveryTimeCardSkeleton extends StatelessWidget {
  const DeliveryTimeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'deliveryTime'.tr(),
      child: const Row(
        children: [
          Expanded(child: ZSkeleton(height: 66, radius: ZRadius.tile)),
          SizedBox(width: ZSpace.x3),
          Expanded(child: ZSkeleton(height: 66, radius: ZRadius.tile)),
        ],
      ),
    );
  }
}
