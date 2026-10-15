import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/utils/parsed_address.dart';
import 'package:zippy/features/search_address/domain/place_details.dart';

void main() {
  group('ParsedAddress.fromGoogleComponents', () {
    test('prefers street number + route for line1', () {
      final parsed = ParsedAddress.fromGoogleComponents([
        AddressComponent(longName: '12', types: const ['street_number']),
        AddressComponent(longName: 'Hill View Road', types: const ['route']),
        AddressComponent(longName: 'Nutundih', types: const ['sublocality']),
        AddressComponent(longName: 'Purulia', types: const ['locality']),
        AddressComponent(
          longName: 'West Bengal',
          types: const ['administrative_area_level_1'],
        ),
        AddressComponent(longName: '723101', types: const ['postal_code']),
      ]);

      expect(parsed.line1, '12 Hill View Road');
      expect(parsed.area, 'Nutundih');
      expect(parsed.city, 'Purulia');
      expect(parsed.state, 'West Bengal');
      expect(parsed.postalCode, '723101');
    });

    test('falls back to premise, then the caller-supplied fallback', () {
      final withPremise = ParsedAddress.fromGoogleComponents([
        AddressComponent(longName: 'Green Residency', types: const ['premise']),
      ], fallbackLine1: 'ignored');
      expect(withPremise.line1, 'Green Residency');

      final withNeither = ParsedAddress.fromGoogleComponents(
        const [],
        fallbackLine1: 'Typed search text',
      );
      expect(withNeither.line1, 'Typed search text');
    });

    test('leaves fields empty when no matching component exists', () {
      final parsed = ParsedAddress.fromGoogleComponents(const []);

      expect(parsed.line1, '');
      expect(parsed.area, '');
      expect(parsed.city, '');
      expect(parsed.state, '');
      expect(parsed.postalCode, '');
    });
  });
}
