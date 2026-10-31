import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/data/home_section_repository.dart';
import 'package:zippy/core/data/mock/mock_data_source.dart';
import 'package:zippy/core/data/supabase_home_section_repository_impl.dart';
import 'package:zippy/core/domain/home_section.dart';

class MockHomeSectionRepository implements HomeSectionRepository {
  @override
  Future<List<HomeSection>> fetchHomeSections() async {
    await MockDataSource.simulateLatency();

    final json = await MockDataSource.loadJsonList(
      'assets/mock/home_sections.json',
    );

    return json
        .map((e) => HomeSection.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final homeSectionRepositoryProvider = Provider<HomeSectionRepository>(
  (ref) => Env.isMockDataSource
      ? MockHomeSectionRepository()
      : SupabaseHomeSectionRepository(Supabase.instance.client),
);
