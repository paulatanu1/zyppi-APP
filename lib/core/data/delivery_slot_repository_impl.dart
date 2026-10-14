import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/delivery_slot_repository.dart';
import 'package:zippy/core/data/mock/mock_data_source.dart';
import 'package:zippy/core/domain/delivery_slot.dart';

class MockDeliverySlotRepository implements DeliverySlotRepository {
  @override
  Future<List<DeliverySlot>> fetchSlots() async {
    await MockDataSource.simulateLatency();

    final json = await MockDataSource.loadJsonList('assets/mock/slots.json');

    return json
        .map((e) => DeliverySlot.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final deliverySlotRepositoryProvider = Provider<DeliverySlotRepository>(
  (ref) => MockDeliverySlotRepository(),
);
