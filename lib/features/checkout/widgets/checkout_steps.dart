import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// Cart ✓ — Details (current) — Pay, under the checkout app bar.
class CheckoutSteps extends StatelessWidget {
  const CheckoutSteps({super.key});

  @override
  Widget build(BuildContext context) {
    final z = context.z;

    Widget rule() => Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: ZSpace.x2),
        color: z.line,
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(
        ZSpace.screen,
        ZSpace.x2,
        ZSpace.screen,
        ZSpace.x3,
      ),
      decoration: BoxDecoration(
        color: z.surface,
        border: Border(bottom: BorderSide(color: z.line)),
      ),
      child: Row(
        children: [
          _Step(label: 'stepCart'.tr(), state: _StepState.done),
          rule(),
          _Step(label: 'stepDetails'.tr(), number: 2),
          rule(),
          _Step(label: 'stepPay'.tr(), number: 3, state: _StepState.upcoming),
        ],
      ),
    );
  }
}

enum _StepState { done, current, upcoming }

class _Step extends StatelessWidget {
  final String label;
  final int? number;
  final _StepState state;

  const _Step({
    required this.label,
    this.number,
    this.state = _StepState.current,
  });

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final text = Theme.of(context).textTheme;
    final active = state != _StepState.upcoming;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? z.brand : z.surface3,
          ),
          child: state == _StepState.done
              ? Icon(Icons.check_rounded, size: 14, color: z.onBrand)
              : Text(
                  '$number',
                  style: text.labelSmall?.copyWith(
                    color: active ? z.onBrand : z.ink3,
                    letterSpacing: 0,
                  ),
                ),
        ),
        const SizedBox(width: ZSpace.x2),
        Text(
          label,
          style: text.labelMedium?.copyWith(color: active ? z.ink : z.ink3),
        ),
      ],
    );
  }
}
