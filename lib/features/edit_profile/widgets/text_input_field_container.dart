import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.input),
            color: enabled ? context.colors.surface : context.colors.surfaceAlt,
            border: Border.all(
              color: errorText != null
                  ? context.colors.danger
                  : context.colors.line,
            ),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            readOnly: onTap != null,
            onTap: onTap,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: AppTypography.bodyLarge.copyWith(color: context.colors.ink),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.lg,
                horizontal: AppSpacing.base,
              ),
              suffixIcon: enabled
                  ? IconButton(
                      icon: Icon(Icons.clear, color: context.colors.muted),
                      onPressed: controller.clear,
                    )
                  : null,
              // A label, not a hint: it stays visible once the field has text.
              labelText: inputFieldName,
              labelStyle: AppTypography.bodyLarge.copyWith(
                color: context.colors.muted,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.base,
              top: AppSpacing.xs,
            ),
            child: Text(
              errorText!,
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.danger,
              ),
            ),
          ),
      ],
    );
  }
}
