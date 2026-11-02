import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/auth/otp_verification/application/otp_provider.dart';

/// docs/mockups/Otp.dc.html.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  static const _codeLength = 6;
  static const _resendAfter = 30;

  final _controller = TextEditingController();
  Timer? _timer;
  int _secondsLeft = _resendAfter;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
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

  Future<void> _resend() async {
    setState(() => _resending = true);
    final sent = await ref
        .read(otpProvider.notifier)
        .resendOtp(widget.phoneNumber);
    if (!mounted) return;
    setState(() => _resending = false);
    if (sent) {
      _controller.clear();
      _startCountdown();
    }
  }

  void _submit() {
    final code = _controller.text;
    if (code.length != _codeLength) return;
    ref.read(otpProvider.notifier).verifyOtp(widget.phoneNumber, code, context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(otpProvider);
    final z = context.z;
    final text = Theme.of(context).textTheme;
    final canSubmit = _controller.text.length == _codeLength;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ZSpace.x6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('phoneVerification'.tr(), style: text.headlineSmall),
              const SizedBox(height: ZSpace.x2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'sentTo'.tr(args: [widget.phoneNumber]),
                      style: text.bodyMedium?.copyWith(color: z.ink2),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go('/loginScreen'),
                    child: Text('edit'.tr()),
                  ),
                ],
              ),
              const SizedBox(height: ZSpace.x6),
              // One field for the whole code: reliable editing, paste and
              // SMS autofill (autofillHints), unlike per-digit boxes.
              TextField(
                controller: _controller,
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
                  ref.read(otpProvider.notifier).setOtp(code);
                  if (code.length == _codeLength) _submit();
                },
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: ZSpace.x4),
              Align(
                alignment: Alignment.centerLeft,
                child: _secondsLeft > 0
                    ? Text(
                        'resendIn'.tr(args: ['$_secondsLeft']),
                        style: text.bodyMedium?.copyWith(color: z.ink3),
                      )
                    : TextButton(
                        onPressed: _resending ? null : _resend,
                        child: Text('resendCode'.tr()),
                      ),
              ),
              const SizedBox(height: ZSpace.x8),
              FilledButton(
                onPressed: canSubmit && !state.otpLoading ? _submit : null,
                child: state.otpLoading
                    ? SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: z.onBrand,
                        ),
                      )
                    : Text('submit'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
