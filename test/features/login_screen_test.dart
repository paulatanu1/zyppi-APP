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

class _Otp implements OtpAuthRepository {
  final sent = <String>[];

  @override
  Future<void> sendOtp(String phoneNumber) async => sent.add(phoneNumber);

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
  late _Otp otp;

  Future<void> pump(WidgetTester tester) async {
    otp = _Otp();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          otpAuthRepositoryProvider.overrideWithValue(otp),
          googleAuthRepositoryProvider.overrideWithValue(_Google()),
          guestAuthRepositoryProvider.overrideWithValue(_Guest()),
        ],
        child: MaterialApp(theme: ZyppiTheme.light, home: const LoginScreen()),
      ),
    );
  }

  testWidgets('rejects an invalid number without sending an OTP', (
    tester,
  ) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField), '12345');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('invalidPhone'), findsOneWidget); // translation key
    expect(otp.sent, isEmpty);
  });

  testWidgets('only digits are accepted, at most 10', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField), '+91 98765-432109');
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, '9198765432');
  });

  testWidgets('the typed number survives the rebuild after Continue', (
    tester,
  ) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField), '9876543210');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(otp.sent, ['+919876543210']);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, '9876543210');
  });
}
