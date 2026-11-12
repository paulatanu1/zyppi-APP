import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// Soft section card shared by checkout, account settings and order
/// details: borderless with a soft shadow in light; a faint edge in dark,
/// where shadows don't show.
class SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;

  const SectionCard({super.key, this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final z = context.z;

    // A Material (not a decorated box) so ListTiles / switches inside get
    // their ink splashes, clipped to the rounded corners.
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: ZRadius.all(ZRadius.card),
        boxShadow: dark ? null : z.elevation,
      ),
      child: Material(
        color: z.surface,
        shape: RoundedRectangleBorder(
          borderRadius: ZRadius.all(ZRadius.card),
          side: dark ? BorderSide(color: z.line) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ZSpace.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(title!, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: ZSpace.x3),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// A selectable option tile: brandSoft fill + brand border when selected.
class SelectableTile extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  const SelectableTile({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final z = context.z;

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? z.brandSoft : z.surface,
        shape: RoundedRectangleBorder(
          borderRadius: ZRadius.all(ZRadius.tile),
          side: BorderSide(
            color: selected ? z.brand : z.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(ZSpace.x4),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Swaps a section's skeleton for its content with a short fade, or
/// instantly when the user has asked for reduced motion.
class ContentFade extends StatelessWidget {
  final Widget child;

  const ContentFade({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : ZMotion.ui,
      child: child,
    );
  }
}
