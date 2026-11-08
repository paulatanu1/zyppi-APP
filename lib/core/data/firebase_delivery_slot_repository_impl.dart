import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zippy/core/data/delivery_slot_repository.dart';
import 'package:zippy/core/domain/delivery_slot.dart';

class FirebaseDeliverySlotRepository implements DeliverySlotRepository {
  final FirebaseFirestore firestore;

  FirebaseDeliverySlotRepository(this.firestore);

  @override
  Future<List<DeliverySlot>> fetchSlots() async {
    final snap = await firestore
        .collection('deliverySlots')
        .where('isActive', isEqualTo: true)
        .get();

    return snap.docs
        .map(
          (doc) => DeliverySlot(
            id: doc.id,
            label: doc.data()['label'] as String,
            etaMinutes: doc.data()['etaMinutes'] as int,
            isExpress: doc.data()['isExpress'] as bool? ?? false,
          ),
        )
        .toList()
      ..sort((a, b) => a.etaMinutes.compareTo(b.etaMinutes));
  }
}
