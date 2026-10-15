import 'package:flutter/material.dart';
import 'package:zippy/core/common_widgets/add_button.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/common_widgets/quantity_stepper.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';

/// docs/mockups/Search.dc.html's `.row`: a thumbnail, name + unit ·
/// price, and an ADD/stepper control.
class ProductListRow extends StatelessWidget {
  final String name;
  final String imagePath;
  final String unit;
  final int pricePaise;
  final VoidCallback onClicked;
  final VoidCallback? onAddClicked;
  final int cartQuantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const ProductListRow({
    super.key,
    required this.name,
    required this.imagePath,
    required this.unit,
    required this.pricePaise,
    required this.onClicked,
    this.onAddClicked,
    this.cartQuantity = 0,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClicked,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.chip),
                child: CatalogImage(image: imagePath),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '$unit · ${PriceTag.format(pricePaise)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (cartQuantity > 0 && onIncrement != null && onDecrement != null)
              QuantityStepper(
                quantity: cartQuantity,
                onIncrement: onIncrement!,
                onDecrement: onDecrement!,
              )
            else
              AddButton(onTap: onAddClicked),
          ],
        ),
      ),
    );
  }
}
