import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

class TextformField extends StatefulWidget {
  final TextEditingController textFormFieldController;
  final String labelText;
  final bool? prefixIcon;
  final double? borderRadius;
  final bool? isNumber;
  final void Function(String)? onChanged;

  const TextformField({
    super.key,
    required this.textFormFieldController,
    required this.labelText,
    this.prefixIcon,
    this.borderRadius,
    this.isNumber,
    this.onChanged,
  });

  @override
  State<TextformField> createState() => _TextformFieldState();
}

class _TextformFieldState extends State<TextformField> {
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.textFormFieldController.addListener(_onTextChanged);
    _focusNode.addListener(
      () => setState(() => _isFocused = _focusNode.hasFocus),
    );
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    widget.textFormFieldController.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.inputMin,
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(
          color: _isFocused
              ? context.colors.primaryText
              : context.colors.lineAlt,
          width: _isFocused ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? AppRadius.input,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: context.colors.primaryTint,
                  blurRadius: 0,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: TextField(
        focusNode: _focusNode,
        textAlignVertical: TextAlignVertical.center,
        controller: widget.textFormFieldController,
        onChanged: widget.onChanged,
        keyboardType: widget.isNumber == true
            ? TextInputType.number
            : TextInputType.text,
        decoration: InputDecoration(
          hintText: widget.labelText,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: context.colors.muted,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          isCollapsed: true,
          prefixIcon: widget.prefixIcon == null || widget.prefixIcon == false
              ? null
              : const Icon(Icons.search),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: AppSizes.inputMin,
            minHeight: AppSizes.inputMin - 4,
          ),
          suffixIcon: widget.textFormFieldController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () => widget.textFormFieldController.clear(),
                  icon: const Icon(Icons.cancel),
                ),
        ),
      ),
    );
  }
}
