import 'package:zippy/features/explore/domain/explore.dart';

abstract class ExploreRepository {
  Future<List<Explore>> fetchExploreCategories();
}
