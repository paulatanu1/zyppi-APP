import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/data/coupon_repository.dart';
import 'package:zippy/core/data/mock/mock_data_source.dart';
import 'package:zippy/core/data/supabase_coupon_repository_impl.dart';
import 'package:zippy/core/domain/coupon.dart';

class MockCouponRepository implements CouponRepository {
  @override
  Future<Coupon?> findByCode(String code) async {
    await MockDataSource.simulateLatency();

    final json = await MockDataSource.loadJsonList('assets/mock/coupons.json');

    final match = json
        .map((e) => Coupon.fromJson(e as Map<String, dynamic>))
        .where((c) => c.code.toUpperCase() == code.trim().toUpperCase());

    return match.isEmpty ? null : match.first;
  }
}

final couponRepositoryProvider = Provider<CouponRepository>(
  (ref) => Env.isMockDataSource
      ? MockCouponRepository()
      : SupabaseCouponRepository(Supabase.instance.client),
);
