import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/data/coupon_repository.dart';
import 'package:zippy/core/domain/coupon.dart';

/// Live Supabase-backed coupon lookup, selected by `couponRepositoryProvider`
/// (coupon_repository_impl.dart) instead of `MockCouponRepository` when
/// Env.dataSource != 'mock'. RLS only exposes active, unexpired coupons;
/// place_order() re-validates the code server-side regardless.
class SupabaseCouponRepository implements CouponRepository {
  final SupabaseClient client;

  SupabaseCouponRepository(this.client);

  @override
  Future<Coupon?> findByCode(String code) async {
    final row = await client
        .from('coupons')
        .select(
          'code, description, discountPaise:discount_paise, '
          'minOrderPaise:min_order_paise',
        )
        .eq('code', code.trim().toUpperCase())
        .maybeSingle();

    if (row == null) return null;
    return Coupon.fromJson({...row, 'description': row['description'] ?? ''});
  }
}
