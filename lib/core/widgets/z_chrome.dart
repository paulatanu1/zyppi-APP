import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/zyppi_theme.dart';
import 'z_brand_texture.dart';
import 'z_commerce.dart';
import 'z_motion.dart';

/// "Shop by category" / "Deals for you" header with an optional "See all".
class ZSectionHeader extends StatelessWidget {
  const ZSectionHeader(
    this.title, {
    super.key,
    this.onSeeAll,
    this.actionLabel,
    this.pill = false,
  });
  final String title;

  /// Shows the action as a soft brand pill with a chevron (Home) instead
  /// of plain brand text.
  final bool pill;

  /// Defaults to `seeAll`.
  final String? actionLabel;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: Text(title, style: t.titleMedium)),
        if (onSeeAll != null)
          Semantics(
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSeeAll,
              child: pill ? _pill(context, t) : _label(context, t),
            ),
          ),
      ],
    );
  }
}

extension on ZSectionHeader {
  Text _label(BuildContext context, TextTheme t) => Text(
    actionLabel ?? 'seeAll'.tr(),
    style: t.labelMedium!.copyWith(
      color: context.z.brandText,
      fontWeight: FontWeight.w800,
    ),
  );

  /// A 44 px tall touch target around a 30 px pill.
  Widget _pill(BuildContext context, TextTheme t) {
    final z = context.z;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: ZSize.touch),
      child: Center(
        widthFactor: 1,
        child: Container(
          height: 30,
          padding: const EdgeInsets.only(left: ZSpace.x3, right: ZSpace.x1),
          decoration: BoxDecoration(
            color: z.brandSoft,
            borderRadius: ZRadius.all(15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _label(context, t),
              Icon(Icons.chevron_right_rounded, size: 18, color: z.brandText),
            ],
          ),
        ),
      ),
    );
  }
}

/// Category tile: 76×72 tinted rounded square with the full photo, label below (12/700, max 2 lines).
/// Narrower in tight grids (up to 6 columns); [height] gives the grid row
/// height at the current text scale.
class ZCategoryTile extends StatelessWidget {
  const ZCategoryTile({
    super.key,
    required this.label,
    required this.image,
    required this.color,
    this.onTap,
  });
  final String label;

  /// Usually `CatalogImage(image: url, fit: BoxFit.contain)`.
  final Widget image;

  /// Catalog tint; muted automatically in dark mode.
  final Color color;
  final VoidCallback? onTap;

  static const double _tileWidth = 76, _gap = 6;

  static TextStyle _labelStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: context.z.ink,
        height: 1.2,
      );

  /// Tile + gap + two label lines at the current text scale.
  static double height(BuildContext context) {
    final style = _labelStyle(context);
    final line = MediaQuery.textScalerOf(context)
        .scale(style.fontSize! * style.height!);
    return ZSize.categoryTile + _gap + 2 * line + 1;
  }

  @override
  Widget build(BuildContext context) {
    return ZPressable(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ZImageTile(
              image: image,
              color: zTileTint(context, color),
              width: constraints.maxWidth < _tileWidth
                  ? constraints.maxWidth
                  : _tileWidth,
              height: ZSize.categoryTile,
            ),
            const SizedBox(height: _gap),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _labelStyle(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// White search field used in the home header. The mic button only shows
/// when [onMic] is set (there is no voice search yet).
class ZSearchBar extends StatelessWidget {
  const ZSearchBar({
    super.key,
    this.hint,
    this.onTap,
    this.onMic,
    this.glow = false,
  });

  /// Defaults to `homeSearchHint`.
  final String? hint;
  final VoidCallback? onTap, onMic;

  /// A soft brand-tinted shadow, so the bar floats over a textured header.
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return ZPressable(
      onTap: onTap,
      scale: .99,
      child: Container(
        height: ZSize.search,
        padding: const EdgeInsets.only(left: 14, right: 6),
        decoration: BoxDecoration(
          color: z.surface,
          borderRadius: ZRadius.all(15),
          boxShadow: [
            if (glow)
              BoxShadow(
                color: ZBrandTones.deep.withValues(alpha: .35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              )
            else
              BoxShadow(
                color: z.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: z.ink3, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hint ?? 'homeSearchHint'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium!
                    .copyWith(color: z.ink3, fontSize: 14.5),
              ),
            ),
            if (onMic != null)
              Material(
                color: z.surface2,
                borderRadius: ZRadius.all(11),
                child: InkWell(
                  borderRadius: ZRadius.all(11),
                  onTap: onMic,
                  child: SizedBox.square(
                    dimension: 38,
                    child: Icon(
                      Icons.mic_none_rounded,
                      size: 20,
                      color: z.ink2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Floating purple cart bar: stacked thumbnails · "3 items · ₹447 / You save ₹50" · View cart ›.
/// Slides up on first build. Place in a Stack, 12 px above the nav bar.
/// [thumbnails] are widgets (e.g. `CatalogImage`) so network and asset
/// images both work; at most three are shown.
class ZCartBar extends StatelessWidget {
  const ZCartBar({
    super.key,
    required this.thumbnails,
    required this.itemCount,
    required this.total,
    this.saved = 0,
    required this.onTap,
    this.textured = true,
  });
  final List<Widget> thumbnails;
  final int itemCount, total, saved;
  final VoidCallback onTap;

  /// The splash texture (aurora + grain) on the bar, with a softer, wider
  /// glow. Off: the flat brand bar.
  final bool textured;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final thumbs = thumbnails.take(3).toList();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : ZMotion.sheet,
      curve: ZMotion.emphasized,
      builder: (context, v, child) =>
          Transform.translate(offset: Offset(0, 120 * v), child: child),
      child: ZPressable(
        onTap: onTap,
        child: Container(
          height: ZSize.cartBar,
          decoration: BoxDecoration(
            color: textured ? null : z.brand,
            borderRadius: ZRadius.all(ZRadius.card),
            boxShadow: [
              BoxShadow(
                color: (textured ? ZBrandTones.deep : z.brand).withValues(
                  alpha: textured ? .4 : .35,
                ),
                blurRadius: textured ? 32 : 28,
                offset: Offset(0, textured ? 12 : 10),
              ),
            ],
          ),
          child: _surface(
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 8),
              child: Row(
                children: [
                  if (thumbs.isNotEmpty) ...[
                    SizedBox(
                      width: 38 + (thumbs.length - 1) * 26,
                      height: 38,
                      child: Stack(
                        children: [
                          for (var i = 0; i < thumbs.length; i++)
                            Positioned(
                              left: i * 26,
                              child: Container(
                                width: 38,
                                height: 38,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  // Product shots are on white in both themes.
                                  color: z.onBrand,
                                  borderRadius: ZRadius.all(12),
                                  border: Border.all(color: z.brand, width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: ZRadius.all(8),
                                  child: thumbs[i],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'itemCount'.plural(itemCount)} · ${rupees(total)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.labelLarge!.copyWith(
                            color: z.onBrand,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (saved > 0)
                          Text(
                            'youSave'.tr(args: [rupees(saved)]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.bodySmall!.copyWith(
                              color: z.headerInk2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: z.onBrand.withValues(alpha: .18),
                      borderRadius: ZRadius.all(13),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'viewCart'.tr(),
                          style: t.labelLarge!.copyWith(
                            color: z.onBrand,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: z.onBrand,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            z,
          ),
        ),
      ),
    );
  }

  /// The bar's content on its brand surface: flat (the [Container]'s own
  /// colour) or textured.
  Widget _surface(Widget child, ZColors z) => textured
      ? ZBrandTexture(
          color: z.brand,
          borderRadius: ZRadius.all(ZRadius.card),
          child: child,
        )
      : child;
}

/// Bottom navigation: Home · Explore · Cart · Favourite · Account.
/// Active tab = brand-soft pill behind the icon; Cart shows a count badge.
class ZNavBar extends StatelessWidget {
  const ZNavBar({
    super.key,
    required this.index,
    required this.onTap,
    this.cartCount = 0,
  });
  final int index, cartCount;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'home'),
    (Icons.explore_outlined, Icons.explore_rounded, 'explore'),
    (Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'navCart'),
    (Icons.favorite_border_rounded, Icons.favorite_rounded, 'favourite'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'navAccount'),
  ];

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    // Floating rounded bar with a soft shadow, inset from the screen edges.
    return ColoredBox(
      color: z.bg,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(
          ZSpace.x3,
          ZSpace.x1,
          ZSpace.x3,
          ZSpace.x2,
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: z.surface,
            borderRadius: ZRadius.all(ZRadius.sheet),
            border: Border.all(color: z.line),
            boxShadow: [
              BoxShadow(
                color: z.shadow,
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          // The bar has a fixed height, so labels stop growing at 1.2×.
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.2,
            child: SizedBox(
              height: 66,
              child: Row(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Expanded(
                      child: Semantics(
                        selected: i == index,
                        button: true,
                        label: i == 2 && cartCount > 0
                            ? '${_items[i].$3.tr()}, $cartCount'
                            : null,
                        excludeSemantics: i == 2 && cartCount > 0,
                        child: InkWell(
                          onTap: () => onTap(i),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Selected tab: a textured purple pill.
                                  SizedBox(
                                    width: 52,
                                    height: 30,
                                    child: i == index
                                        ? ZBrandTexture(
                                            color: z.brand,
                                            borderRadius: ZRadius.all(15),
                                            child: Icon(
                                              _items[i].$2,
                                              size: 20,
                                              color: z.onBrand,
                                            ),
                                          )
                                        : Icon(
                                            _items[i].$1,
                                            size: 22,
                                            color: z.ink3,
                                          ),
                                  ),
                                  if (i == 2 && cartCount > 0)
                                    Positioned(
                                      right: 2,
                                      top: -4,
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 18,
                                        ),
                                        height: 18,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: z.brand,
                                          borderRadius: ZRadius.all(9),
                                          border: Border.all(
                                            color: z.surface,
                                            width: 2,
                                          ),
                                        ),
                                        child: Text(
                                          cartCount > 99 ? '99+' : '$cartCount',
                                          style: t.labelSmall!.copyWith(
                                            color: z.onBrand,
                                            fontSize: 10,
                                            letterSpacing: 0,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _items[i].$3.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: t.labelSmall!.copyWith(
                                  fontSize: 11,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w700,
                                  color: i == index ? z.brandText : z.ink3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill filter chip (06-category.png, 13-orders.png); selected = filled
/// with ink. Optional leading icon, trailing icon and count badge. The tap
/// area is the full 44 pt row height.
class ZChip extends StatelessWidget {
  const ZChip({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.trailing,
    this.selected = false,
    this.count = 0,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon, trailing;
  final bool selected;
  final int count;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final fg = selected ? z.onBrand : z.ink;
    final text = Theme.of(context).textTheme.labelMedium!
        .copyWith(color: fg, fontWeight: FontWeight.w700);

    return Semantics(
      selected: selected,
      child: ZPressable(
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : ZMotion.ui,
            curve: ZMotion.standard,
            padding: const EdgeInsets.symmetric(
              horizontal: ZSpace.x3,
              vertical: ZSpace.x2,
            ),
            decoration: BoxDecoration(
              color: selected ? z.brand : z.surface,
              borderRadius: ZRadius.all(ZRadius.chip),
              border: Border.all(color: selected ? z.brand : z.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: fg),
                  const SizedBox(width: ZSpace.x1),
                ],
                Text(label, style: text),
                if (count > 0) ...[
                  const SizedBox(width: ZSpace.x1),
                  Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: selected ? z.onBrand : z.brand,
                      borderRadius: ZRadius.all(ZRadius.chip),
                    ),
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: text.copyWith(
                        color: selected ? z.brand : z.onBrand,
                      ),
                    ),
                  ),
                ],
                if (trailing != null) Icon(trailing, size: 18, color: fg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fills the status-bar area with [color] (default: the purple header) and
/// asks for light status-bar icons — for screens whose top section is the
/// header colour (Home, Account). Place at the top of a `Stack`.
class ZStatusBarStrip extends StatelessWidget {
  const ZStatusBarStrip({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.paddingOf(context).top,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: ColoredBox(color: color ?? context.z.header),
      ),
    );
  }
}
