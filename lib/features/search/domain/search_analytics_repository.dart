/// Reports finished product searches for the admin's Search insights:
/// the words and how many products matched. Fire-and-forget: a failure
/// never affects the search itself.
abstract class SearchAnalyticsRepository {
  Future<void> logSearch(String term, {required int results});
}
