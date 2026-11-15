import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Back from a screen with nothing underneath it — reached by `go()`, a
/// push notification or a deep link — goes Home instead of closing the
/// app. When there is a route underneath, back pops normally (and keeps
/// Android's predictive-back animation).
///
/// This has to be a route-level [PopScope], not a back-button dispatcher:
/// targeting Android 16 turns predictive back on, and Android then exits
/// the app on its own whenever Flutter reports it can't pop.
class HomeFallbackScope extends StatelessWidget {
  const HomeFallbackScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isFirst = ModalRoute.of(context)?.isFirst ?? false;
    return PopScope(
      canPop: !isFirst,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) popOrHome(context);
      },
      child: child,
    );
  }
}

/// App-bar back: pop if there is somewhere to pop to, else go Home.
void popOrHome(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/navBar');
  }
}

/// Wraps a route builder's page in a [HomeFallbackScope].
GoRouterWidgetBuilder withHomeFallback(GoRouterWidgetBuilder builder) =>
    (context, state) => HomeFallbackScope(child: builder(context, state));
