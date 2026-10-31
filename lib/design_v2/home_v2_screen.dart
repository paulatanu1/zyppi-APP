import 'package:flutter/material.dart';

import '../core/theme/zyppi_theme.dart';
import '../core/widgets/z_chrome.dart';
import '../core/widgets/z_motion.dart';
import '../core/widgets/z_product_card.dart';

/// Reference implementation of docs/screens/light/05-home.png (and dark/05-home.png).
///
/// Static demo data only. When wiring the real feature, keep this widget tree and
/// replace the `_demo*` lists with Riverpod providers from the home/catalog/cart repositories.
class HomeV2Screen extends StatefulWidget {
  const HomeV2Screen({super.key});

  @override
  State<HomeV2Screen> createState() => _HomeV2ScreenState();
}

class _Cat {
  const _Cat(this.label, this.asset, this.color);
  final String label, asset;
  final Color Function(ZColors) color;
}

class _Deal {
  const _Deal(this.name, this.weight, this.asset, this.price, [this.mrp]);
  final String name, weight, asset;
  final int price;
  final int? mrp;
}

const _img = 'assets/images/products';

final _demoCats = <_Cat>[
  _Cat('Fruits & Vegetables', '$_img/veg.png', (z) => z.tileVeg),
  _Cat('Dairy, Bread & Eggs', '$_img/dairy.png', (z) => z.tileDairy),
  _Cat('Atta, Rice & Dal', '$_img/basket.png', (z) => z.tileAll),
  _Cat('Oil, Ghee & Masala', '$_img/oil.png', (z) => z.tileOil),
  _Cat('Meat & Fish', '$_img/meat.png', (z) => z.tileMeat),
  _Cat('Bakery & Snacks', '$_img/bread.png', (z) => z.tileBakery),
  _Cat('Cold Drinks', '$_img/drinks.png', (z) => z.tileDrink),
  _Cat('Juices', '$_img/juice.png', (z) => z.tileFruit),
];

const _demoDeals = <_Deal>[
  _Deal('Seasonal Veg Box', '2 kg', '$_img/veg.png', 14900, 17900),
  _Deal('Shimla Apples', '1 kg', '$_img/apple.png', 17900, 19900),
  _Deal('Mixed Fruit Juice', '1 L', '$_img/juice.png', 11900),
];

class _HomeV2ScreenState extends State<HomeV2Screen> {
  final Map<String, int> _cart = {'Shimla Apples': 1};

  int get _count => _cart.values.fold(0, (a, b) => a + b);
  int get _total =>
      _demoDeals.fold(0, (s, d) => s + d.price * (_cart[d.name] ?? 0));
  int get _saved => _demoDeals.fold(
    0,
    (s, d) => s + ((d.mrp ?? d.price) - d.price) * (_cart[d.name] ?? 0),
  );

  void _add(String n) => setState(() => _cart[n] = (_cart[n] ?? 0) + 1);
  void _remove(String n) => setState(() {
    final q = (_cart[n] ?? 0) - 1;
    if (q <= 0) {
      _cart.remove(n);
    } else {
      _cart[n] = q;
    }
  });

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Scaffold(
      backgroundColor: z.bg,
      bottomNavigationBar: ZNavBar(index: 0, cartCount: _count, onTap: (_) {}),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  ZSpace.screen,
                  14,
                  ZSpace.screen,
                  100,
                ),
                sliver: SliverList.list(
                  children: [
                    const ZEntrance(index: 1, child: _PromoBanner()),
                    const SizedBox(height: 18),
                    ZEntrance(
                      index: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ZSectionHeader('Shop by category', onSeeAll: () {}),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 4,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 10,
                            childAspectRatio: 76 / 112,
                            children: [
                              for (final c in _demoCats)
                                ZCategoryTile(
                                  label: c.label,
                                  image: AssetImage(c.asset),
                                  color: c.color(z),
                                  onTap: () {},
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    ZEntrance(
                      index: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ZSectionHeader('Deals for you', onSeeAll: () {}),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 276,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none,
                              itemCount: _demoDeals.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (_, i) {
                                final d = _demoDeals[i];
                                return ZProductCard(
                                  width: 150,
                                  name: d.name,
                                  weight: d.weight,
                                  image: AssetImage(d.asset),
                                  price: d.price,
                                  mrp: d.mrp,
                                  quantity: _cart[d.name] ?? 0,
                                  onAdd: () => _add(d.name),
                                  onRemove: () => _remove(d.name),
                                  onTap: () {},
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_count > 0)
            Positioned(
              left: ZSpace.screen,
              right: ZSpace.screen,
              bottom: 12,
              child: ZCartBar(
                thumbnails: [
                  for (final d in _demoDeals)
                    if ((_cart[d.name] ?? 0) > 0)
                      Image.asset(d.asset, fit: BoxFit.contain),
                ],
                itemCount: _count,
                total: _total,
                saved: _saved,
                onTap: () {},
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return Container(
      color: z.header,
      padding: EdgeInsets.fromLTRB(
        ZSpace.screen,
        MediaQuery.paddingOf(context).top + 16,
        ZSpace.screen,
        18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ZYPPI EXPRESS',
                      style: t.labelSmall!.copyWith(
                        color: z.headerInk2,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        ZLoop(
                          child: Icon(
                            Icons.bolt_rounded,
                            color: z.deal,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '12 minutes',
                          style: t.headlineSmall!.copyWith(color: z.headerInk),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          Text(
                            'Home',
                            style: t.labelMedium!.copyWith(
                              color: z.headerInk,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              ' · Ranchi Road, Purulia',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.labelMedium!.copyWith(
                                color: z.headerInk2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: z.headerInk2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white.withValues(alpha: .16),
                child: Text(
                  'A',
                  style: t.titleMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ZSearchBar(onTap: () {}, onMic: () {}),
        ],
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return ZPressable(
      onTap: () {},
      child: Container(
        height: 128,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: z.deal, borderRadius: ZRadius.all(20)),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .35),
                ),
              ),
            ),
            Positioned(
              right: -6,
              bottom: -4,
              width: 168,
              child: ZLoop(
                kind: ZLoopKind.float,
                child: Image.asset('$_img/apple.png'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: z.dealInk,
                      borderRadius: ZRadius.all(6),
                    ),
                    child: Text(
                      'TODAY ONLY',
                      style: t.labelSmall!.copyWith(
                        color: z.deal,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Fresh fruits\nflat 20% off',
                    style: t.headlineSmall!.copyWith(
                      fontSize: 21,
                      color: z.dealInk,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'Shop now',
                        style: t.labelMedium!.copyWith(
                          color: z.dealInk,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: z.dealInk,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
