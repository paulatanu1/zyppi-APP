import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/data/mock/mock_data_source.dart';
import 'package:zippy/core/domain/delivery_config.dart';

abstract class DeliveryConfigRepository {
  Future<DeliveryConfig> fetch();
}

/// `config/delivery` (public read, admin write — firestore.rules).
class FirebaseDeliveryConfigRepository implements DeliveryConfigRepository {
  FirebaseDeliveryConfigRepository(this.firestore);
  final FirebaseFirestore firestore;

  @override
  Future<DeliveryConfig> fetch() async {
    final data = (await firestore.doc('config/delivery').get()).data();
    if (data == null) return DeliveryConfig.free;
    int paise(String key) => switch (data[key]) {
      final int v when v > 0 => v,
      _ => 0,
    };
    return DeliveryConfig(
      feePaise: paise('feePaise'),
      freeAbovePaise: paise('freeAbovePaise'),
      minOrderPaise: paise('minOrderPaise'),
    );
  }
}

/// Same values the seed script writes.
class MockDeliveryConfigRepository implements DeliveryConfigRepository {
  @override
  Future<DeliveryConfig> fetch() async {
    await MockDataSource.simulateLatency();
    return const DeliveryConfig(
      feePaise: 2500,
      freeAbovePaise: 49900,
      minOrderPaise: 9900,
    );
  }
}

final deliveryConfigRepositoryProvider = Provider<DeliveryConfigRepository>(
  (ref) => Env.isMockDataSource
      ? MockDeliveryConfigRepository()
      : FirebaseDeliveryConfigRepository(FirebaseFirestore.instance),
);

/// The current delivery rule; falls back to [DeliveryConfig.free] if it
/// can't be read (the server still enforces the real rule at checkout).
final deliveryConfigProvider = FutureProvider<DeliveryConfig>((ref) async {
  try {
    return await ref.read(deliveryConfigRepositoryProvider).fetch();
  } catch (_) {
    return DeliveryConfig.free;
  }
});
