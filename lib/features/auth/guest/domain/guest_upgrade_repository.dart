/// Turns the signed-in guest (anonymous) account into a permanent one,
/// keeping the same user — so their orders, addresses, cart and
/// favourites stay with them.
abstract class GuestUpgradeRepository {
  /// Texts a code to [phone] (E.164, e.g. "+9198…") to attach it.
  Future<void> sendPhoneCode(String phone);

  /// Confirms [code]; the account is permanent afterwards.
  Future<void> verifyPhoneCode({required String phone, required String code});

  /// Attaches the user's Google account. Returns false if they closed the
  /// Google picker.
  Future<bool> linkGoogle();
}

/// The phone number or Google account already belongs to another Zyppi
/// account, so it can't be attached to this guest.
class AccountAlreadyExists implements Exception {
  const AccountAlreadyExists();
}
