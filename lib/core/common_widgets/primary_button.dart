import 'package:flutter/material.dart';

/// Full-width brand button. Styled entirely by the theme's
/// `filledButtonTheme` (zyppi.css `.btn`: 54 px, radius 16, 800 16 px).
class PrimaryButton extends StatelessWidget {
  final String buttonTitle;
  final VoidCallback action;

  const PrimaryButton({
    super.key,
    required this.buttonTitle,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(onPressed: action, child: Text(buttonTitle)),
    );
  }
}
