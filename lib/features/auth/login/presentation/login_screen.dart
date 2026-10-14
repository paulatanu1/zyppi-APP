import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/google_sign_in_button.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/auth/google_sign_in/application/google_provider.dart';

/// docs/mockups/Login.dc.html.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController phoneController = TextEditingController();
    final googleToken = ref.watch(googleProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 220,
                color: AppColors.primaryTint,
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 72,
                  color: AppColors.primary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'logInOrSignUp'.tr(),
                      style: AppTypography.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'otpSentDescription'.tr(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'mobileNumber'.tr(),
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      height: AppSizes.inputMax,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.input),
                      ),
                      child: Row(
                        children: [
                          Text('+91', style: AppTypography.bodyLarge),
                          const SizedBox(width: AppSpacing.base),
                          Container(
                            width: 1,
                            height: 24,
                            color: AppColors.line,
                          ),
                          const SizedBox(width: AppSpacing.base),
                          Expanded(
                            child: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              style: AppTypography.bodyLarge,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    PrimaryButton(
                      buttonTitle: 'continueLabel'.tr(),
                      action: () {
                        context.goNamed(
                          'OtpVerificationScreen',
                          queryParameters: {
                            'phoneNumber': phoneController.text,
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Center(
                      child: Text(
                        'continueWith'.tr(),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Center(
                      child: googleToken.loading == true
                          ? const CircularProgressIndicator()
                          : GoogleSignInButton(
                              action: () => ref
                                  .read(googleProvider.notifier)
                                  .generateGoogleToken(context),
                            ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'termsAndPrivacy'.tr(),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
