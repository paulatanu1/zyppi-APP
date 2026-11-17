import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/delivery_config.dart';
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

  // A light tick on every change: a firmer one for the first add.
  void _add() {
    quantity == 0
        ? HapticFeedback.lightImpact()
        : HapticFeedback.selectionClick();
    onAdd();
  }

  void _remove() {
    HapticFeedback.selectionClick();
    onRemove();
  }

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
              onTap: _add,
              child: Container(
                height: height,
                constraints: const BoxConstraints(minWidth: 70),
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
                    onTap: _remove,
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
                    onTap: _add,
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

/// Free-delivery / minimum-order progress (docs/mockups/Cart.dc.html's
/// truck + bar card): "Add ₹X more to place your order" until the
/// minimum is met, then "Add ₹X more for FREE delivery", then a
/// celebratory "free delivery" line once unlocked. Renders nothing when
/// [delivery] has neither a minimum nor a free-delivery goal.
///
/// [compact] is the slim pill shown above the floating cart bar; it hides
/// itself once there is nothing left to add.
class ZDeliveryProgress extends StatelessWidget {
  const ZDeliveryProgress({
    super.key,
    required this.itemTotalPaise,
    required this.delivery,
    this.compact = false,
  });

  final int itemTotalPaise;
  final DeliveryConfig delivery;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final toMinimum = delivery.remainingForMinimum(itemTotalPaise);
    final toFree = delivery.remainingForFree(itemTotalPaise);
    final unlocked = delivery.hasFreeDeliveryGoal && toFree == 0;

    if (toMinimum == 0 && !delivery.hasFreeDeliveryGoal) {
      return const SizedBox.shrink();
    }
    if (compact && toMinimum == 0 && unlocked) return const SizedBox.shrink();

    final String message;
    final double progress;
    final Color accent;
    final IconData icon;
    if (toMinimum > 0) {
      message = 'addMoreToOrder'.tr(args: [rupees(toMinimum)]);
      progress = itemTotalPaise / delivery.minOrderPaise;
      accent = z.warn;
      icon = Icons.shopping_basket_outlined;
    } else if (!unlocked) {
      message = 'addMoreForFreeDelivery'.tr(args: [rupees(toFree)]);
      progress = itemTotalPaise / delivery.freeAbovePaise;
      accent = z.brand;
      icon = Icons.local_shipping_outlined;
    } else {
      message = 'freeDeliveryUnlocked'.tr();
      progress = 1;
      accent = z.ok;
      icon = Icons.celebration_outlined;
    }

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final motion = reduceMotion ? Duration.zero : ZMotion.sheet;

    final bar = ClipRRect(
      borderRadius: ZRadius.all(ZRadius.badge),
      child: SizedBox(
        height: compact ? 4 : 6,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: progress.clamp(0, 1).toDouble()),
          duration: motion,
          curve: ZMotion.emphasized,
          builder: (context, value, _) => LinearProgressIndicator(
            value: value,
            minHeight: compact ? 4 : 6,
            backgroundColor: z.surface3,
            valueColor: AlwaysStoppedAnimation(accent),
          ),
        ),
      ),
    );

    final row = Row(
      children: [
        // Pops when the stage changes (minimum met, free delivery unlocked).
        AnimatedSwitcher(
          duration: motion,
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
            child: child,
          ),
          child: Icon(
            icon,
            key: ValueKey(icon),
            size: compact ? 16 : 18,
            color: accent,
          ),
        ),
        const SizedBox(width: ZSpace.x2),
        Expanded(
          child: Text(
            message,
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: (compact ? t.labelSmall : t.labelMedium)!.copyWith(
              color: z.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );

    return Semantics(
      liveRegion: true,
      label: message,
      excludeSemantics: true,
      child: Container(
        padding: compact
            ? const EdgeInsets.fromLTRB(
                ZSpace.x3,
                ZSpace.x2,
                ZSpace.x3,
                ZSpace.x2,
              )
            : const EdgeInsets.all(ZSpace.x4 - 2),
        decoration: BoxDecoration(
          color: z.surface,
          borderRadius: ZRadius.all(compact ? ZRadius.chip : ZRadius.card),
          border: Border.all(color: z.line),
          boxShadow: compact
              ? [
                  BoxShadow(
                    color: z.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            row,
            SizedBox(height: compact ? ZSpace.x1 + 2 : ZSpace.x2 + 2),
            bar,
          ],
        ),
      ),
    );
  }
}
