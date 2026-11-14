import 'package:zippy/core/domain/home_section.dart';

/// The Home screen's backend/admin-driven section stack — see
/// docs/PLAN.md's note on the typed-section/flexible-item model.
abstract class HomeSectionRepository {
  /// Active sections, ordered by `display_order`, each with its items
  /// already ordered the same way.
  Future<List<HomeSection>> fetchHomeSections();

  /// Counts one tap on a banner (admin click stats). Best effort.
  Future<void> recordBannerClick(String sectionId, String itemId);
}
