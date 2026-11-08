import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/push/data/push_token_repository_impl.dart';
import 'package:zippy/core/push/push_notification_service.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/auth/guest/data/guest_auth_repository_impl.dart';
import 'package:zippy/features/auth/guest/domain/guest_auth_repository.dart';

/// State is just "loading"; same flow as google_provider.dart.
class GuestLogin extends StateNotifier<bool> {
  final GuestAuthRepository repository;
  final Ref ref;

  GuestLogin(this.repository, this.ref) : super(false);

  Future<void> signIn() async {
    state = true;

    try {
      final accessToken = await repository.signIn();

      state = false;

      if (accessToken == null) {
        showConnectionInterrupted();
        return;
      }

      // Read before logging in: the redirect that follows disposes this
      // provider, and its ref with it.
      final pushTokens = ref.read(pushTokenRepositoryProvider);
      await ref
          .read(sharedPreferenceProvider.notifier)
          .setLocalStorage(authToken: accessToken);
      PushNotificationService.registerTokenAfterLogin(pushTokens);
      // The router's redirect (watching sharedPreferenceProvider) takes
      // it from here — no manual navigation needed.
    } catch (error) {
      if (!mounted) return;
      state = false;

      showError(error);
    }
  }
}

final guestProvider = StateNotifierProvider.autoDispose<GuestLogin, bool>(
  (ref) => GuestLogin(ref.read(guestAuthRepositoryProvider), ref),
);
