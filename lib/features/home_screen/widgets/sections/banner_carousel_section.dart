import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/utils/launch.dart';
import 'package:zippy/features/home_screen/widgets/sections/section_data.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// Blinkit-referenced swipeable promo banner strip — replaces the old
/// single static PromoBanner. `config.autoplay` toggles auto-advance.
class BannerCarouselSection extends StatefulWidget {
  final HomeSection section;

  const BannerCarouselSection({super.key, required this.section});

  @override
  State<BannerCarouselSection> createState() => _BannerCarouselSectionState();
}

class _BannerCarouselSectionState extends State<BannerCarouselSection> {
  final _controller = CarouselSliderController();
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final items = widget.section.items;
    if (items.isEmpty) return const SizedBox.shrink();

    // Auto-advancing content is motion; respect the OS setting.
    final autoplay =
        widget.section.config['autoplay'] == true &&
        !MediaQuery.disableAnimationsOf(context);

    return Column(
      children: [
        CarouselSlider(
          carouselController: _controller,
          options: CarouselOptions(
            height: 140,
            viewportFraction: 1,
            autoPlay: autoplay && items.length > 1,
            autoPlayInterval: const Duration(seconds: 5),
            onPageChanged: (index, reason) => setState(() => _page = index),
          ),
          items: items.map((item) {
            final title = item.data.string('title') ?? '';
            final ctaText = item.data.string('cta_text');
            final linkType = item.data.string('link_type');
            final linkTarget = item.data.string('link_target');
            final imageUrl = item.data.string('image_url');

            // The carousel hands each slide loose constraints; without an
            // explicit width the card shrinks to its content.
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: ZSpace.x4),
              child: InkWell(
                onTap: switch ((linkType, linkTarget)) {
                  ('category', final String id) => () => context.push(
                    '/categoryDetailsScreen?categoryId=$id',
                  ),
                  ('product', final String id) => () => context.push(
                    '/productDetailsScreen?productId=$id',
                  ),
                  ('url', final String url) => () => openExternal(
                    Uri.parse(url),
                  ),
                  _ => null,
                },
                borderRadius: BorderRadius.circular(ZRadius.banner),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: context.z.deal,
                    borderRadius: BorderRadius.circular(ZRadius.banner),
                  ),
                  // Image owns the right ~42%, text the rest, so they never
                  // overlap whatever the image's aspect ratio.
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final imageWidth = constraints.maxWidth * 0.42;

                      return Stack(
                        children: [
                          Positioned(
                            top: 0,
                            right: 0,
                            bottom: 0,
                            width: imageWidth,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                ZRadius.banner,
                              ),
                              child: CatalogImage(
                                image: imageUrl,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              ZSpace.x4,
                              ZSpace.x4,
                              imageWidth,
                              ZSpace.x4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  // Accent yellow in both themes, so use its
                                  // fixed dark ink rather than the theme ink.
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(color: context.z.dealInk),
                                ),
                                if (ctaText != null) ...[
                                  const SizedBox(height: ZSpace.x1),
                                  Text(
                                    ctaText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(
                                          color: context.z.dealInk,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (items.length > 1) ...[
          const SizedBox(height: ZSpace.x2),
          AnimatedSmoothIndicator(
            activeIndex: _page,
            count: items.length,
            effect: ExpandingDotsEffect(
              dotHeight: 6,
              dotWidth: 6,
              activeDotColor: context.z.brand,
              dotColor: context.z.line2,
            ),
          ),
        ],
      ],
    );
  }
}
