import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/features/ProductDetails/provider/productDetailProvider.dart';
import 'package:zippy/Utils/colors.dart';

class ProductSlider extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    final productDetail = ref.watch(productDetailProvider);
    final productDetailNotifier = ref.read(productDetailProvider.notifier);

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
            // Static Header
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
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 30,
                      weight: 2,
                    ),
                  ),
                ),
              ],
            ),
            // Sliding Images
            CarouselSlider(
              items: productDetail.product?.map((item) {
                return Image.asset(
                  item.image ?? 'assets/images/apple.png',
                  height: height * 0.25,
                  width: width * 0.6,
                  fit: BoxFit.contain,
                );
              }).toList(),
              options: CarouselOptions(
                height: height * 0.25,
                enlargeCenterPage: false,
                autoPlay: false,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) =>
                    productDetailNotifier.currentIndex(index),
              ),
            ),
            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: productDetail.product!.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => productDetailNotifier.currentIndex(entry.key),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: width * 0.01),
                    width: productDetail.currentIndex == entry.key
                        ? width * 0.06
                        : width * 0.01,
                    height: productDetail.currentIndex == entry.key
                        ? height * 0.005
                        : width * 0.01,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: productDetail.currentIndex == entry.key
                          ? AppColors.green
                          : AppColors.grey,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: height * 0.025),
          ],
        ),
      ),
    );
  }
}