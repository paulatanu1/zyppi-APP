import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// A form field with its label above it (approved sign-in mockups):
/// "Email", "Password · Forgot?", "Mobile number * · Required".
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    this.required = false,
    this.trailingLabel,
    this.hint,
    this.helper,
    this.error,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.suffix,
    this.prefixText,
    this.inputFormatters,
    this.onSubmitted,
    this.onChanged,
    this.fieldKey,
    this.autofocus = false,
  });

  final String label;
  final TextEditingController controller;
  final bool required;

  /// Right side of the label row: a link ("Forgot?") or a note.
  final Widget? trailingLabel;
  final String? hint, helper, error, prefixText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText, autofocus;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted, onChanged;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: label,
                  children: [
                    if (required)
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: z.brandText),
                      ),
                  ],
                ),
                style: t.labelMedium!.copyWith(
                  color: z.ink2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ?trailingLabel,
          ],
        ),
        const SizedBox(height: ZSpace.x1 + 2),
        TextField(
          key: fieldKey,
          controller: controller,
          autofocus: autofocus,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          obscureText: obscureText,
          autocorrect: !obscureText,
          enableSuggestions: !obscureText,
          inputFormatters: inputFormatters,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          style: t.titleMedium,
          decoration: InputDecoration(
            hintText: hint,
            errorText: error,
            prefixText: prefixText,
            prefixStyle: t.titleMedium!.copyWith(fontWeight: FontWeight.w800),
            suffixIcon: suffix,
          ),
        ),
        if (helper != null && error == null) ...[
          const SizedBox(height: ZSpace.x1),
          Text(helper!, style: t.bodySmall!.copyWith(color: z.ink3)),
        ],
      ],
    );
  }
}

/// "+91 | 98765 43210": 10 digits only.
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    this.error,
    this.helper,
    this.onSubmitted,
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String? error, helper;
  final ValueChanged<String>? onSubmitted, onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return AuthField(
      label: 'mobileNumber'.tr(),
      required: true,
      trailingLabel: Text(
        'requiredLabel'.tr(),
        style: Theme.of(context).textTheme.labelSmall!.copyWith(color: z.ink3),
      ),
      controller: controller,
      prefixText: '+91  ',
      hint: '98765 43210',
      helper: helper,
      error: error,
      autofocus: autofocus,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.telephoneNumberNational],
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      onSubmitted: onSubmitted,
      onChanged: onChanged,
    );
  }
}

/// Password field with a Show / Hide toggle.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.trailingLabel,
    this.error,
    this.required = false,
    this.newPassword = false,
    this.onSubmitted,
    this.onChanged,
  });

  final TextEditingController controller;
  final Widget? trailingLabel;
  final String? error;
  final bool required;

  /// Sign-up: the system can suggest a strong password.
  final bool newPassword;
  final ValueChanged<String>? onSubmitted, onChanged;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return AuthField(
      label: 'password'.tr(),
      required: widget.required,
      trailingLabel: widget.trailingLabel,
      controller: widget.controller,
      error: widget.error,
      obscureText: !_visible,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      autofillHints: [
        widget.newPassword ? AutofillHints.newPassword : AutofillHints.password,
      ],
      onSubmitted: widget.onSubmitted,
      onChanged: widget.onChanged,
      suffix: TextButton(
        onPressed: () => setState(() => _visible = !_visible),
        child: Text(
          _visible ? 'hidePassword'.tr() : 'showPassword'.tr(),
          style: Theme.of(context).textTheme.labelMedium!
              .copyWith(color: context.z.ink3, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

/// Full-width primary button that shows a spinner while [busy].
class BusyButton extends StatelessWidget {
  const BusyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(minimumSize: const Size(0, ZSize.button)),
      onPressed: busy ? null : onPressed,
      child: busy
          ? const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Text(label),
    );
  }
}

/// Small brand link inside running text ("Log in", "Forgot?").
class AuthLink extends StatelessWidget {
  const AuthLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: ZRadius.all(ZRadius.badge),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: ZSize.touch),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: ZSpace.x1),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: context.z.brandText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Rider calls this number · Only for your deliveries".
class AuthReassurance extends StatelessWidget {
  const AuthReassurance({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title, body;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ZSpace.x2),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: z.brandSoft,
              borderRadius: ZRadius.all(ZRadius.control),
            ),
            child: Icon(icon, size: 18, color: z.brandText),
          ),
          const SizedBox(width: ZSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.labelLarge),
                Text(body, style: t.bodySmall!.copyWith(color: z.ink3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
