/// Turns the signed-in guest (anonymous) account into a permanent one,
/// keeping the same user — so their orders, addresses, cart and
/// favourites stay with them.
abstract class GuestUpgradeRepository {
  /// Attaches an email and password; the account is permanent afterwards.
  Future<void> linkEmail({required String email, required String password});

  /// Attaches the user's Google account. Returns false if they closed the
  /// Google picker.
  Future<bool> linkGoogle();
}

/// The email or Google account already belongs to another Zyppi
/// account, so it can't be attached to this guest.
class AccountAlreadyExists implements Exception {
  const AccountAlreadyExists();
}
