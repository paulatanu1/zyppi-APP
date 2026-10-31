import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

class TextInputFieldContainer extends StatelessWidget {
  final String inputFieldName;
  final TextEditingController controller;
  final bool enabled;

  const TextInputFieldContainer({
    super.key,
    required this.inputFieldName,
    required this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.input),
        color: enabled ? context.colors.surface : context.colors.surfaceAlt,
        border: Border.all(color: context.colors.line),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
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
          hintText: inputFieldName,
          hintStyle: AppTypography.bodyLarge.copyWith(
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
    );
  }
}
