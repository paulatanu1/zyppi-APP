import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/data/home_section_repository.dart';
import 'package:zippy/core/domain/home_section.dart';

class SupabaseHomeSectionRepository implements HomeSectionRepository {
  final SupabaseClient client;

  SupabaseHomeSectionRepository(this.client);

  @override
  Future<List<HomeSection>> fetchHomeSections() async {
    final rows = await client
        .from('home_sections')
        .select('''
          id, type, title, subtitle, config,
          items:home_section_items(id, data, display_order)
        ''')
        .order('display_order');

    return rows.map((row) {
      final items =
          (row['items'] as List<dynamic>).cast<Map<String, dynamic>>().toList()
            ..sort(
              (a, b) => (a['display_order'] as int).compareTo(
                b['display_order'] as int,
              ),
            );

      return HomeSection.fromJson({
        ...row,
        'items': items
            .map(
              (item) => {
                'id': item['id'],
                'data': _resolveImages(item['data'] as Map<String, dynamic>),
              },
            )
            .toList(),
      });
    }).toList();
  }

  static const _imagesBucket = 'catalog-images';

  /// Section items store images as object paths in the catalog bucket
  /// (supabase/seed.sql), like products do — resolve them to public URLs
  /// so CatalogImage gets something it can load (a bare path is treated as
  /// a bundled asset and silently falls back).
  Map<String, dynamic> _resolveImages(Map<String, dynamic> data) {
    final resolved = {...data};
    for (final key in const ['image_url', 'image']) {
      final value = data[key];
      if (value is String && value.isNotEmpty && !value.startsWith('http')) {
        resolved[key] = client.storage.from(_imagesBucket).getPublicUrl(value);
      }
    }
    return resolved;
  }
}
