import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// A v2 text field (zyppi.css `.field`): the theme's rounded 1.5 px input,
/// a floating label, a clear button and an inline error.
class TextInputFieldContainer extends StatelessWidget {
  final String inputFieldName;
  final TextEditingController controller;
  final bool enabled;

  /// Opens a picker instead of the keyboard (e.g. date of birth).
  final VoidCallback? onTap;

  /// Shown under the field (validation).
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const TextInputFieldContainer({
    super.key,
    required this.inputFieldName,
    required this.controller,
    this.enabled = true,
    this.onTap,
    this.errorText,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final text = Theme.of(context).textTheme;
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: ZRadius.all(ZRadius.input),
      borderSide: BorderSide(color: color, width: 1.5),
    );

    return TextField(
      controller: controller,
      enabled: enabled,
      readOnly: onTap != null,
      onTap: onTap,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: text.bodyLarge!.copyWith(color: enabled ? z.ink : z.ink2),
      decoration: InputDecoration(
        // A label, not a hint: it stays visible once the field has text.
        labelText: inputFieldName,
        labelStyle: text.bodyLarge!.copyWith(color: z.ink2),
        errorText: errorText,
        errorStyle: text.bodySmall!.copyWith(color: z.danger),
        fillColor: enabled ? z.surface : z.surface2,
        disabledBorder: border(z.line),
        errorBorder: border(z.danger),
        focusedErrorBorder: border(z.danger),
        suffixIcon: enabled
            ? IconButton(
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                icon: Icon(Icons.clear_rounded, color: z.ink3),
                onPressed: () {
                  controller.clear();
                  onChanged?.call('');
                },
              )
            : null,
      ),
    );
  }
}
