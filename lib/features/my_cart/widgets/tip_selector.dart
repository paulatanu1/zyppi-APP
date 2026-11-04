import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_commerce.dart';
import 'package:zippy/core/widgets/z_motion.dart';

const _presetsPaise = [1000, 2000, 3000];

/// Tip boxes from docs/screens/light/09-cart.png — None · ₹10 · ₹20 · ₹30 —
/// plus Custom (dialog, capped at [CartNotifier.maxTipPaise]).
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

    final options = <(String, bool, VoidCallback)>[
      ('tipNone'.tr(), tipPaise == 0, () => onChanged(0)),
      for (final preset in _presetsPaise)
        (
          rupees(preset),
          tipPaise == preset,
          () => onChanged(tipPaise == preset ? 0 : preset),
        ),
      (
        isCustom ? rupees(tipPaise) : 'custom'.tr(),
        isCustom,
        () => _showCustomTipDialog(context),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'tipGoesFullyToPartner'.tr(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: ZSpace.x2),
        Row(
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: ZSpace.x2),
              Expanded(
                child: _TipBox(
                  label: options[i].$1,
                  selected: options[i].$2,
                  onTap: options[i].$3,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _showCustomTipDialog(BuildContext context) async {
    final controller = TextEditingController();

    final rupeesEntered = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('tip'.tr()),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: '₹',
            helperText: 'tipMax'.tr(args: [rupees(CartNotifier.maxTipPaise)]),
          ),
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

    if (rupeesEntered == null || rupeesEntered <= 0) return;
    // Capped to match the server (CartNotifier.maxTipPaise).
    onChanged((rupeesEntered * 100).clamp(0, CartNotifier.maxTipPaise));
  }
}

class _TipBox extends StatelessWidget {
  const _TipBox({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Semantics(
      selected: selected,
      child: ZPressable(
        onTap: onTap,
        child: Container(
          height: ZSize.touch,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: ZSpace.x1),
          decoration: BoxDecoration(
            color: selected ? z.brandSoft : z.surface,
            borderRadius: ZRadius.all(ZRadius.control),
            border: Border.all(
              color: selected ? z.brand : z.line,
              width: selected ? 1.5 : 1,
            ),
          ),
          // Five boxes share the row: shrink the label rather than wrap.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelLarge!
                  .copyWith(color: selected ? z.brandText : z.ink),
            ),
          ),
        ),
      ),
    );
  }
}
