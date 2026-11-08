import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zippy/core/data/service_area_repository.dart';
import 'package:zippy/core/domain/service_area.dart';
import 'package:zippy/core/utils/haversine.dart';

/// Reads the (few, public) `serviceAreas` and does the distance check on
/// the device; the server repeats it when an order is placed.
class FirebaseServiceAreaRepository implements ServiceAreaRepository {
  final FirebaseFirestore firestore;

  FirebaseServiceAreaRepository(this.firestore);

  @override
  Future<ServiceArea?> findServiceableArea(double lat, double lng) async {
    final snap = await firestore
        .collection('serviceAreas')
        .where('isActive', isEqualTo: true)
        .get();

    final areas = snap.docs.map((doc) {
      final d = doc.data();
      return ServiceArea(
        id: doc.id,
        name: d['name'] as String,
        isActive: true,
        centerLat: (d['centerLat'] as num?)?.toDouble(),
        centerLng: (d['centerLng'] as num?)?.toDouble(),
        radiusMeters: (d['radiusMeters'] as num?)?.toInt(),
      );
    }).toList();

    return nearestServiceableArea(areas, lat, lng);
  }
}
