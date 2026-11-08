import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/auth/google_sign_in/data/google_auth_repository_impl.dart';
import 'package:zippy/features/auth/google_sign_in/domain/google_auth_repository.dart';
import 'package:zippy/features/auth/guest/data/guest_auth_repository_impl.dart';
import 'package:zippy/features/auth/guest/domain/guest_auth_repository.dart';
import 'package:zippy/features/auth/login/presentation/login_screen.dart';
import 'package:zippy/features/auth/otp_verification/data/otp_auth_repository_impl.dart';
import 'package:zippy/features/auth/otp_verification/domain/otp_auth_repository.dart';
import 'package:zippy/features/auth/otp_verification/presentation/otp_verification_screen.dart';

import '../helpers/localized_app.dart';

class _Otp implements OtpAuthRepository {
  @override
  Future<void> sendOtp(String phoneNumber) async {}
  @override
  Future<String?> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async => null;
}

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
        otpAuthRepositoryProvider.overrideWithValue(_Otp()),
        googleAuthRepositoryProvider.overrideWithValue(_Google()),
        guestAuthRepositoryProvider.overrideWithValue(_Guest()),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('OTP', () {
    Future<void> pumpOtp(
      WidgetTester tester, {
      ThemeData? theme,
      double textScale = 1,
    }) => pumpLocalizedApp(
      tester,
      container: container(),
      home: const OtpVerificationScreen(phoneNumber: '+919876543210'),
      theme: theme,
      textScale: textScale,
    );

    // The resend countdown is a periodic timer; unmount to stop it.
    Future<void> unmount(WidgetTester tester) =>
        tester.pumpWidget(const SizedBox());

    testWidgets('typed digits fill the boxes; Verify needs all six', (
      tester,
    ) async {
      await pumpOtp(tester);
      await tester.enterText(find.byType(TextField), '4827');
      await tester.pump();

      for (final d in ['4', '8', '2', '7']) {
        expect(find.text(d), findsOneWidget);
      }
      final verify = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(verify.onPressed, isNull);
      expect(find.text('Resend code in 30s'), findsOneWidget);
      await unmount(tester);
    });

    for (final dark in [false, true]) {
      testWidgets('no overflow at 2× text (${dark ? 'dark' : 'light'})', (
        tester,
      ) async {
        await pumpOtp(
          tester,
          theme: dark ? ZyppiTheme.dark : ZyppiTheme.light,
          textScale: 2,
        );
        await tester.enterText(find.byType(TextField), '48271');
        await tester.pump();
        expect(tester.takeException(), isNull);
        await unmount(tester);
      });
    }
  });

  group('Login', () {
    for (final dark in [false, true]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('no overflow (${dark ? 'dark' : 'light'}, $scale× text)', (
          tester,
        ) async {
          await pumpLocalizedApp(
            tester,
            container: container(),
            home: const LoginScreen(),
            theme: dark ? ZyppiTheme.dark : ZyppiTheme.light,
            textScale: scale,
          );
          expect(find.text('Log in or sign up'), findsOneWidget);
          expect(find.text('Sign in with Google'), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
