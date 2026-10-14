import 'package:freezed_annotation/freezed_annotation.dart';

part 'delivery_slot.freezed.dart';
part 'delivery_slot.g.dart';

@freezed
abstract class DeliverySlot with _$DeliverySlot {
  factory DeliverySlot({
    required String id,
    required String label, // "In 12 minutes", "Schedule for later"
    required int etaMinutes,
    @Default(false) bool isExpress,
  }) = _DeliverySlot;

  factory DeliverySlot.fromJson(Map<String, dynamic> json) =>
      _$DeliverySlotFromJson(json);
}
