import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/cart/data/supabase_cart_repository_impl.dart';
import 'package:zippy/core/cart/domain/cart_repository.dart';
import 'package:zippy/core/config/env.dart';

/// Null in the mock flavor: there the device copy (LocalCartStore) is the
/// whole cart and nothing syncs.
final cartRepositoryProvider = Provider<CartRepository?>(
  (ref) => Env.isMockDataSource
      ? null
      : SupabaseCartRepository(Supabase.instance.client),
);
