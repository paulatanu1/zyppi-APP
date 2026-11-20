import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:zippy/core/utils/parsed_address.dart';
import 'package:zippy/features/search_address/domain/place_details.dart';

void main() {
  group('isPlusCode', () {
    test('spots plus codes, alone or with a locality', () {
      expect(isPlusCode('JH83+23P'), isTrue);
      expect(isPlusCode('JH83+23P Chelyama'), isTrue);
      expect(isPlusCode('7MJCJH83+23P'), isTrue);
      expect(isPlusCode(' jh83+23p, West Bengal'), isTrue);
    });

    test('leaves real names alone', () {
      expect(isPlusCode('Chelyama Girls High School'), isFalse);
      expect(isPlusCode('12 Hill View Road'), isFalse);
      expect(isPlusCode(''), isFalse);
      expect(isPlusCode(null), isFalse);
    });
  });

  group('ParsedAddress.fromPlacemark', () {
    test('never uses a plus code as line 1', () {
      final parsed = ParsedAddress.fromPlacemark(
        geocoding.Placemark(
          name: 'JH83+23P',
          street: 'JH83+23P, Chelyama',
          locality: 'Chelyama',
          administrativeArea: 'West Bengal',
        ),
      );
      expect(parsed.line1, '');
      expect(parsed.city, 'Chelyama');
    });

    test('uses the placemark name when it is a real name', () {
      final parsed = ParsedAddress.fromPlacemark(
        geocoding.Placemark(name: 'Saheb Bandh Road', locality: 'Purulia'),
      );
      expect(parsed.line1, 'Saheb Bandh Road');
    });
  });

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
