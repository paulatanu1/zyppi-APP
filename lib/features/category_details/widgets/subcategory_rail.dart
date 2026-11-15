import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_commerce.dart';
import 'package:zippy/core/widgets/z_motion.dart';

/// Blinkit/Zepto-style left rail of sub-categories
/// (docs/mockups/Category.dc.html `.rail`): "All" first, then each
/// sub-category as a 52px image tile with a label. The selected item gets a
/// brand-soft tile, bold ink label and a brand bar on its right edge.
class SubcategoryRail extends StatelessWidget {
  const SubcategoryRail({
    super.key,
    required this.parent,
    required this.subcategories,
    required this.selectedId,
    required this.onSelect,
  });

  /// Rail width (mockup: 82px).
  static const double width = 82;
  static const double _tile = 52;

  final Category parent;
  final List<Category> subcategories;

  /// null = "All".
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: z.surface,
        border: Border(right: BorderSide(color: z.line)),
      ),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        // Room at the end for the floating cart bar.
        padding: const EdgeInsets.only(bottom: ZSize.cartBar + ZSpace.x6),
        itemCount: subcategories.length + 1,
        itemBuilder: (context, index) {
          final sub = index == 0 ? null : subcategories[index - 1];
          return _RailItem(
            label: sub?.name ?? 'subcategoryAll'.tr(),
            // "All" shows the parent category's own picture.
            image: (sub ?? parent).image,
            selected: sub?.id == selectedId,
            onTap: () => onSelect(sub?.id),
          );
        },
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.label,
    required this.image,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? image;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final motion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : ZMotion.ui;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: ZPressable(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ZSpace.x1,
                vertical: ZSpace.x2 + 2,
              ),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: motion,
                    curve: ZMotion.emphasized,
                    width: SubcategoryRail._tile,
                    height: SubcategoryRail._tile,
                    decoration: BoxDecoration(
                      color: selected ? z.brandSoft : z.surface2,
                      borderRadius: ZRadius.all(ZRadius.tile),
                    ),
                    child: AnimatedScale(
                      duration: motion,
                      curve: ZMotion.emphasized,
                      scale: selected ? 1.08 : 1,
                      child: ZImageTile(
                        color: Colors.transparent,
                        height: SubcategoryRail._tile,
                        image: CatalogImage(image: image, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  const SizedBox(height: ZSpace.x1 + 1),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: t.labelSmall!.copyWith(
                      color: selected ? z.ink : z.ink2,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            // Brand bar on the right edge (mockup `.rail a.on::before`).
            Positioned(
              right: 0,
              top: ZSpace.x4 + 2,
              bottom: ZSpace.x4 + 2,
              child: AnimatedContainer(
                duration: motion,
                curve: ZMotion.emphasized,
                width: selected ? 4 : 0,
                decoration: BoxDecoration(
                  color: z.brand,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(4),
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
