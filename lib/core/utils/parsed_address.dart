import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:zippy/features/search_address/domain/place_details.dart';

/// The subset of an [Address]'s fields that can be derived from a reverse
/// geocode (map-pin picker) or a Google Places Details response (search
/// result) — both feed the same `line1/area/city/state/postalCode` shape.
class ParsedAddress {
  final String line1;
  final String area;
  final String city;
  final String state;
  final String postalCode;

  const ParsedAddress({
    required this.line1,
    required this.area,
    required this.city,
    required this.state,
    required this.postalCode,
  });

  factory ParsedAddress.fromPlacemark(geocoding.Placemark placemark) {
    final street = [
      placemark.subThoroughfare,
      placemark.thoroughfare,
    ].where((part) => part != null && part.isNotEmpty).join(' ');

    return ParsedAddress(
      line1: street.isNotEmpty
          ? street
          : (placemark.name ?? placemark.street ?? ''),
      area: placemark.subLocality?.isNotEmpty == true
          ? placemark.subLocality!
          : (placemark.locality ?? ''),
      city: placemark.locality ?? placemark.subAdministrativeArea ?? '',
      state: placemark.administrativeArea ?? '',
      postalCode: placemark.postalCode ?? '',
    );
  }

  factory ParsedAddress.fromGoogleComponents(
    List<AddressComponent> components, {
    String fallbackLine1 = '',
  }) {
    String byType(List<String> types) {
      for (final component in components) {
        if ((component.types ?? const []).any(types.contains)) {
          return component.longName ?? '';
        }
      }
      return '';
    }

    final streetNumber = byType(['street_number']);
    final route = byType(['route']);
    final premise = byType(['premise']);
    final street = [
      streetNumber,
      route,
    ].where((part) => part.isNotEmpty).join(' ');

    return ParsedAddress(
      line1: street.isNotEmpty
          ? street
          : (premise.isNotEmpty ? premise : fallbackLine1),
      area: byType(['sublocality', 'sublocality_level_1', 'neighborhood']),
      city: byType(['locality', 'administrative_area_level_2']),
      state: byType(['administrative_area_level_1']),
      postalCode: byType(['postal_code']),
    );
  }
}
