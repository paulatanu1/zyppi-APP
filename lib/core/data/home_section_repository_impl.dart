import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/data/home_section_repository.dart';
import 'package:zippy/core/data/mock/mock_data_source.dart';
import 'package:zippy/core/data/firebase_home_section_repository_impl.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/firebase/firebase_setup.dart';

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

  @override
  Future<void> recordBannerClick(String sectionId, String itemId) async {}
}

final homeSectionRepositoryProvider = Provider<HomeSectionRepository>(
  (ref) => Env.isMockDataSource
      ? MockHomeSectionRepository()
      : FirebaseHomeSectionRepository(
          FirebaseFirestore.instance,
          zyppiFunctions(),
        ),
);
