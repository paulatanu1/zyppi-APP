import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';

/// Bridges Riverpod's [sharedPreferenceProvider] auth state to go_router's
/// `refreshListenable`, so navigation reacts to auth changes via the
/// router's own `redirect` instead of a `ref.listen` + `context.goNamed`
/// call in the root widget.
class GoRouterRefreshListenable extends ChangeNotifier {
  GoRouterRefreshListenable(ProviderContainer container) {
    container.listen(sharedPreferenceProvider, (_, _) => notifyListeners());
  }
}
