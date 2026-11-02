import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zippy/core/data/coupon_repository.dart';
import 'package:zippy/core/domain/coupon.dart';

/// `coupons/{CODE}`. The rules only let customers read an active,
/// unexpired coupon, so anything else reads as "not found"; placeOrder
/// re-validates the code server-side regardless.
class FirebaseCouponRepository implements CouponRepository {
  final FirebaseFirestore firestore;

  FirebaseCouponRepository(this.firestore);

  @override
  Future<Coupon?> findByCode(String code) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty || normalized.contains('/')) return null;

    final DocumentSnapshot<Map<String, dynamic>> doc;
    try {
      doc = await firestore.collection('coupons').doc(normalized).get();
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') return null;
      rethrow;
    }
    final data = doc.data();
    if (data == null) return null;

    return Coupon(
      code: doc.id,
      description: data['description'] as String? ?? '',
      discountPaise: data['discountPaise'] as int,
      minOrderPaise: data['minOrderPaise'] as int?,
    );
  }
}
