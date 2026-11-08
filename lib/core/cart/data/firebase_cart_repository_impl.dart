import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zippy/core/cart/domain/cart_repository.dart';
import 'package:zippy/core/domain/cart_item.dart';

/// Server copy of the cart at `users/{uid}/cart/{variantId}` — the cart the
/// placeOrder / createPayUOrder functions price. CartNotifier pushes
/// local changes here in the background.
class FirebaseCartRepository implements CartRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  FirebaseCartRepository(this.auth, this.firestore);

  CollectionReference<Map<String, dynamic>> get _cart {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('Not signed in');
    return firestore.collection('users').doc(uid).collection('cart');
  }

  @override
  Future<List<CartItem>> getItems() async {
    final snap = await _cart.get();
    return snap.docs
        .map(
          (doc) => CartItem(
            productId: doc.data()['productId'] as String? ?? '',
            variantId: doc.id,
            quantity: doc.data()['quantity'] as int,
          ),
        )
        .toList();
  }

  @override
  Future<void> setQuantity(CartItem item) {
    final doc = _cart.doc(item.variantId);
    if (item.quantity <= 0) return doc.delete();

    return doc.set({
      'productId': item.productId,
      'quantity': item.quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
