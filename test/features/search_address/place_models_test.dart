import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/features/search_address/domain/place_details.dart';
import 'package:zippy/features/search_address/domain/place_prediction.dart';

// The shapes placesProxy (functions/src/places.ts) and the device-geocoder
// fallback return. A snake_case `place_id` here once left every
// suggestion without an id, so picking one never resolved a location.
void main() {
  test('predictions carry their placeId', () {
    final parsed = PlacePrediction.fromJson({
      'status': 'OK',
      'predictions': [
        {
          'description': 'Purulia Station, Purulia',
          'placeId': 'abc',
          'structuredFormatting': {
            'mainText': 'Purulia Station',
            'secondaryText': 'Purulia',
          },
        },
      ],
    });

    expect(parsed.predictions?.single.placeId, 'abc');
    expect(
      parsed.predictions?.single.structuredFormatting?.mainText,
      'Purulia Station',
    );
  });

  test('details carry location and address components', () {
    final parsed = PlaceDetails.fromJson({
      'status': 'OK',
      'result': {
        'formattedAddress': 'Station Rd, Purulia 723101',
        'geometry': {
          'location': {'lat': 23.33, 'lng': 86.36},
        },
        'addressComponents': [
          {
            'longName': '723101',
            'shortName': '723101',
            'types': ['postal_code'],
          },
        ],
      },
    });

    expect(parsed.result?.geometry?.location?.lat, 23.33);
    expect(parsed.result?.addressComponents?.single.longName, '723101');
  });
}
