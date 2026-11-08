import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zippy/core/utils/phone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/common_widgets/google_sign_in_button.dart';
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
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final googleToken = ref.watch(googleProvider);
    final otpState = ref.watch(otpProvider);
    final guestLoading = ref.watch(guestProvider);
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: z.bg,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pink hero with the phone illustration (02-login.png).
            Container(
              height: top + 300,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: z.brandSoft,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(ZRadius.sheet),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: -80,
                    top: -60,
                    child: _Blob(size: 240, color: z.brandSoft2),
                  ),
                  Positioned(
                    right: -50,
                    top: top + 40,
                    child: _Blob(size: 130, color: z.blueSoft),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Image.asset(
                      'assets/images/Splash-4.png',
                      height: 260,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ),
                  if (Navigator.of(context).canPop())
                    Positioned(
                      left: ZSpace.screen,
                      top: top + ZSpace.x2,
                      child: Material(
                        color: z.surface,
                        borderRadius: ZRadius.all(ZRadius.input),
                        child: IconButton(
                          tooltip: 'back'.tr(),
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: z.ink,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ZSpace.x5,
                ZSpace.x6,
                ZSpace.x5,
                ZSpace.x6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('logInOrSignUp'.tr(), style: t.headlineMedium),
                  const SizedBox(height: ZSpace.x2),
                  Text('otpSentDescription'.tr(), style: t.bodyLarge),
                  const SizedBox(height: ZSpace.x5),
                  Text(
                    'mobileNumber'.tr(),
                    style: t.labelMedium!.copyWith(color: z.ink2),
                  ),
                  const SizedBox(height: ZSpace.x2),
                  Container(
                    constraints: const BoxConstraints(minHeight: ZSize.input),
                    padding: const EdgeInsets.symmetric(horizontal: ZSpace.x4),
                    decoration: BoxDecoration(
                      color: z.surface,
                      border: Border.all(
                        color: _phoneError != null ? z.danger : z.brandText,
                        width: 1.5,
                      ),
                      borderRadius: ZRadius.all(ZRadius.input),
                    ),
                    child: Row(
                      children: [
                        Text('🇮🇳 +91', style: t.titleMedium),
                        const SizedBox(width: ZSpace.x3),
                        Container(width: 1, height: 24, color: z.line),
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
                            style: t.titleMedium,
                            decoration: InputDecoration(
                              hintText: 'mobileNumber'.tr(),
                              filled: false,
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
                      style: t.bodySmall!.copyWith(color: z.danger),
                    ),
                  ],
                  const SizedBox(height: ZSpace.x4),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, ZSize.button),
                    ),
                    onPressed: otpState.loading ? null : _continue,
                    child: otpState.loading
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Text('continueLabel'.tr()),
                  ),
                  const SizedBox(height: ZSpace.x5),
                  Row(
                    children: [
                      Expanded(child: Divider(color: z.line)),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ZSpace.x3,
                        ),
                        child: Text(
                          'orDivider'.tr(),
                          style: t.labelMedium!.copyWith(color: z.ink3),
                        ),
                      ),
                      Expanded(child: Divider(color: z.line)),
                    ],
                  ),
                  const SizedBox(height: ZSpace.x5),
                  if (googleToken.loading == true)
                    const Center(child: CircularProgressIndicator())
                  else
                    GoogleSignInButton(
                      action: () => ref
                          .read(googleProvider.notifier)
                          .generateGoogleToken(context),
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
                  const SizedBox(height: ZSpace.x6),
                  Text(
                    'termsAndPrivacy'.tr(),
                    textAlign: TextAlign.center,
                    style: t.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft decorative circle in the hero.
class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
