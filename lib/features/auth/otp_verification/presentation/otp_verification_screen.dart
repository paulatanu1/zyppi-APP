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
      backgroundColor: z.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  ZSpace.x5,
                  ZSpace.x2,
                  ZSpace.x5,
                  ZSpace.x5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: z.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: ZRadius.all(ZRadius.input),
                        side: BorderSide(color: z.line),
                      ),
                      child: IconButton(
                        tooltip: 'back'.tr(),
                        onPressed: () => context.canPop()
                            ? context.pop()
                            : context.go('/loginScreen'),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: z.ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: ZSpace.x6),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: z.brandSoft,
                        borderRadius: ZRadius.all(ZRadius.card),
                      ),
                      child: Icon(
                        Icons.phone_iphone_rounded,
                        size: 30,
                        color: z.brandText,
                      ),
                    ),
                    const SizedBox(height: ZSpace.x5),
                    Text('phoneVerification'.tr(), style: text.headlineMedium),
                    const SizedBox(height: ZSpace.x2),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'sentTo'.tr(args: [widget.phoneNumber]),
                          style: text.bodyLarge,
                        ),
                        TextButton(
                          onPressed: () => context.canPop()
                              ? context.pop()
                              : context.go('/loginScreen'),
                          child: Text('edit'.tr()),
                        ),
                      ],
                    ),
                    const SizedBox(height: ZSpace.x4),
                    _CodeBoxes(
                      controller: _controller,
                      length: _codeLength,
                      onChanged: (code) {
                        setState(() {});
                        ref.read(otpProvider.notifier).setOtp(code);
                        if (code.length == _codeLength) _submit();
                      },
                      onSubmitted: _submit,
                    ),
                    const SizedBox(height: ZSpace.x4),
                    if (_secondsLeft > 0)
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 18, color: z.ink3),
                          const SizedBox(width: ZSpace.x2),
                          Flexible(
                            child: Text(
                              'resendIn'.tr(args: ['$_secondsLeft']),
                              style: text.bodyMedium!.copyWith(color: z.ink2),
                            ),
                          ),
                        ],
                      )
                    else
                      TextButton.icon(
                        onPressed: _resending ? null : _resend,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text('resendCode'.tr()),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ZSpace.x5,
                0,
                ZSpace.x5,
                ZSpace.x4,
              ),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, ZSize.button),
                ),
                onPressed: canSubmit && !state.otpLoading ? _submit : null,
                child: state.otpLoading
                    ? SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: z.onBrand,
                        ),
                      )
                    : Text('verifyAndContinue'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Six digit boxes (03-otp.png) drawn over one invisible text field, so
/// typing, deleting, paste and SMS autofill (oneTimeCode) behave like a
/// normal field. Filled boxes are tinted; the next box is highlighted.
class _CodeBoxes extends StatefulWidget {
  const _CodeBoxes({
    required this.controller,
    required this.length,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  @override
  State<_CodeBoxes> createState() => _CodeBoxesState();
}

class _CodeBoxesState extends State<_CodeBoxes> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final code = widget.controller.text;
    final boxHeight = MediaQuery.textScalerOf(context).scale(56);

    return SizedBox(
      height: boxHeight,
      child: Stack(
        children: [
          Row(
            children: [
              for (var i = 0; i < widget.length; i++) ...[
                if (i > 0) const SizedBox(width: ZSpace.x2),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i < code.length ? z.brandSoft : z.surface,
                      borderRadius: ZRadius.all(ZRadius.input),
                      border: Border.all(
                        color:
                            i < code.length ||
                                (_focus.hasFocus && i == code.length)
                            ? z.brandText
                            : z.line2,
                        width: 1.5,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        i < code.length ? code[i] : '',
                        style: t.headlineSmall,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          // The real field: invisible, on top, so taps focus it.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                autofocus: true,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                maxLength: widget.length,
                showCursor: false,
                enableInteractiveSelection: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
                onChanged: widget.onChanged,
                onSubmitted: (_) => widget.onSubmitted(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
