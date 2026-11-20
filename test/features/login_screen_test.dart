import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/auth/email/data/email_auth_repository_impl.dart';
import 'package:zippy/features/auth/email/domain/email_auth_repository.dart';
import 'package:zippy/features/auth/google_sign_in/data/google_auth_repository_impl.dart';
import 'package:zippy/features/auth/google_sign_in/domain/google_auth_repository.dart';
import 'package:zippy/features/auth/guest/data/guest_auth_repository_impl.dart';
import 'package:zippy/features/auth/guest/domain/guest_auth_repository.dart';
import 'package:zippy/features/auth/login/presentation/login_screen.dart';
import 'package:zippy/features/auth/session/auth_session.dart';

class _Email implements EmailAuthRepository {
  final signIns = <String>[];
  EmailAuthFailure? failWith;

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    signIns.add(email);
    if (failWith != null) throw failWith!;
    return 'uid-1';
  }

  @override
  Future<String> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async => 'uid-1';

  @override
  Future<void> sendPasswordReset(String email) async {}
}

class _Google implements GoogleAuthRepository {
  @override
  Future<String?> signIn() async => null;
}

class _Guest implements GuestAuthRepository {
  @override
  Future<String?> signIn() async => null;
}

/// Records completions; answers with [result] instead of reading a profile.
class _Session extends AuthSession {
  _Session(super.ref, this.result);

  final SignInResult result;
  final completed = <String>[];

  @override
  Future<SignInResult> complete(String uid) async {
    completed.add(uid);
    return result;
  }
}

void main() {
  late _Email email;
  late _Session session;

  Future<void> pump(
    WidgetTester tester, {
    SignInResult result = SignInResult.signedIn,
  }) async {
    email = _Email();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const LoginScreen()),
        GoRoute(path: '/addPhone', builder: (_, _) => const Text('add-phone')),
        GoRoute(path: '/register', builder: (_, _) => const Text('register')),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          emailAuthRepositoryProvider.overrideWithValue(email),
          googleAuthRepositoryProvider.overrideWithValue(_Google()),
          guestAuthRepositoryProvider.overrideWithValue(_Guest()),
          authSessionProvider.overrideWith(
            (ref) => session = _Session(ref, result),
          ),
        ],
        child: MaterialApp.router(
          theme: ZyppiTheme.light,
          routerConfig: router,
        ),
      ),
    );
  }

  Finder field(String key) => find.descendant(
    of: find.byKey(ValueKey(key)),
    matching: find.byType(EditableText),
  );

  Future<void> fill(
    WidgetTester tester, {
    String mail = 'riya@gmail.com',
  }) async {
    await tester.enterText(field('login-email'), mail);
    await tester.enterText(find.byType(TextField).at(1), 'secret123');
  }

  Future<void> tapLogIn(WidgetTester tester) async {
    await tester.ensureVisible(find.text('logIn'));
    await tester.tap(find.text('logIn'));
    await tester.pump();
  }

  testWidgets('has no phone-number sign-in', (tester) async {
    await pump(tester);
    expect(find.text('mobileNumber'), findsNothing);
    expect(find.byType(TextField), findsNWidgets(2)); // email + password
  });

  testWidgets('rejects an invalid email without signing in', (tester) async {
    await pump(tester);
    await fill(tester, mail: 'riya@');
    await tester.tap(find.byType(Checkbox));
    await tapLogIn(tester);

    expect(find.text('invalidEmail'), findsOneWidget); // translation key
    expect(email.signIns, isEmpty);
  });

  testWidgets('needs the terms ticked before signing in', (tester) async {
    await pump(tester);
    await fill(tester);
    await tapLogIn(tester);

    expect(email.signIns, isEmpty);
    expect(find.text('legalAgreeRequired'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tapLogIn(tester);
    await tester.pumpAndSettle();
    expect(email.signIns, ['riya@gmail.com']);
    expect(session.completed, ['uid-1']);
  });

  testWidgets('a wrong password shows a readable message', (tester) async {
    await pump(tester);
    email.failWith = const EmailAuthFailure('authWrongCredentials');
    await fill(tester);
    await tester.tap(find.byType(Checkbox));
    await tapLogIn(tester);
    await tester.pumpAndSettle();

    expect(find.text('authWrongCredentials'), findsOneWidget);
  });

  testWidgets('an account without a number goes to "Add mobile number"', (
    tester,
  ) async {
    await pump(tester, result: SignInResult.needsPhone);
    await fill(tester);
    await tester.tap(find.byType(Checkbox));
    await tapLogIn(tester);
    await tester.pumpAndSettle();

    expect(find.text('add-phone'), findsOneWidget);
  });

  testWidgets('guest sign-in also needs the terms ticked', (tester) async {
    await pump(tester);

    await tester.ensureVisible(find.text('continueAsGuest'));
    await tester.tap(find.text('continueAsGuest'));
    await tester.pump();

    expect(find.text('legalAgreeRequired'), findsOneWidget);
  });

  testWidgets('shows a link to each customer document', (tester) async {
    await pump(tester);

    expect(find.text('legalTerms'), findsOneWidget);
    expect(find.text('legalPrivacy'), findsOneWidget);
    expect(find.text('legalRefund'), findsOneWidget);
  });
}
