import 'package:zippy/core/domain/delivery_slot.dart';

abstract class DeliverySlotRepository {
  Future<List<DeliverySlot>> fetchSlots();
}
