import 'package:flutter/material.dart';
import 'package:zippy/core/common_widgets/add_button.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/common_widgets/quantity_stepper.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

/// docs/mockups/Main.dc.html's product card: image with an optional
/// % off badge, unit, name, price (+ struck-through MRP) and either an
/// ADD button or (once [cartQuantity] > 0, per Category.dc.html) a
/// QuantityStepper.
class ItemCard extends StatelessWidget {
  final String? productName;
  final String? quantity;
  final int? pricePaise;
  final int? mrpPaise;
  final String? imagePath;
  final VoidCallback? onClicked;
  final VoidCallback? onAddClicked;
  final int cartQuantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const ItemCard({
    super.key,
    required this.productName,
    this.quantity,
    this.pricePaise,
    this.mrpPaise,
    this.imagePath,
    this.onClicked,
    this.onAddClicked,
    this.cartQuantity = 0,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final showDiscount =
        mrpPaise != null && pricePaise != null && mrpPaise! > pricePaise!;
    final discountPercent = showDiscount
        ? (100 - (pricePaise! * 100 / mrpPaise!)).round()
        : null;

    return InkWell(
      onTap: onClicked,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: context.colors.line),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.base,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CatalogImage(
                          image: imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    if (discountPercent != null && discountPercent > 0)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.accent,
                            borderRadius: BorderRadius.circular(
                              AppRadius.badge,
                            ),
                          ),
                          child: Text(
                            '$discountPercent% OFF',
                            style: AppTypography.labelSmall.copyWith(
                              color: context.colors.ink,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                productName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                quantity ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.muted,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (pricePaise != null)
                    Expanded(
                      child: PriceTag(
                        pricePaise: pricePaise!,
                        mrpPaise: mrpPaise,
                      ),
                    ),
                  if (cartQuantity > 0 &&
                      onIncrement != null &&
                      onDecrement != null)
                    QuantityStepper(
                      quantity: cartQuantity,
                      onIncrement: onIncrement!,
                      onDecrement: onDecrement!,
                    )
                  else
                    AddButton(onTap: onAddClicked ?? onClicked),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
