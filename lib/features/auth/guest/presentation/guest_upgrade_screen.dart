import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/google_sign_in_button.dart';
import 'package:zippy/core/data/profile_repository_impl.dart';
import 'package:zippy/core/data/provider/profile_provider.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/phone.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/auth/guest/data/guest_upgrade_repository_impl.dart';
import 'package:zippy/features/auth/guest/domain/guest_upgrade_repository.dart';
import 'package:zippy/features/auth/widgets/auth_widgets.dart';

/// "Save your account": links Google or an email to the current guest,
/// keeping their orders, addresses and favourites. Then asks for the
/// mobile number if the account has none (it's needed to order).
class GuestUpgradeScreen extends ConsumerStatefulWidget {
  const GuestUpgradeScreen({super.key});

  @override
  ConsumerState<GuestUpgradeScreen> createState() => _GuestUpgradeScreenState();
}

class _GuestUpgradeScreenState extends ConsumerState<GuestUpgradeScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _emailForm = false, _busy = false;
  String? _emailError, _passwordError;

  GuestUpgradeRepository get _repo => ref.read(guestUpgradeRepositoryProvider);

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Runs [action], showing progress; maps the "already has an account"
  /// case to its own prompt.
  Future<bool> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      return true;
    } on AccountAlreadyExists {
      if (mounted) await _offerSignIn();
      return false;
    } catch (error) {
      showError(error);
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _linkGoogle() async {
    var linked = false;
    await _run(() async => linked = await _repo.linkGoogle());
    if (linked && mounted) await _done();
  }

  Future<void> _linkEmail() async {
    setState(() {
      _emailError = isValidEmail(_email.text) ? null : 'invalidEmail'.tr();
      _passwordError = _password.text.length < minPasswordLength
          ? 'passwordTooShort'.tr()
          : null;
    });
    if (_emailError != null || _passwordError != null) return;
    FocusScope.of(context).unfocus();
    if (await _run(
          () => _repo.linkEmail(email: _email.text, password: _password.text),
        ) &&
        mounted) {
      await _done();
    }
  }

  Future<void> _done() async {
    final profile = await ref.read(profileRepositoryProvider).fetchProfile();
    if (!mounted) return;
    ref.invalidate(profileProvider); // isGuest → false
    // Ordering needs a number the rider can call.
    if ((profile.phone ?? '').isEmpty) await context.push('/addPhone');
    if (!mounted) return;
    showSuccessToast(message: 'accountSaved'.tr());
    context.pop();
  }

  /// The email/Google account already has its own Zyppi account. The
  /// guest's data can't be merged into it, so be clear before switching.
  Future<void> _offerSignIn() async {
    final switchAccount = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('accountExistsTitle'.tr()),
        content: Text('accountExistsBody'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('signInInstead'.tr()),
          ),
        ],
      ),
    );
    if (switchAccount == true) {
      // Back to the login screen to sign in to that account.
      await ref.read(sharedPreferenceProvider.notifier).logOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: z.bg,
      appBar: AppBar(title: Text('saveAccount'.tr())),
      body: SafeArea(
        child: AutofillGroup(
          child: ListView(
            padding: const EdgeInsets.all(ZSpace.x5),
            children: [
              Container(
                padding: const EdgeInsets.all(ZSpace.x3),
                decoration: BoxDecoration(
                  color: z.warnSoft,
                  borderRadius: ZRadius.all(ZRadius.input),
                ),
                child: Text(
                  'guestHint'.tr(),
                  style: text.bodyMedium?.copyWith(
                    color: z.warn,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: ZSpace.x5),
              Text('saveAccountTitle'.tr(), style: text.headlineSmall),
              const SizedBox(height: ZSpace.x2),
              Text(
                'saveAccountBody'.tr(),
                style: text.bodyMedium?.copyWith(color: z.ink2),
              ),
              const SizedBox(height: ZSpace.x5),
              GoogleSignInButton(action: _busy ? () {} : _linkGoogle),
              const SizedBox(height: ZSpace.x3),
              if (!_emailForm)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, ZSize.button),
                  ),
                  onPressed: _busy
                      ? null
                      : () => setState(() => _emailForm = true),
                  icon: const Icon(Icons.mail_outline_rounded),
                  label: Text('useEmailInstead'.tr()),
                )
              else ...[
                AuthField(
                  label: 'emailAddress'.tr(),
                  controller: _email,
                  error: _emailError,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: ZSpace.x3),
                PasswordField(
                  controller: _password,
                  newPassword: true,
                  error: _passwordError,
                  onSubmitted: (_) => _linkEmail(),
                  trailingLabel: Text(
                    'passwordRule'.tr(),
                    style: text.labelSmall!.copyWith(color: z.ink3),
                  ),
                ),
                const SizedBox(height: ZSpace.x4),
                BusyButton(
                  label: 'saveAccount'.tr(),
                  busy: _busy,
                  onPressed: _linkEmail,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
