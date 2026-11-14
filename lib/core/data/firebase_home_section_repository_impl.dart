import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:zippy/core/data/home_section_repository.dart';
import 'package:zippy/core/domain/home_section.dart';

/// `homeSections`, each with its items embedded in display order. Item
/// images are stored as download URLs. Scheduled and area-only items come
/// back too; homeSectionsProvider filters them.
class FirebaseHomeSectionRepository implements HomeSectionRepository {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  FirebaseHomeSectionRepository(this.firestore, this.functions);

  @override
  Future<List<HomeSection>> fetchHomeSections() async {
    final snap = await firestore
        .collection('homeSections')
        .where('isActive', isEqualTo: true)
        .orderBy('displayOrder')
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      return HomeSection.fromJson({
        'id': doc.id,
        'type': data['type'],
        'title': data['title'],
        'subtitle': data['subtitle'],
        'config': data['config'] ?? const <String, dynamic>{},
        'items': (data['items'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(
              (item) => {
                'id': item['id'],
                'data': item['data'] ?? {},
                'startAt': _iso(item['startAt']),
                'endAt': _iso(item['endAt']),
                'serviceAreaIds': item['serviceAreaIds'] ?? const <String>[],
                'isActive': item['isActive'] ?? true,
              },
            )
            .toList(),
      });
    }).toList();
  }

  @override
  Future<void> recordBannerClick(String sectionId, String itemId) async {
    await functions.httpsCallable('trackBannerClick').call<void>({
      'sectionId': sectionId,
      'itemId': itemId,
    });
  }
}

String? _iso(Object? value) =>
    value is Timestamp ? value.toDate().toIso8601String() : null;
