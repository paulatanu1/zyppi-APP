import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_filter.dart';
import 'package:zippy/core/domain/product_variant.dart';

Product _p(String id, int price, {int? mrp, bool noVariant = false}) => Product(
  id: id,
  name: id,
  categoryId: 'c',
  variants: noVariant
      ? const []
      : [
          ProductVariant(
            id: '$id-v',
            label: '1',
            pricePaise: price,
            mrpPaise: mrp,
          ),
        ],
);

void main() {
  final products = [
    _p('cheap', 3000),
    _p('mid', 8000, mrp: 10000),
    _p('pricey', 25000, mrp: 26000),
    _p('none', 0, noVariant: true),
  ];

  List<String> ids(List<Product> list) => list.map((p) => p.id).toList();

  test('no filter keeps everything sellable in its original order', () {
    expect(ids(ProductFilter.none.apply(products)), ['cheap', 'mid', 'pricey']);
    expect(ProductFilter.none.isActive, isFalse);
  });

  test('sorts by price both ways and by discount', () {
    expect(
      ids(
        const ProductFilter(sort: ProductSort.priceHighToLow).apply(products),
      ),
      ['pricey', 'mid', 'cheap'],
    );
    expect(
      ids(
        const ProductFilter(sort: ProductSort.priceLowToHigh).apply(products),
      ),
      ['cheap', 'mid', 'pricey'],
    );
    expect(
      ids(const ProductFilter(sort: ProductSort.discount).apply(products)),
      ['mid', 'pricey', 'cheap'],
    );
  });

  test('price bands combine as "any of"', () {
    const filter = ProductFilter(
      priceBands: {PriceBand.under50, PriceBand.over200},
    );
    expect(ids(filter.apply(products)), ['cheap', 'pricey']);
    expect(filter.activeCount, 2);
  });

  test('only discounted drops full-price items', () {
    expect(ids(const ProductFilter(onlyDiscounted: true).apply(products)), [
      'mid',
      'pricey',
    ]);
  });
}
