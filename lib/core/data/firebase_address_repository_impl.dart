import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zippy/core/data/address_repository.dart';
import 'package:zippy/core/domain/address.dart';

/// `users/{uid}/addresses`. The server re-derives each order's service
/// area from the address's coordinates, so `serviceAreaId` here is only a
/// convenience for the admin panel.
class FirebaseAddressRepository implements AddressRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  FirebaseAddressRepository(this.auth, this.firestore);

  CollectionReference<Map<String, dynamic>> get _addresses {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('Not signed in');
    return firestore.collection('users').doc(uid).collection('addresses');
  }

  @override
  Future<List<Address>> fetchAddresses() async {
    final snap = await _addresses.orderBy('createdAt').get();
    return snap.docs.map((doc) {
      final d = doc.data();
      return Address(
        id: doc.id,
        label: d['label'] as String,
        line1: d['line1'] as String,
        area: d['area'] as String? ?? '',
        city: d['city'] as String? ?? '',
        state: d['state'] as String? ?? '',
        postalCode: d['postalCode'] as String? ?? '',
        landmark: d['landmark'] as String?,
        lat: (d['lat'] as num).toDouble(),
        lng: (d['lng'] as num).toDouble(),
        isDefault: d['isDefault'] as bool? ?? false,
      );
    }).toList();
  }

  @override
  Future<void> addAddress(
    Address address, {
    required String serviceAreaId,
  }) async {
    final addresses = _addresses;
    final batch = firestore.batch();
    // Only one default address per user.
    if (address.isDefault) {
      final current = await addresses.where('isDefault', isEqualTo: true).get();
      for (final doc in current.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
    }
    batch.set(addresses.doc(), {
      'serviceAreaId': serviceAreaId,
      'label': address.label,
      'line1': address.line1,
      'area': address.area,
      'city': address.city,
      'state': address.state,
      'postalCode': address.postalCode,
      'landmark': address.landmark,
      'lat': address.lat,
      'lng': address.lng,
      'isDefault': address.isDefault,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  @override
  Future<void> updateAddress(Address address) =>
      _addresses.doc(address.id).update({
        'label': address.label,
        'line1': address.line1,
        'landmark': address.landmark,
      });

  @override
  Future<void> deleteAddress(String id) => _addresses.doc(id).delete();

  @override
  Future<void> setDefault(String id) async {
    final addresses = _addresses;
    final current = await addresses.where('isDefault', isEqualTo: true).get();
    final batch = firestore.batch();
    for (final doc in current.docs) {
      if (doc.id != id) batch.update(doc.reference, {'isDefault': false});
    }
    batch.update(addresses.doc(id), {'isDefault': true});
    await batch.commit();
  }
}
