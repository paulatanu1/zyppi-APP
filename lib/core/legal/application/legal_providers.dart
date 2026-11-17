import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/legal/data/legal_repository_impl.dart';
import 'package:zippy/core/legal/domain/legal_doc.dart';

/// What the signed-in customer still has to accept. Not retried on
/// failure: the gate lets the customer in and checks again next start.
final legalPendingProvider = FutureProvider.autoDispose<List<PendingLegalDoc>>(
  (ref) => ref.watch(legalRepositoryProvider).pending(),
  retry: (_, _) => null,
);

/// One document's live text, by (type, language code).
final legalDocTextProvider = FutureProvider.autoDispose
    .family<LegalDocText?, ({String type, String lang})>(
      (ref, key) =>
          ref.watch(legalRepositoryProvider).fetchText(key.type, key.lang),
    );

/// The customer ticked "I agree" on the login screen in this session.
/// The legal gate then records the acceptance right after sign-in
/// instead of asking again.
class LegalAgreedAtLogin extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final legalAgreedAtLoginProvider = NotifierProvider<LegalAgreedAtLogin, bool>(
  LegalAgreedAtLogin.new,
);

/// The app's language as the server's body key (`en`, `bn`, `hi`, `pa`).
String legalLang(String languageCode) =>
    const {'bn', 'hi', 'pa'}.contains(languageCode) ? languageCode : 'en';
