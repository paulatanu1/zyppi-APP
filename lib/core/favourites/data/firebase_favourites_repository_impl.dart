import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zippy/core/favourites/domain/favourites_repository.dart';

/// `users/{uid}/favourites/{productId}`.
class FirebaseFavouritesRepository implements FavouritesRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  FirebaseFavouritesRepository(this.auth, this.firestore);

  CollectionReference<Map<String, dynamic>> get _favourites {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('Not signed in');
    return firestore.collection('users').doc(uid).collection('favourites');
  }

  @override
  Future<Set<String>> getIds() async {
    final snap = await _favourites.get();
    return snap.docs.map((doc) => doc.id).toSet();
  }

  @override
  Future<void> add(String productId) => _favourites.doc(productId).set({
    'createdAt': FieldValue.serverTimestamp(),
  });

  @override
  Future<void> remove(String productId) => _favourites.doc(productId).delete();

  // Only this session writes favourites; the notifier updates its own state.
  @override
  Stream<void> watch() => const Stream.empty();
}
