import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zippy/core/data/home_section_repository.dart';
import 'package:zippy/core/domain/home_section.dart';

/// `homeSections`, each with its items embedded in display order. Item
/// images are stored as download URLs.
class FirebaseHomeSectionRepository implements HomeSectionRepository {
  final FirebaseFirestore firestore;

  FirebaseHomeSectionRepository(this.firestore);

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
            .map((item) => {'id': item['id'], 'data': item['data'] ?? {}})
            .toList(),
      });
    }).toList();
  }
}
