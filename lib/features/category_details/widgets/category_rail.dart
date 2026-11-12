import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_commerce.dart';
import 'package:zippy/features/category_details/application/category_details_state.dart';

/// The product page's left menu (Blinkit/Zepto style). With
/// sub-categories: "All" (the whole parent) then each sub-category, with a
/// way back to every category on top. Without: "All" then every top-level
/// category. The selected item has a purple bar on its left edge and a
/// lilac ring.
class CategoryRail extends StatelessWidget {
  const CategoryRail({
    super.key,
    required this.state,
    required this.onSelectParent,
    required this.onSelectSub,
  });

  static const double width = 84;

  final CategoryDetailsState state;
  final ValueChanged<String?> onSelectParent;
  final ValueChanged<String?> onSelectSub;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final parent = state.category;
    final items = <Widget>[];

    if (state.menuShowsSubcategories && parent != null) {
      items
        ..add(
          _RailItem(
            label: 'allCategories'.tr(),
            icon: Icons.grid_view_rounded,
            selected: false,
            onTap: () => onSelectParent(null),
          ),
        )
        ..add(
          _RailItem(
            label: 'allItemsShort'.tr(),
            category: parent,
            selected: state.subId == null,
            onTap: () => onSelectSub(null),
          ),
        );
      for (final sub in state.subcategories) {
        items.add(
          _RailItem(
            label: sub.name,
            category: sub,
            fallbackImage: parent.image,
            selected: state.subId == sub.id,
            onTap: () => onSelectSub(sub.id),
          ),
        );
      }
    } else {
      items.add(
        _RailItem(
          label: 'allItemsShort'.tr(),
          icon: Icons.grid_view_rounded,
          selected: state.parentId == null,
          onTap: () => onSelectParent(null),
        ),
      );
      for (final c in state.categories.topLevel) {
        items.add(
          _RailItem(
            label: c.name,
            category: c,
            selected: state.parentId == c.id,
            onTap: () => onSelectParent(c.id),
          ),
        );
      }
    }

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: z.surface,
        border: Border(right: BorderSide(color: z.line)),
      ),
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: ListView(
          padding: const EdgeInsets.only(
            top: ZSpace.x2,
            // Clear of the floating cart bar.
            bottom: ZSize.cartBar + ZSpace.x6,
          ),
          children: items,
        ),
      ),
    );
  }
}

class _RailItem extends StatefulWidget {
  const _RailItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.category,
    this.fallbackImage,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Category? category;
  final String? fallbackImage;
  final IconData? icon;

  @override
  State<_RailItem> createState() => _RailItemState();
}

class _RailItemState extends State<_RailItem> {
  @override
  void didUpdateWidget(_RailItem old) {
    super.didUpdateWidget(old);
    // Keep a newly selected item in view (e.g. opened deep in the list).
    if (widget.selected && !old.selected) _reveal();
  }

  @override
  void initState() {
    super.initState();
    if (widget.selected) _reveal();
  }

  void _reveal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        alignment: .3,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : ZMotion.ui,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final selected = widget.selected;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : ZMotion.ui;
    final c = widget.category;
    final tint = c == null
        ? z.brandSoft
        : zTileTint(context, ZColors.fromHex(c.colorHex));
    final image = c?.image ?? widget.fallbackImage;

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: widget.onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ZSpace.x2,
                vertical: ZSpace.x2,
              ),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: duration,
                    curve: ZMotion.standard,
                    width: 56,
                    height: 56,
                    padding: const EdgeInsets.all(ZSpace.x1 + 2),
                    decoration: BoxDecoration(
                      color: selected ? z.brandSoft : tint,
                      borderRadius: ZRadius.all(ZRadius.tile),
                      border: Border.all(
                        color: selected ? z.brandSoft2 : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: AnimatedScale(
                      duration: duration,
                      scale: selected ? 1.08 : 1,
                      child: image == null
                          ? Icon(
                              widget.icon ?? Icons.category_rounded,
                              color: z.brandText,
                              size: 26,
                            )
                          : CatalogImage(image: image, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: ZSpace.x1 + 2),
                  Text(
                    widget.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: t.labelSmall!.copyWith(
                      letterSpacing: 0,
                      height: 1.2,
                      color: selected ? z.brandText : z.ink2,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Purple bar on the left edge of the selected item.
            Positioned(
              left: 0,
              top: ZSpace.x3,
              bottom: ZSpace.x3,
              child: AnimatedContainer(
                duration: duration,
                curve: ZMotion.standard,
                width: selected ? 4 : 0,
                decoration: BoxDecoration(
                  color: z.brand,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(4),
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
