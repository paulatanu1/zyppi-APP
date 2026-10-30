import 'package:flutter/material.dart';

import '../theme/zyppi_theme.dart';
import 'z_commerce.dart';
import 'z_motion.dart';

/// "Shop by category" / "Deals for you" header with an optional "See all".
class ZSectionHeader extends StatelessWidget {
  const ZSectionHeader(
    this.title, {
    super.key,
    this.onSeeAll,
    this.actionLabel = 'See all',
  });
  final String title, actionLabel;
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
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              actionLabel,
              style: t.labelMedium!.copyWith(
                color: context.z.brandText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

/// Category tile: 76×72 tinted rounded square with the full photo, label below (12/700, max 2 lines).
class ZCategoryTile extends StatelessWidget {
  const ZCategoryTile({
    super.key,
    required this.label,
    required this.image,
    required this.color,
    this.onTap,
  });
  final String label;
  final ImageProvider image;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ZPressable(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ZImageTile(
            image: image,
            color: color,
            width: 76,
            height: ZSize.categoryTile,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              color: context.z.ink,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// White search field used in the home header ("Search “paneer”" + mic).
class ZSearchBar extends StatelessWidget {
  const ZSearchBar({
    super.key,
    this.hint = 'Search “paneer”',
    this.onTap,
    this.onMic,
  });
  final String hint;
  final VoidCallback? onTap, onMic;

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
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: z.ink3, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hint,
                style: Theme.of(context).textTheme.bodyMedium!
                    .copyWith(color: z.ink3, fontSize: 14.5),
              ),
            ),
            Material(
              color: z.surface2,
              borderRadius: ZRadius.all(11),
              child: InkWell(
                borderRadius: ZRadius.all(11),
                onTap: onMic,
                child: SizedBox.square(
                  dimension: 38,
                  child: Icon(Icons.mic_none_rounded, size: 20, color: z.ink2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating magenta cart bar: stacked thumbnails · "3 items · ₹447 / You save ₹50" · View cart ›.
/// Slides up on first build. Place in a Stack, 12 px above the nav bar.
class ZCartBar extends StatelessWidget {
  const ZCartBar({
    super.key,
    required this.thumbnails,
    required this.itemCount,
    required this.total,
    this.saved = 0,
    required this.onTap,
  });
  final List<ImageProvider> thumbnails;
  final int itemCount, total, saved;
  final VoidCallback onTap;

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
          padding: const EdgeInsets.only(left: 10, right: 8),
          decoration: BoxDecoration(
            color: z.brand,
            borderRadius: ZRadius.all(ZRadius.card),
            boxShadow: [
              BoxShadow(
                color: z.brand.withValues(alpha: .35),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
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
                            color: Colors.white,
                            borderRadius: ZRadius.all(12),
                            border: Border.all(color: z.brand, width: 2),
                          ),
                          child: Image(image: thumbs[i], fit: BoxFit.contain),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$itemCount items · ${rupees(total)}',
                      style: t.labelLarge!.copyWith(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (saved > 0)
                      Text(
                        'You save ${rupees(saved)}',
                        style: t.bodySmall!.copyWith(
                          color: const Color(0xFFFFD6EB),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .18),
                  borderRadius: ZRadius.all(13),
                ),
                child: Row(
                  children: [
                    Text(
                      'View cart',
                      style: t.labelLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.explore_outlined, Icons.explore_rounded, 'Explore'),
    (Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Cart'),
    (Icons.favorite_border_rounded, Icons.favorite_rounded, 'Favourite'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: z.surface,
        border: Border(top: BorderSide(color: z.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedContainer(
                              duration: ZMotion.ui,
                              curve: ZMotion.standard,
                              width: 52,
                              height: 30,
                              decoration: BoxDecoration(
                                color: i == index
                                    ? z.brandSoft
                                    : Colors.transparent,
                                borderRadius: ZRadius.all(15),
                              ),
                              child: Icon(
                                i == index ? _items[i].$2 : _items[i].$1,
                                size: 22,
                                color: i == index ? z.brandText : z.ink3,
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
                                    '$cartCount',
                                    style: t.labelSmall!.copyWith(
                                      color: Colors.white,
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
                          _items[i].$3,
                          style: t.labelSmall!.copyWith(
                            fontSize: 11,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w700,
                            color: i == index ? z.ink : z.ink3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
