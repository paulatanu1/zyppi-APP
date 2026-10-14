import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';

const _presetsPaise = [1000, 2000, 3000];

/// docs/mockups/Cart.dc.html's "Tip your delivery partner" chips.
class TipSelector extends StatelessWidget {
  final int tipPaise;
  final void Function(int tipPaise) onChanged;

  const TipSelector({
    super.key,
    required this.tipPaise,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isCustom = tipPaise > 0 && !_presetsPaise.contains(tipPaise);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('tip'.tr(), style: AppTypography.titleMedium),
          Text(
            'tipGoesFullyToPartner'.tr(),
            style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.base),
          Wrap(
            spacing: AppSpacing.md,
            children: [
              ..._presetsPaise.map(
                (preset) => ChoiceChip(
                  label: Text('₹${preset ~/ 100}'),
                  selected: tipPaise == preset,
                  onSelected: (_) => onChanged(tipPaise == preset ? 0 : preset),
                  selectedColor: AppColors.primary,
                  labelStyle: AppTypography.bodySmall.copyWith(
                    color: tipPaise == preset ? AppColors.white : AppColors.ink,
                  ),
                ),
              ),
              ChoiceChip(
                label: Text('custom'.tr()),
                selected: isCustom,
                onSelected: (_) => _showCustomTipDialog(context),
                selectedColor: AppColors.primary,
                labelStyle: AppTypography.bodySmall.copyWith(
                  color: isCustom ? AppColors.white : AppColors.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomTipDialog(BuildContext context) async {
    final controller = TextEditingController();

    final rupees = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('tip'.tr()),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: '₹'),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(int.tryParse(controller.text)),
            child: Text('submit'.tr()),
          ),
        ],
      ),
    );

    if (rupees != null && rupees > 0) onChanged(rupees * 100);
  }
}
