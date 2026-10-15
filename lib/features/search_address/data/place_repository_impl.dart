import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/data/mock/mock_data_source.dart';
import 'package:zippy/features/search_address/data/supabase_place_repository_impl.dart';
import 'package:zippy/features/search_address/domain/place_repository.dart';

/// Canned predictions covering the three launch towns, so the search flow
/// works offline in the mock flavor without a Places key at all.
class MockPlaceRepository implements PlaceRepository {
  @override
  Future<Map<String, dynamic>> fetchPlacePredictions(String? input) async {
    await MockDataSource.simulateLatency();

    final json = await MockDataSource.loadJsonMap(
      'assets/mock/place_predictions.json',
    );
    final predictions = json['predictions'] as List<dynamic>;
    final query = (input ?? '').toLowerCase();

    final matches = query.isEmpty
        ? predictions
        : predictions.where(
            (p) => (p['description'] as String).toLowerCase().contains(query),
          );

    return {'predictions': matches.toList(), 'status': 'OK'};
  }

  @override
  Future<Map<String, dynamic>> fetchPlaceDetails(String? placeId) async {
    await MockDataSource.simulateLatency();

    final json = await MockDataSource.loadJsonMap(
      'assets/mock/place_predictions.json',
    );
    final details = json['details'] as Map<String, dynamic>;
    final result = details[placeId];

    if (result == null) {
      return {'status': 'NOT_FOUND'};
    }
    return {'result': result, 'status': 'OK'};
  }
}

final placeRepositoryProvider = Provider<PlaceRepository>(
  (ref) => Env.isMockDataSource
      ? MockPlaceRepository()
      : SupabasePlaceRepository(Supabase.instance.client),
);
