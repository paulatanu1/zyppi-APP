abstract class FavouritesRepository {
  Future<Set<String>> getIds();

  /// One-row writes (not "save the whole set"), so two quick taps on
  /// different products can't overwrite each other.
  Future<void> add(String productId);

  Future<void> remove(String productId);

  /// Emits when the stored ids change outside this session's own writes.
  Stream<void> watch();
}
