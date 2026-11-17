import 'package:cloud_functions/cloud_functions.dart';
import 'package:zippy/core/data/coupon_repository.dart';
import 'package:zippy/core/domain/coupon.dart';

/// The `checkCoupon` callable: it knows this customer's earlier uses and
/// orders, which the app can't read. placeOrder checks the code again.
class FirebaseCouponRepository implements CouponRepository {
  final FirebaseFunctions functions;

  FirebaseCouponRepository(this.functions);

  @override
  Future<Coupon?> findByCode(String code, {String? serviceAreaId}) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return null;

    final Map<String, dynamic> data;
    try {
      final result = await functions
          .httpsCallable('checkCoupon')
          .call<Map<String, dynamic>>({
            'code': normalized,
            'serviceAreaId': ?serviceAreaId,
          });
      data = Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (error) {
      if (error.code != 'failed-precondition') rethrow;
      final details = error.details;
      final problem = CouponProblem.fromWire(
        details is Map ? details['reason'] : null,
      );
      if (problem == CouponProblem.invalid) return null;
      throw CouponRejected(problem);
    }

    return Coupon(
      code: data['code'] as String? ?? normalized,
      description: data['description'] as String? ?? '',
      type: data['type'] == 'percent' ? CouponType.percent : CouponType.flat,
      discountPaise: (data['discountPaise'] as num?)?.toInt() ?? 0,
      percent: (data['percent'] as num?)?.toInt() ?? 0,
      maxDiscountPaise: (data['maxDiscountPaise'] as num?)?.toInt(),
      minOrderPaise: (data['minOrderPaise'] as num?)?.toInt(),
    );
  }
}
