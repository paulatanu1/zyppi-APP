import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/features/search_address/domain/place_repository.dart';

/// Phase 4: Places autocomplete/details go through the `places-proxy` Edge
/// Function instead of a client-side Google Places key
/// (supabase/functions/places-proxy/index.ts).
class SupabasePlaceRepository implements PlaceRepository {
  final SupabaseClient client;

  SupabasePlaceRepository(this.client);

  @override
  Future<Map<String, dynamic>> fetchPlacePredictions(String? input) async {
    final response = await client.functions.invoke(
      'places-proxy',
      body: {'action': 'autocomplete', 'input': input},
    );

    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> fetchPlaceDetails(String? placeId) async {
    final response = await client.functions.invoke(
      'places-proxy',
      body: {'action': 'details', 'placeId': placeId},
    );

    return response.data as Map<String, dynamic>;
  }
}
