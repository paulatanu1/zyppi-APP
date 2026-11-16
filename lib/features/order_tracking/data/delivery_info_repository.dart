import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/firebase/firebase_setup.dart';

/// Where the delivery partner is (orders/{id}/tracking/live, written by
/// the rider app's pings while the order is out for delivery).
class RiderLive {
  const RiderLive({
    required this.lat,
    required this.lng,
    required this.distanceM,
    required this.etaMinutes,
    this.at,
  });

  final double lat;
  final double lng;
  final int distanceM;
  final int etaMinutes;
  final DateTime? at;

  static RiderLive? tryFrom(Map<String, dynamic>? d) {
    if (d == null || d['lat'] is! num || d['lng'] is! num) return null;
    return RiderLive(
      lat: (d['lat'] as num).toDouble(),
      lng: (d['lng'] as num).toDouble(),
      distanceM: (d['distanceM'] as num?)?.round() ?? 0,
      etaMinutes: (d['etaMinutes'] as num?)?.round() ?? 0,
      at: d['at'] is Timestamp ? (d['at'] as Timestamp).toDate() : null,
    );
  }

  /// Older than 3 minutes: the rider's phone may have lost signal.
  bool staleAt(DateTime now) =>
      at != null && now.difference(at!) > const Duration(minutes: 3);
}

/// The delivery code, the rider's live distance, and rating the rider
/// (functions/src/dispatch: handover code, riderPing, rateRider).
abstract class DeliveryInfoRepository {
  Stream<String?> watchCode(String orderId);
  Stream<RiderLive?> watchRider(String orderId);

  /// Whether the customer already rated this order's rider.
  Stream<bool> watchRated(String orderId);
  Future<void> rateRider(String orderId, int stars, List<String> tags);

  /// Marketplace sellers of the order the customer already rated.
  Stream<Set<String>> watchRatedSellers(String orderId);

  /// 1–5 stars per seller (rateSellers; once per seller per order).
  Future<void> rateSellers(String orderId, Map<String, int> stars);
}

class FirebaseDeliveryInfoRepository implements DeliveryInfoRepository {
  FirebaseDeliveryInfoRepository(this.db, this.functions);
  final FirebaseFirestore db;
  final FirebaseFunctions functions;

  DocumentReference<Map<String, dynamic>> _order(String id) =>
      db.collection('orders').doc(id);

  @override
  Stream<String?> watchCode(String orderId) =>
      _order(orderId)
          .collection('private')
          .doc('handover')
          .snapshots()
          .map((s) => s.data()?['code'] as String?);

  @override
  Stream<RiderLive?> watchRider(String orderId) =>
      _order(orderId)
          .collection('tracking')
          .doc('live')
          .snapshots()
          .map((s) => RiderLive.tryFrom(s.data()));

  @override
  Stream<bool> watchRated(String orderId) =>
      _order(orderId).snapshots().map((s) => s.data()?['riderRating'] != null);

  @override
  Future<void> rateRider(String orderId, int stars, List<String> tags) =>
      functions.httpsCallable('rateRider').call<Object?>({
        'orderId': orderId,
        'stars': stars,
        'tags': tags,
      });

  @override
  Stream<Set<String>> watchRatedSellers(String orderId) => _order(orderId)
      .snapshots()
      .map(
        (s) => ((s.data()?['sellerRatings'] as Map?) ?? const {}).keys
            .cast<String>()
            .toSet(),
      );

  @override
  Future<void> rateSellers(String orderId, Map<String, int> stars) => functions
      .httpsCallable('rateSellers')
      .call<Object?>({'orderId': orderId, 'ratings': stars});
}

/// Mock data source: a fixed code, no live rider.
class MockDeliveryInfoRepository implements DeliveryInfoRepository {
  final _rated = <String>{};

  @override
  Stream<String?> watchCode(String orderId) => Stream.value('4821');
  @override
  Stream<RiderLive?> watchRider(String orderId) => Stream.value(null);
  @override
  Stream<bool> watchRated(String orderId) =>
      Stream.value(_rated.contains(orderId));
  @override
  Future<void> rateRider(String orderId, int stars, List<String> tags) async =>
      _rated.add(orderId);

  final _sellers = <String, Set<String>>{};
  @override
  Stream<Set<String>> watchRatedSellers(String orderId) =>
      Stream.value(_sellers[orderId] ?? const {});
  @override
  Future<void> rateSellers(String orderId, Map<String, int> stars) async =>
      (_sellers[orderId] ??= {}).addAll(stars.keys);
}

final deliveryInfoRepositoryProvider = Provider<DeliveryInfoRepository>(
  (ref) => Env.isMockDataSource
      ? MockDeliveryInfoRepository()
      : FirebaseDeliveryInfoRepository(
          FirebaseFirestore.instance,
          zyppiFunctions(),
        ),
);

final handoverCodeProvider = StreamProvider.autoDispose.family<String?, String>(
  (ref, id) => ref.watch(deliveryInfoRepositoryProvider).watchCode(id),
);

final riderLiveProvider = StreamProvider.autoDispose.family<RiderLive?, String>(
  (ref, id) => ref.watch(deliveryInfoRepositoryProvider).watchRider(id),
);

final riderRatedProvider = StreamProvider.autoDispose.family<bool, String>(
  (ref, id) => ref.watch(deliveryInfoRepositoryProvider).watchRated(id),
);

final ratedSellersProvider = StreamProvider.autoDispose
    .family<Set<String>, String>(
      (ref, id) =>
          ref.watch(deliveryInfoRepositoryProvider).watchRatedSellers(id),
    );
