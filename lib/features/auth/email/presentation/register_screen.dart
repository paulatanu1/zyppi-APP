import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/profile_repository_impl.dart';
import 'package:zippy/core/legal/application/legal_providers.dart';
import 'package:zippy/core/legal/presentation/legal_consent_row.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/phone.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/auth/email/data/email_auth_repository_impl.dart';
import 'package:zippy/features/auth/email/domain/email_auth_repository.dart';
import 'package:zippy/features/auth/session/auth_session.dart';
import 'package:zippy/features/auth/widgets/auth_widgets.dart';

/// "Create account": name, email, mobile number (required, no OTP) and a
/// password. The number is saved on the profile before the person counts
/// as signed in.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  String? _nameError, _emailError, _phoneError, _passwordError, _formError;
  bool _agreed = false, _triedWithoutAgreeing = false, _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final phone = toIndianE164(_phone.text);
    setState(() {
      _nameError = _name.text.trim().isEmpty ? 'nameRequired'.tr() : null;
      _emailError = isValidEmail(_email.text) ? null : 'invalidEmail'.tr();
      _phoneError = phone == null ? 'invalidPhone'.tr() : null;
      _passwordError = _password.text.length < minPasswordLength
          ? 'passwordTooShort'.tr()
          : null;
      _formError = null;
      if (!_agreed) _triedWithoutAgreeing = true;
    });
    if (_nameError != null ||
        _emailError != null ||
        _phoneError != null ||
        _passwordError != null ||
        !_agreed) {
      return;
    }
    FocusScope.of(context).unfocus();

    final session = ref.read(authSessionProvider);
    final profiles = ref.read(profileRepositoryProvider);
    setState(() => _busy = true);
    try {
      final uid = await ref
          .read(emailAuthRepositoryProvider)
          .signUp(
            email: _email.text,
            password: _password.text,
            fullName: _name.text,
          );
      await profiles.savePhone(phone!, fullName: _name.text);
      // The router's redirect goes to Home.
      await session.markSignedIn(uid);
    } on EmailAuthFailure catch (e) {
      if (mounted) setState(() => _formError = e.messageKey.tr());
    } catch (e) {
      showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: z.bg,
      appBar: AppBar(title: Text('createAccount'.tr())),
      body: AutofillGroup(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            ZSpace.x5,
            ZSpace.x2,
            ZSpace.x5,
            ZSpace.x6,
          ),
          children: [
            Text(
              'registerSubtitle'.tr(),
              style: t.bodyLarge!.copyWith(color: z.ink2),
            ),
            const SizedBox(height: ZSpace.x5),
            AuthField(
              label: 'fullName'.tr(),
              required: true,
              controller: _name,
              error: _nameError,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
            ),
            const SizedBox(height: ZSpace.x3),
            AuthField(
              label: 'emailAddress'.tr(),
              required: true,
              controller: _email,
              hint: 'name@gmail.com',
              error: _emailError,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: ZSpace.x3),
            PhoneField(
              controller: _phone,
              error: _phoneError,
              helper: 'phoneLockedNote'.tr(),
            ),
            const SizedBox(height: ZSpace.x3),
            PasswordField(
              controller: _password,
              required: true,
              newPassword: true,
              error: _passwordError,
              onSubmitted: (_) => _create(),
              trailingLabel: Text(
                'passwordRule'.tr(),
                style: t.labelSmall!.copyWith(color: z.ink3),
              ),
            ),
            const SizedBox(height: ZSpace.x3),
            LegalConsentRow(
              value: _agreed,
              showError: _triedWithoutAgreeing,
              onChanged: (v) {
                setState(() => _agreed = v);
                ref.read(legalAgreedAtLoginProvider.notifier).set(v);
              },
            ),
            if (_formError != null) ...[
              const SizedBox(height: ZSpace.x2),
              Text(_formError!, style: t.bodySmall!.copyWith(color: z.danger)),
            ],
            const SizedBox(height: ZSpace.x4),
            BusyButton(
              label: 'createAccount'.tr(),
              busy: _busy,
              onPressed: _create,
            ),
          ],
        ),
      ),
    );
  }
}
