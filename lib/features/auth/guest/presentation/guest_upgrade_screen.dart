import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/google_sign_in_button.dart';
import 'package:zippy/core/data/provider/profile_provider.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/phone.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/auth/guest/data/guest_upgrade_repository_impl.dart';
import 'package:zippy/features/auth/guest/domain/guest_upgrade_repository.dart';

/// "Save your account": attaches a phone number or Google account to the
/// current guest, keeping their orders, addresses and favourites.
class GuestUpgradeScreen extends ConsumerStatefulWidget {
  const GuestUpgradeScreen({super.key});

  @override
  ConsumerState<GuestUpgradeScreen> createState() => _GuestUpgradeScreenState();
}

class _GuestUpgradeScreenState extends ConsumerState<GuestUpgradeScreen> {
  static const _codeLength = 6;
  static const _resendAfter = 30;

  final _phone = TextEditingController();
  final _code = TextEditingController();
  String? _sentTo; // E.164 number the code went to; null = phone step
  String? _error;
  bool _busy = false;
  int _secondsLeft = 0;
  Timer? _timer;

  GuestUpgradeRepository get _repo => ref.read(guestUpgradeRepositoryProvider);

  @override
  void dispose() {
    _timer?.cancel();
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendAfter);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  /// Runs [action], showing progress; maps the "already has an account"
  /// case to its own prompt.
  Future<bool> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
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

  Future<void> _sendCode() async {
    final digits = _phone.text.trim();
    if (!isValidIndianMobile(digits)) {
      setState(() => _error = 'invalidPhone'.tr());
      return;
    }
    final phone = '+91$digits';
    if (await _run(() => _repo.sendPhoneCode(phone)) && mounted) {
      setState(() => _sentTo = phone);
      _startCountdown();
    }
  }

  Future<void> _verify() async {
    final code = _code.text;
    if (code.length != _codeLength || _sentTo == null) return;
    if (await _run(() => _repo.verifyPhoneCode(phone: _sentTo!, code: code)) &&
        mounted) {
      _done();
    }
  }

  Future<void> _linkGoogle() async {
    var linked = false;
    await _run(() async => linked = await _repo.linkGoogle());
    if (linked && mounted) _done();
  }

  void _done() {
    ref.invalidate(profileProvider); // isGuest → false
    showSuccessToast(message: 'accountSaved'.tr());
    context.pop();
  }

  /// The number/Google account already has its own Zyppi account. The
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
    final codeStep = _sentTo != null;

    return Scaffold(
      appBar: AppBar(title: Text('saveAccount'.tr())),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ZSpace.x6),
          children: [
            Text(
              codeStep ? 'phoneVerification'.tr() : 'saveAccountTitle'.tr(),
              style: text.headlineSmall,
            ),
            const SizedBox(height: ZSpace.x2),
            Text(
              codeStep ? 'sentTo'.tr(args: [_sentTo!]) : 'saveAccountBody'.tr(),
              style: text.bodyMedium?.copyWith(color: z.ink2),
            ),
            const SizedBox(height: ZSpace.x6),
            if (!codeStep) ...[
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  prefixText: '+91  ',
                  labelText: 'mobileNumber'.tr(),
                  errorText: _error,
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                onSubmitted: (_) => _sendCode(),
              ),
              const SizedBox(height: ZSpace.x4),
              FilledButton(
                onPressed: _busy ? null : _sendCode,
                child: _busy
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text('continueLabel'.tr()),
              ),
              const SizedBox(height: ZSpace.x6),
              Center(child: Text('continueWith'.tr(), style: text.bodySmall)),
              const SizedBox(height: ZSpace.x3),
              Center(
                child: GoogleSignInButton(action: _busy ? () {} : _linkGoogle),
              ),
            ] else ...[
              TextField(
                controller: _code,
                autofocus: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                autofillHints: const [AutofillHints.oneTimeCode],
                maxLength: _codeLength,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: text.headlineSmall?.copyWith(letterSpacing: 12),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '• ' * _codeLength,
                ),
                onChanged: (code) {
                  setState(() {});
                  if (code.length == _codeLength) _verify();
                },
              ),
              const SizedBox(height: ZSpace.x3),
              Row(
                children: [
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                            _sentTo = null;
                            _code.clear();
                          }),
                    child: Text('edit'.tr()),
                  ),
                  const Spacer(),
                  if (_secondsLeft > 0)
                    Text(
                      'resendIn'.tr(args: ['$_secondsLeft']),
                      style: text.bodySmall,
                    )
                  else
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () async {
                              if (await _run(
                                    () => _repo.sendPhoneCode(_sentTo!),
                                  ) &&
                                  mounted) {
                                _code.clear();
                                _startCountdown();
                              }
                            },
                      child: Text('resendCode'.tr()),
                    ),
                ],
              ),
              const SizedBox(height: ZSpace.x4),
              FilledButton(
                onPressed: _busy || _code.text.length != _codeLength
                    ? null
                    : _verify,
                child: _busy
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text('submit'.tr()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
