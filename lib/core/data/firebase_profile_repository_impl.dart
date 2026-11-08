import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zippy/core/data/profile_repository.dart';
import 'package:zippy/core/domain/profile.dart';

/// The signed-in user's `users/{uid}` document. It's created on the first
/// write (merge), so a brand-new account simply reads as an empty profile.
class FirebaseProfileRepository implements ProfileRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  FirebaseProfileRepository(this.auth, this.firestore);

  User get _user {
    final user = auth.currentUser;
    if (user == null) throw StateError('Not signed in');
    return user;
  }

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      firestore.collection('users').doc(uid);

  @override
  Future<Profile> fetchProfile() async {
    final user = _user;
    final data = (await _doc(user.uid).get()).data() ?? const {};

    return Profile(
      id: user.uid,
      phone: data['phone'] as String? ?? user.phoneNumber,
      fullName: data['fullName'] as String? ?? user.displayName,
      email: data['email'] as String? ?? user.email,
      dob: DateTime.tryParse(data['dob'] as String? ?? ''),
      gender: data['gender'] as String?,
      preferredPaymentMethod: data['preferredPaymentMethod'] as String?,
      notifyOrderUpdates: data['notifyOrderUpdates'] as bool? ?? true,
      notifyOffers: data['notifyOffers'] as bool? ?? false,
      isGuest: user.isAnonymous,
    );
  }

  @override
  Future<void> updateProfile(Profile profile) {
    final email = profile.email?.trim() ?? '';
    final name = profile.fullName?.trim() ?? '';
    return _write(profile.id, {
      'fullName': name.isEmpty ? null : name,
      'email': email.isEmpty ? null : email,
      'dob': profile.dob?.toIso8601String().split('T').first,
      'gender': profile.gender,
      if (_user.phoneNumber != null) 'phone': _user.phoneNumber,
    });
  }

  @override
  Future<void> updatePreferences(Profile profile) => _write(profile.id, {
    'preferredPaymentMethod': profile.preferredPaymentMethod,
    'notifyOrderUpdates': profile.notifyOrderUpdates,
    'notifyOffers': profile.notifyOffers,
  });

  Future<void> _write(String id, Map<String, dynamic> values) {
    if (id != _user.uid) throw StateError('Profile not saved');
    return _doc(id).set({
      ...values,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
