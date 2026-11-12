import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/zyppi_theme.dart';
import 'z_motion.dart';

/// Formats paise as rupees: 14900 → ₹149, 14950 → ₹149.50.
String rupees(int paise) {
  final r = paise ~/ 100, p = paise % 100;
  final s = r.toString();
  // Indian grouping: 1,23,456
  final buf = StringBuffer();
  final head = s.length > 3 ? s.substring(0, s.length - 3) : '';
  final tail = s.length > 3 ? s.substring(s.length - 3) : s;
  for (var i = 0; i < head.length; i++) {
    if (i > 0 && (head.length - i) % 2 == 0) buf.write(',');
    buf.write(head[i]);
  }
  if (head.isNotEmpty) buf.write(',');
  buf.write(tail);
  return '₹$buf${p == 0 ? '' : '.${p.toString().padLeft(2, '0')}'}';
}

/// Blue "17% OFF" badge.
class ZOffBadge extends StatelessWidget {
  const ZOffBadge(this.percent, {super.key});
  final int percent;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: z.blue,
        borderRadius: ZRadius.all(ZRadius.badge),
      ),
      child: Text(
        'offPercent'.tr(args: ['$percent']),
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
          color: context.z.onBrand,
          fontSize: 10.5,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Grey "⚡ 12 MINS" chip. [label] defaults to the store-wide ETA
/// (`etaBadge`); no product or location carries its own ETA yet.
class ZEtaBadge extends StatelessWidget {
  const ZEtaBadge({super.key, this.label, this.background, this.foreground});
  final String? label;
  final Color? background, foreground;

  static const double iconSize = 12, verticalPadding = 3;

  static TextStyle textStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!
          .copyWith(fontSize: 10.5, letterSpacing: 0.4);

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final fg = foreground ?? z.ink2;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: background ?? z.surface2,
        borderRadius: ZRadius.all(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, size: iconSize, color: fg),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              label ?? 'etaBadge'.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle(context).copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// Price with optional struck MRP underneath.
class ZPrice extends StatelessWidget {
  const ZPrice({
    super.key,
    required this.price,
    this.mrp,
    this.horizontal = false,
  });
  final int price;
  final int? mrp;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final children = [
      Text(rupees(price), style: t.price),
      if (mrp != null && mrp! > price) Text(rupees(mrp!), style: t.mrp),
    ];
    return horizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              children.first,
              if (children.length > 1) ...[
                const SizedBox(width: 6),
                children.last,
              ],
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: children,
          );
  }
}

/// Outlined "ADD" button that morphs into a filled − n + stepper.
class ZAddStepper extends StatelessWidget {
  const ZAddStepper({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    this.height = ZSize.addButton,
    this.minWidth = 84,
  });

  final int quantity;
  final VoidCallback onAdd, onRemove;
  final double height, minWidth;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final label = Theme.of(context).textTheme.labelMedium!
        .copyWith(fontWeight: FontWeight.w800);
    return AnimatedSwitcher(
      duration: ZMotion.ui,
      switchInCurve: ZMotion.emphasized,
      transitionBuilder: (child, a) => ScaleTransition(
        scale: Tween(begin: .85, end: 1.0).animate(a),
        child: FadeTransition(opacity: a, child: child),
      ),
      child: quantity == 0
          ? ZPressable(
              key: const ValueKey('add'),
              onTap: onAdd,
              child: Container(
                height: height,
                // A full-width stepper (minWidth: infinity) has a
                // full-width ADD too.
                constraints: BoxConstraints(
                  minWidth: minWidth.isInfinite ? minWidth : 70,
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: z.surface,
                  borderRadius: ZRadius.all(ZRadius.control),
                  border: Border.all(color: z.brandText, width: 1.5),
                ),
                child: Text(
                  'add'.tr(),
                  style: label.copyWith(color: z.brandText, letterSpacing: 0.5),
                ),
              ),
            )
          : Container(
              key: const ValueKey('step'),
              height: height,
              constraints: BoxConstraints(minWidth: minWidth),
              decoration: BoxDecoration(
                color: z.brand,
                borderRadius: ZRadius.all(ZRadius.control),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StepBtn(
                    icon: Icons.remove_rounded,
                    onTap: onRemove,
                    semantic: 'removeOne'.tr(),
                    size: height,
                  ),
                  AnimatedSwitcher(
                    duration: ZMotion.ui,
                    transitionBuilder: (c, a) => SlideTransition(
                      position: Tween(
                        begin: const Offset(0, .5),
                        end: Offset.zero,
                      ).animate(a),
                      child: FadeTransition(opacity: a, child: c),
                    ),
                    child: Text(
                      '$quantity',
                      key: ValueKey(quantity),
                      style: label.copyWith(color: z.onBrand, fontSize: 14),
                    ),
                  ),
                  _StepBtn(
                    icon: Icons.add_rounded,
                    onTap: onAdd,
                    semantic: 'addOne'.tr(),
                    size: height,
                  ),
                ],
              ),
            ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({
    required this.icon,
    required this.onTap,
    required this.semantic,
    required this.size,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String semantic;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semantic,
    child: InkResponse(
      onTap: onTap,
      radius: size / 2,
      child: SizedBox(
        width: size - 4,
        height: size,
        child: Icon(icon, size: 18, color: context.z.onBrand),
      ),
    ),
  );
}

/// Category tints arrive from catalog data as light pastels; on a dark
/// surface they glare, so in dark mode they are muted into the surface.
Color zTileTint(BuildContext context, Color color) =>
    Theme.of(context).brightness == Brightness.dark
    ? Color.alphaBlend(color.withValues(alpha: .16), context.z.surface)
    : color;

/// Rounded tinted square holding a product photo (no circular crop).
/// [image] is a widget so catalog photos go through `CatalogImage`
/// (Firebase Storage URL or asset, with placeholder and fallback).
class ZImageTile extends StatelessWidget {
  const ZImageTile({
    super.key,
    required this.image,
    required this.color,
    this.width,
    this.height = ZSize.productTile,
    this.fill = .82,
  });
  final Widget image;
  final Color color;
  final double? width;
  final double height;
  final double fill;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: ZRadius.all(ZRadius.tile),
    ),
    alignment: Alignment.center,
    child: FractionallySizedBox(
      widthFactor: fill,
      heightFactor: fill,
      child: image,
    ),
  );
}
