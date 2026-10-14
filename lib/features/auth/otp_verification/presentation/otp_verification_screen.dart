import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/auth/otp_verification/application/login_provider.dart';
import 'package:zippy/features/auth/otp_verification/application/otp_provider.dart';

/// docs/mockups/Otp.dc.html.
class OtpVerificationScreen extends ConsumerWidget {
  final String? phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpVerification = ref.watch(otpProvider);
    final login = ref.watch(loginProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'phoneVerification'.tr(),
                  style: AppTypography.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'sentTo'.tr(args: [phoneNumber ?? '']),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text('edit'.tr()),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                OtpTextField(
                  numberOfFields: 6,
                  fieldWidth: MediaQuery.of(context).size.width * 0.11,
                  margin: const EdgeInsets.all(4),
                  focusedBorderColor: AppColors.primary,
                  enabledBorderColor: AppColors.line,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  borderWidth: 1.5,
                  showFieldAsBox: true,
                  onCodeChanged: (String code) {},
                  onSubmit: (String verificationCode) {
                    ref.read(otpProvider.notifier).setOtp(verificationCode);
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'resendCode'.tr(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.giant),
                login.loading == true
                    ? const Center(child: CircularProgressIndicator())
                    : PrimaryButton(
                        buttonTitle: 'submit'.tr(),
                        action: () => ref
                            .read(loginProvider.notifier)
                            .login(
                              phoneNumber: phoneNumber,
                              otp: otpVerification.otp,
                              context: context,
                            ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
