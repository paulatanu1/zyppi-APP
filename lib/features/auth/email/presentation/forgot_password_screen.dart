import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/phone.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/auth/email/data/email_auth_repository_impl.dart';
import 'package:zippy/features/auth/email/domain/email_auth_repository.dart';
import 'package:zippy/features/auth/widgets/auth_widgets.dart';

/// "Reset password": sends Firebase's reset email.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late final _email = TextEditingController(text: widget.initialEmail);
  String? _error;
  bool _busy = false, _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!isValidEmail(_email.text)) {
      setState(() => _error = 'invalidEmail'.tr());
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      await ref
          .read(emailAuthRepositoryProvider)
          .sendPasswordReset(_email.text);
      if (mounted) setState(() => _sent = true);
    } on EmailAuthFailure catch (e) {
      if (mounted) setState(() => _error = e.messageKey.tr());
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
      appBar: AppBar(title: Text('resetPasswordTitle'.tr())),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          ZSpace.x5,
          ZSpace.x2,
          ZSpace.x5,
          ZSpace.x6,
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: z.brandSoft,
                borderRadius: ZRadius.all(ZRadius.control + 5),
              ),
              child: Icon(Icons.mail_outline_rounded, color: z.brandText),
            ),
          ),
          const SizedBox(height: ZSpace.x4),
          Text('forgotTitle'.tr(), style: t.headlineSmall),
          const SizedBox(height: ZSpace.x1),
          Text('forgotBody'.tr(), style: t.bodyLarge!.copyWith(color: z.ink2)),
          const SizedBox(height: ZSpace.x5),
          AuthField(
            label: 'emailAddress'.tr(),
            controller: _email,
            error: _error,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.send,
            autofillHints: const [AutofillHints.email],
            onSubmitted: (_) => _send(),
          ),
          const SizedBox(height: ZSpace.x4),
          BusyButton(
            label: 'sendResetLink'.tr(),
            busy: _busy,
            onPressed: _send,
          ),
          if (_sent) ...[
            const SizedBox(height: ZSpace.x4),
            Container(
              padding: const EdgeInsets.all(ZSpace.x3),
              decoration: BoxDecoration(
                color: z.okSoft,
                borderRadius: ZRadius.all(ZRadius.input),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: z.ok, size: 20),
                  const SizedBox(width: ZSpace.x2),
                  Expanded(
                    child: Text(
                      'resetLinkSent'.tr(),
                      style: t.bodyMedium!.copyWith(
                        color: z.ok,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: ZSpace.x5),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'rememberedIt'.tr(),
                style: t.bodyMedium!.copyWith(color: z.ink2),
              ),
              AuthLink(label: 'logIn'.tr(), onTap: () => context.pop()),
            ],
          ),
        ],
      ),
    );
  }
}
