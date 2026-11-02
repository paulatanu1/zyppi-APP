import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/favourites/application/favourites_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

class FavouriteItem extends ConsumerWidget {
  final Product product;

  const FavouriteItem({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  CatalogImage(
                    image: product.image,
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
                            color: context.colors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (variant != null) PriceTag(pricePaise: variant.pricePaise),
                  IconButton(
                    tooltip: 'removeFromFavourites'.tr(),
                    onPressed: () => ref
                        .read(favouritesProvider.notifier)
                        .toggle(product.id),
                    icon: Icon(Icons.favorite, color: context.colors.danger),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.colors.divider),
          ],
        ),
      ),
    );
  }
}
