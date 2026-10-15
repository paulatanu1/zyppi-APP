import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/data/delivery_slot_repository.dart';
import 'package:zippy/core/domain/delivery_slot.dart';

/// Phase 3: live Supabase-backed delivery slots, selected by
/// `deliverySlotRepositoryProvider` (delivery_slot_repository_impl.dart)
/// instead of `MockDeliverySlotRepository` when Env.dataSource != 'mock'.
class SupabaseDeliverySlotRepository implements DeliverySlotRepository {
  final SupabaseClient client;

  SupabaseDeliverySlotRepository(this.client);

  @override
  Future<List<DeliverySlot>> fetchSlots() async {
    final rows = await client
        .from('delivery_slots')
        .select('id, label, etaMinutes:eta_minutes, isExpress:is_express')
        .eq('is_active', true)
        .order('eta_minutes');

    return rows.map((row) => DeliverySlot.fromJson(row)).toList();
  }
}
