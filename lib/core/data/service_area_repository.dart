import 'package:zippy/core/domain/service_area.dart';

abstract class ServiceAreaRepository {
  /// The nearest active service area whose radius covers `(lat, lng)`, or
  /// null if the point falls outside every launch area.
  Future<ServiceArea?> findServiceableArea(double lat, double lng);
}
