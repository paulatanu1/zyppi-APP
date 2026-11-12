import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// Centred empty state: an icon in a soft brand circle, a title, an
/// optional hint and an optional action button.
class ZEmptyState extends StatelessWidget {
  const ZEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ZSpace.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: z.brandSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: z.brandText),
            ),
            const SizedBox(height: ZSpace.x5),
            Text(title, textAlign: TextAlign.center, style: t.titleLarge),
            if (message != null) ...[
              const SizedBox(height: ZSpace.x2),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: t.bodyMedium!.copyWith(color: z.ink2),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: ZSpace.x6),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(200, ZSize.button),
                ),
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
