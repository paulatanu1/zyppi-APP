import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';

class FavouriteItem extends StatelessWidget {
  final Product product;

  const FavouriteItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final variant = product.variants.isNotEmpty ? product.variants.first : null;

    return InkWell(
      onTap: () =>
          context.push('/productDetailsScreen?productId=${product.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Row(
                children: [
                  Image.asset(
                    product.image,
                    height: 56,
                    width: 56,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          variant?.label ?? '',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (variant != null) PriceTag(pricePaise: variant.pricePaise),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
          ],
        ),
      ),
    );
  }
}
