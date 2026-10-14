import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/features/auth/otp_verification/domain/otp_auth_repository.dart';

/// Phase 3: Supabase Auth phone OTP (dev flavor uses Supabase's test
/// phone numbers, configured in the dashboard, instead of real SMS).
class SupabaseOtpAuthRepository implements OtpAuthRepository {
  final SupabaseClient client;

  SupabaseOtpAuthRepository(this.client);

  @override
  Future<void> sendOtp(String phoneNumber) {
    return client.auth.signInWithOtp(phone: phoneNumber);
  }

  @override
  Future<String?> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final response = await client.auth.verifyOTP(
      type: OtpType.sms,
      phone: phoneNumber,
      token: otp,
    );

    return response.session?.accessToken;
  }
}

final otpAuthRepositoryProvider = Provider<OtpAuthRepository>(
  (ref) => SupabaseOtpAuthRepository(Supabase.instance.client),
);
