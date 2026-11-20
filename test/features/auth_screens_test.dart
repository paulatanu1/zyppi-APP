import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/auth/add_phone/presentation/add_phone_screen.dart';
import 'package:zippy/features/auth/email/presentation/forgot_password_screen.dart';
import 'package:zippy/features/auth/email/presentation/register_screen.dart';
import 'package:zippy/features/auth/google_sign_in/data/google_auth_repository_impl.dart';
import 'package:zippy/features/auth/google_sign_in/domain/google_auth_repository.dart';
import 'package:zippy/features/auth/guest/data/guest_auth_repository_impl.dart';
import 'package:zippy/features/auth/guest/domain/guest_auth_repository.dart';
import 'package:zippy/features/auth/login/presentation/login_screen.dart';
import 'package:zippy/features/auth/session/auth_session.dart';

import '../helpers/localized_app.dart';

class _Google implements GoogleAuthRepository {
  @override
  Future<String?> signIn() async => null;
}

class _Guest implements GuestAuthRepository {
  @override
  Future<String?> signIn() async => null;
}

void main() {
  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        googleAuthRepositoryProvider.overrideWithValue(_Google()),
        guestAuthRepositoryProvider.overrideWithValue(_Guest()),
        currentAccountProvider.overrideWithValue((
          uid: 'uid-1',
          name: 'Riya Sen',
          email: 'riya.sen@gmail.com',
        )),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  final screens = <String, (Widget, String)>{
    'Login': (const LoginScreen(), 'Log in or sign up'),
    'Create account': (const RegisterScreen(), 'Mobile number'),
    'Reset password': (const ForgotPasswordScreen(), 'Send reset link'),
    'Add mobile number': (const AddPhoneScreen(), 'One last step'),
  };

  for (final MapEntry(key: name, value: (screen, text)) in screens.entries) {
    group(name, () {
      for (final dark in [false, true]) {
        for (final scale in [1.0, 2.0]) {
          testWidgets(
            'no overflow (${dark ? 'dark' : 'light'}, $scale× text)',
            (tester) async {
              await pumpLocalizedApp(
                tester,
                container: container(),
                home: screen,
                theme: dark ? ZyppiTheme.dark : ZyppiTheme.light,
                textScale: scale,
              );
              expect(find.textContaining(text), findsWidgets);
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    });
  }

  testWidgets('Add mobile number rejects a short number', (tester) async {
    await pumpLocalizedApp(
      tester,
      container: container(),
      home: const AddPhoneScreen(),
    );
    await tester.enterText(find.byType(TextField), '98765');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Enter a valid 10-digit mobile number'), findsOneWidget);
  });
}
