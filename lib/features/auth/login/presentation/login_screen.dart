import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zippy/core/utils/phone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/common_widgets/google_sign_in_button.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/auth/google_sign_in/application/google_provider.dart';
import 'package:zippy/features/auth/guest/application/guest_provider.dart';
import 'package:zippy/features/auth/otp_verification/application/otp_provider.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

/// docs/mockups/Login.dc.html.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Lives across rebuilds (e.g. the loading state), so the typed number
  // isn't wiped when Continue is tapped.
  final _phoneController = TextEditingController();
  String? _phoneError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    final digits = _phoneController.text.trim();
    if (!isValidIndianMobile(digits)) {
      setState(() => _phoneError = 'invalidPhone'.tr());
      return;
    }
    setState(() => _phoneError = null);
    FocusScope.of(context).unfocus();
    ref.read(otpProvider.notifier).generateOtp('+91$digits', context);
  }

  @override
  Widget build(BuildContext context) {
    final googleToken = ref.watch(googleProvider);
    final otpState = ref.watch(otpProvider);
    final guestLoading = ref.watch(guestProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 220,
                color: context.colors.primaryTint,
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 72,
                  color: context.colors.primary,
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
                        color: context.colors.muted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'mobileNumber'.tr(),
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.muted,
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
                          color: _phoneError != null
                              ? context.colors.danger
                              : context.colors.primary,
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
                            color: context.colors.line,
                          ),
                          const SizedBox(width: AppSpacing.base),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              autofillHints: const [
                                AutofillHints.telephoneNumberNational,
                              ],
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              onChanged: (_) {
                                if (_phoneError != null) {
                                  setState(() => _phoneError = null);
                                }
                              },
                              onSubmitted: (_) => _continue(),
                              style: AppTypography.bodyLarge,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_phoneError != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _phoneError!,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.colors.danger,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                    FilledButton(
                      onPressed: otpState.loading ? null : _continue,
                      child: otpState.loading
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text('continueLabel'.tr()),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Center(
                      child: Text(
                        'continueWith'.tr(),
                        style: AppTypography.bodySmall.copyWith(
                          color: context.colors.muted,
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
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: guestLoading
                          ? const CircularProgressIndicator()
                          : TextButton(
                              onPressed: () =>
                                  ref.read(guestProvider.notifier).signIn(),
                              child: Text('continueAsGuest'.tr()),
                            ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'termsAndPrivacy'.tr(),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.muted,
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
