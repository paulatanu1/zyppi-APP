import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/app_skeleton.dart';
import 'package:zippy/core/favourites/application/favourites_provider.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/features/product_details/application/product_detail_provider.dart';

class ProductSlider extends ConsumerWidget {
  final String productId;

  const ProductSlider({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    final productDetail = ref.watch(productDetailProvider(productId));
    final favourites = ref.watch(favouritesProvider);
    final isFavourite = favourites.contains(productId);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.grey2,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(height * 0.025),
          bottomRight: Radius.circular(height * 0.025),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: height * 0.01,
                    left: height * 0.03,
                  ),
                  child: Bounce(
                    duration: Duration(milliseconds: 300),
                    onPressed: () => context.pop(),
                    child: Icon(Icons.arrow_back_ios, size: 30, weight: 2),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: height * 0.01,
                    right: height * 0.03,
                  ),
                  child: Bounce(
                    duration: const Duration(milliseconds: 300),
                    onPressed: () =>
                        ref.read(favouritesProvider.notifier).toggle(productId),
                    child: Icon(
                      isFavourite ? Icons.favorite : Icons.favorite_border,
                      size: 26,
                      color: isFavourite ? AppColors.primary : AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            AppSkeleton(
              enabled: productDetail.loading,
              child: Image.asset(
                productDetail.product?.image ?? 'assets/images/item.png',
                height: height * 0.25,
                width: width * 0.6,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: height * 0.025),
          ],
        ),
      ),
    );
  }
}
