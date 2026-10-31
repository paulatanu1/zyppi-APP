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
                'data': item['data'] as Map<String, dynamic>,
              },
            )
            .toList(),
      });
    }).toList();
  }
}
