import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zippy/core/utils/phone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/common_widgets/google_sign_in_button.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/auth/google_sign_in/application/google_provider.dart';
import 'package:zippy/features/auth/guest/application/guest_provider.dart';
import 'package:zippy/features/auth/otp_verification/application/otp_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

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
                color: context.z.brandSoft,
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 72,
                  color: context.z.brand,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(ZSpace.x4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'logInOrSignUp'.tr(),
                      style: AppTypography.headlineSmall,
                    ),
                    const SizedBox(height: ZSpace.x2),
                    Text(
                      'otpSentDescription'.tr(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.z.ink2,
                      ),
                    ),
                    const SizedBox(height: ZSpace.x4),
                    Text(
                      'mobileNumber'.tr(),
                      style: AppTypography.bodySmall.copyWith(
                        color: context.z.ink2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: ZSpace.x2),
                    Container(
                      height: ZSize.input,
                      padding: const EdgeInsets.symmetric(
                        horizontal: ZSpace.x3,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _phoneError != null
                              ? context.z.danger
                              : context.z.brand,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(ZRadius.input),
                      ),
                      child: Row(
                        children: [
                          Text('+91', style: AppTypography.bodyLarge),
                          const SizedBox(width: ZSpace.x3),
                          Container(
                            width: 1,
                            height: 24,
                            color: context.z.line,
                          ),
                          const SizedBox(width: ZSpace.x3),
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
                      const SizedBox(height: ZSpace.x2),
                      Text(
                        _phoneError!,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.z.danger,
                        ),
                      ),
                    ],
                    const SizedBox(height: ZSpace.x4),
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
                    const SizedBox(height: ZSpace.x4),
                    Center(
                      child: Text(
                        'continueWith'.tr(),
                        style: AppTypography.bodySmall.copyWith(
                          color: context.z.ink2,
                        ),
                      ),
                    ),
                    const SizedBox(height: ZSpace.x3),
                    Center(
                      child: googleToken.loading == true
                          ? const CircularProgressIndicator()
                          : GoogleSignInButton(
                              action: () => ref
                                  .read(googleProvider.notifier)
                                  .generateGoogleToken(context),
                            ),
                    ),
                    const SizedBox(height: ZSpace.x2),
                    Center(
                      child: guestLoading
                          ? const CircularProgressIndicator()
                          : TextButton(
                              onPressed: () =>
                                  ref.read(guestProvider.notifier).signIn(),
                              child: Text('continueAsGuest'.tr()),
                            ),
                    ),
                    const SizedBox(height: ZSpace.x4),
                    Text(
                      'termsAndPrivacy'.tr(),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.z.ink2,
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
