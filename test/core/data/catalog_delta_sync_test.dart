import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:zippy/core/data/catalog_store.dart';
import 'package:zippy/core/data/firebase_catalog_repository_impl.dart';

void main() {
  late Directory dir;
  late Box box;
  late FakeFirebaseFirestore db;
  var now = DateTime(2026, 11, 22, 10);

  Timestamp at(int minute) =>
      Timestamp.fromDate(DateTime(2026, 11, 22, 9, minute));

  Map<String, dynamic> product(
    String name, {
    bool active = true,
    required int minute,
    int price = 100,
  }) => {
    'name': name,
    'categoryId': 'c1',
    'isActive': active,
    'imageUrl': null,
    'variants': [
      {'id': 'v1', 'label': '1 kg', 'pricePaise': price, 'mrpPaise': price},
    ],
    'areaBest': {
      'a1': {
        'v1': {
          'offerId': 'o-$name',
          'sellerId': 's1',
          'sellerName': 'Shop',
          'pricePaise': price - 1,
          'mrpPaise': price,
        },
      },
    },
    'updatedAt': at(minute),
  };

  FirebaseCatalogRepository synced() =>
      FirebaseCatalogRepository(db, store: CatalogStore(box), now: () => now);

  /// The old behaviour: one full active-products query.
  Future<List<String>> fullFetchJson() async =>
      (await FirebaseCatalogRepository(
        db,
      ).fetchProducts()).map((p) => p.toString()).toList();

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('catalog_sync_test');
    Hive.init(dir.path);
    box = await Hive.openBox('catalog');
    db = FakeFirebaseFirestore();
    now = DateTime(2026, 11, 22, 10);
    await db.doc('products/p1').set(product('Apple', minute: 1));
    await db.doc('products/p2').set(product('Banana', minute: 2));
    await db
        .doc('products/p3')
        .set(product('Cherry', active: false, minute: 3));
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('first run downloads the active catalog and stores it', () async {
    final products = await synced().fetchProducts();
    expect(products.map((p) => p.id), ['p1', 'p2']);
    expect(
      CatalogStore(box).readProducts().keys,
      unorderedEquals(['p1', 'p2']),
    );
    expect(
      CatalogStore(box).readMeta()!.cursorMillis,
      at(2).millisecondsSinceEpoch,
    );
  });

  test('a later session applies only changes, incl. deactivation', () async {
    await synced().fetchProducts();

    await db.doc('products/p1').update({
      'name': 'Green Apple',
      'updatedAt': at(10),
    });
    await db.doc('products/p2').update({
      'isActive': false,
      'updatedAt': at(11),
    });
    await db.doc('products/p3').update({'isActive': true, 'updatedAt': at(12)});

    // A new app session: fresh repository, same disk store.
    final products = await synced().fetchProducts();
    expect(products.map((p) => p.id), ['p1', 'p3']);
    expect(products.first.name, 'Green Apple');
    expect(products.map((p) => p.toString()), await fullFetchJson());
  });

  test('stored products survive a JSON round trip unchanged', () async {
    await synced().fetchProducts();
    await Hive.close();
    box = await Hive.openBox('catalog');
    expect(
      CatalogStore(box).readProducts().values.map((p) => p.toString()),
      unorderedEquals(await fullFetchJson()),
    );
  });

  test(
    'changes to an unsynced product are ignored only until full resync',
    () async {
      // Cursor well past p1, outside the overlap window.
      await db.doc('products/p2').update({'updatedAt': at(30)});
      await synced().fetchProducts();
      // A write that didn't bump updatedAt (should never happen).
      await db.doc('products/p1').update({'name': 'Sneaky'});

      expect((await synced().fetchProducts()).first.name, 'Apple');

      now = now.add(FirebaseCatalogRepository.fullSyncEvery);
      expect((await synced().fetchProducts()).first.name, 'Sneaky');
    },
  );

  test('bumping config/catalogSync.epoch forces a full resync', () async {
    await synced().fetchProducts();
    await db.doc('products/p1').update({'name': 'Sneaky'});
    await db.doc('config/catalogSync').set({'epoch': 2});

    expect((await synced().fetchProducts()).first.name, 'Sneaky');
    expect(CatalogStore(box).readMeta()!.epoch, 2);
  });

  test('an empty or corrupt store resyncs fully', () async {
    await box.put('products', 'not a map');
    await box.put('meta', '{"cursorMillis": 99999999999999}');
    final products = await synced().fetchProducts();
    expect(products.map((p) => p.id), ['p1', 'p2']);
  });

  test(
    'offline: falls back to the stored catalog, or fails if empty',
    () async {
      await synced().fetchProducts();
      final offline = _FailingFirestore();
      final repo = FirebaseCatalogRepository(
        offline,
        store: CatalogStore(box),
        now: () => now,
      );
      expect((await repo.fetchProducts()).map((p) => p.id), ['p1', 'p2']);

      await box.clear();
      expect(
        FirebaseCatalogRepository(
          offline,
          store: CatalogStore(box),
        ).fetchProducts(),
        throwsA(isA<FirebaseException>()),
      );
    },
  );

  test('without a store it behaves as before', () async {
    expect((await FirebaseCatalogRepository(db).fetchProducts()).length, 2);
    expect(box.isEmpty, isTrue);
  });
}

/// Every read fails, as when the device is offline.
class _FailingFirestore extends Fake implements FirebaseFirestore {
  @override
  DocumentReference<Map<String, dynamic>> doc(String path) =>
      throw FirebaseException(plugin: 'cloud_firestore', code: 'unavailable');

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      throw FirebaseException(plugin: 'cloud_firestore', code: 'unavailable');
}
