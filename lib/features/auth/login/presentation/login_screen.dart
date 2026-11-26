import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/google_sign_in_button.dart';
import 'package:zippy/core/legal/application/legal_providers.dart';
import 'package:zippy/core/legal/presentation/legal_consent_notice.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/core/utils/phone.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/auth/email/data/email_auth_repository_impl.dart';
import 'package:zippy/features/auth/email/domain/email_auth_repository.dart';
import 'package:zippy/features/auth/google_sign_in/application/google_provider.dart';
import 'package:zippy/features/auth/guest/application/guest_provider.dart';
import 'package:zippy/features/auth/session/auth_session.dart';
import 'package:zippy/features/auth/widgets/auth_widgets.dart';

/// "Log in or sign up": Google first, then email and password, then
/// guest browsing. There is no phone-number sign-in; the number is
/// collected at sign-up (or right after a first Google sign-in).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError, _passwordError, _formError;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Continuing past this screen accepts the terms, privacy and refund
  /// policy (the notice under the buttons says so). The legal gate
  /// records the acceptance right after sign-in.
  void _consent() => ref.read(legalAgreedAtLoginProvider.notifier).set(true);

  void _next(SignInResult? result) {
    if (result == SignInResult.needsPhone && mounted) {
      context.push('/addPhone');
    }
    // signedIn: the router's redirect goes to Home.
  }

  Future<void> _logIn() async {
    final email = _email.text.trim();
    setState(() {
      _emailError = isValidEmail(email) ? null : 'invalidEmail'.tr();
      _passwordError = _password.text.isEmpty ? 'passwordRequired'.tr() : null;
      _formError = null;
    });
    if (_emailError != null || _passwordError != null) return;
    _consent();
    FocusScope.of(context).unfocus();

    final session = ref.read(authSessionProvider);
    setState(() => _busy = true);
    try {
      final uid = await ref
          .read(emailAuthRepositoryProvider)
          .signIn(email: email, password: _password.text);
      _next(await session.complete(uid));
    } on EmailAuthFailure catch (e) {
      if (mounted) setState(() => _formError = e.messageKey.tr());
    } catch (e) {
      showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google() async {
    _consent();
    _next(await ref.read(googleProvider.notifier).signIn());
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final googleLoading = ref.watch(googleProvider).loading == true;
    final guestLoading = ref.watch(guestProvider);

    return Scaffold(
      backgroundColor: z.bg,
      body: AutofillGroup(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  ZSpace.x5,
                  ZSpace.x5,
                  ZSpace.x5,
                  ZSpace.x6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('logInOrSignUp'.tr(), style: t.headlineMedium),
                    const SizedBox(height: ZSpace.x1),
                    Text(
                      'loginSubtitle'.tr(),
                      style: t.bodyLarge!.copyWith(color: z.ink2),
                    ),
                    const SizedBox(height: ZSpace.x5),
                    if (googleLoading)
                      const SizedBox(
                        height: ZSize.button,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      GoogleSignInButton(action: _google),
                    const SizedBox(height: ZSpace.x4),
                    _OrDivider(label: 'orWithEmail'.tr()),
                    const SizedBox(height: ZSpace.x4),
                    AuthField(
                      fieldKey: const ValueKey('login-email'),
                      label: 'emailAddress'.tr(),
                      controller: _email,
                      hint: 'name@gmail.com',
                      error: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: ZSpace.x3),
                    PasswordField(
                      controller: _password,
                      error: _passwordError,
                      onSubmitted: (_) => _logIn(),
                      trailingLabel: AuthLink(
                        label: 'forgotPasswordLink'.tr(),
                        onTap: () => context.push(
                          Uri(
                            path: '/forgotPassword',
                            queryParameters: {
                              if (_email.text.trim().isNotEmpty)
                                'email': _email.text.trim(),
                            },
                          ).toString(),
                        ),
                      ),
                    ),
                    if (_formError != null) ...[
                      const SizedBox(height: ZSpace.x2),
                      Text(
                        _formError!,
                        style: t.bodySmall!.copyWith(color: z.danger),
                      ),
                    ],
                    const SizedBox(height: ZSpace.x4),
                    BusyButton(
                      label: 'logIn'.tr(),
                      busy: _busy,
                      onPressed: _logIn,
                    ),
                    const SizedBox(height: ZSpace.x2),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'newToZyppi'.tr(),
                          style: t.bodyMedium!.copyWith(color: z.ink2),
                        ),
                        AuthLink(
                          label: 'createAccount'.tr(),
                          onTap: () => context.push('/register'),
                        ),
                      ],
                    ),
                    Center(
                      child: guestLoading
                          ? const CircularProgressIndicator()
                          : TextButton(
                              onPressed: () {
                                _consent();
                                ref.read(guestProvider.notifier).signIn();
                              },
                              child: Text('continueAsGuest'.tr()),
                            ),
                    ),
                    const SizedBox(height: ZSpace.x3),
                    const LegalConsentNotice(),
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

/// Pink band with the Zyppi tile and the delivery promise, rounded at
/// the bottom (approved mockup, "Log in").
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, this.height = 150});

  final double height;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final top = MediaQuery.paddingOf(context).top;
    final canPop = Navigator.of(context).canPop();

    const radius = BorderRadius.vertical(
      bottom: Radius.circular(ZRadius.sheet),
    );
    // Floating Cards: the shared header band (brand sheen; Dark B glow).
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: z.headerShadow,
      ),
      child: ZHeaderFill(
        offsetY: 0,
        borderRadius: radius,
        child: Container(
          height: top + height,
          padding: EdgeInsets.only(top: top),
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  padding: const EdgeInsets.all(ZSpace.x3),
                  decoration: BoxDecoration(
                    color: z.surface,
                    borderRadius: ZRadius.all(ZRadius.card + 4),
                    boxShadow: [
                      BoxShadow(
                        color: z.shadow,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/brand/zyppi_mark.png',
                    excludeFromSemantics: true,
                  ),
                ),
              ),
              Positioned(
                left: canPop ? null : ZSpace.screen,
                right: canPop ? ZSpace.screen : null,
                top: ZSpace.x3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ZSpace.x3,
                    vertical: ZSpace.x1 + 2,
                  ),
                  decoration: BoxDecoration(
                    color: z.headerInk.withValues(alpha: .18),
                    borderRadius: ZRadius.all(ZRadius.chip),
                  ),
                  child: Text(
                    '⚡ ${'deliveryPromise'.tr()}',
                    style: t.labelSmall!.copyWith(
                      color: z.headerInk,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              if (canPop)
                Positioned(
                  left: ZSpace.x2,
                  top: 0,
                  child: IconButton(
                    tooltip: 'back'.tr(),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: z.headerInk,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Row(
      children: [
        Expanded(child: Divider(color: z.line2)),
        // Flexible: at large text sizes the label wraps instead of
        // pushing the row wider than the screen.
        Flexible(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ZSpace.x3),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium!
                  .copyWith(color: z.ink3),
            ),
          ),
        ),
        Expanded(child: Divider(color: z.line2)),
      ],
    );
  }
}
