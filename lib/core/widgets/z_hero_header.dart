import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_brand_texture.dart';

/// The textured purple header of the main tabs and key moments (Explore,
/// Favourite, Cart, OTP, …): status bar included, white title and
/// subtitle, an optional glass back button and actions, an optional
/// [bottom] (e.g. a search bar), and a curved bottom edge.
///
/// The back button shows when the route can pop (like an AppBar's), unless
/// [showBack] says otherwise; [onBack] overrides what it does.
class ZHeroHeader extends StatelessWidget {
  const ZHeroHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.bottom,
    this.showBack,
    this.onBack,
  });

  final String title;
  final Widget? subtitle;

  /// Shown above the title (e.g. an icon in a glass circle).
  final Widget? leading;
  final List<Widget> actions;
  final Widget? bottom;
  final bool? showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final back = showBack ?? Navigator.of(context).canPop();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: ZBrandTexture(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(ZRadius.hero),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            ZSpace.screen,
            MediaQuery.paddingOf(context).top + ZSpace.x3,
            ZSpace.screen,
            ZSpace.x6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (back) ...[
                    ZGlassIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      tooltip: 'back'.tr(),
                      onPressed:
                          onBack ?? () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: ZSpace.x3),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (leading != null) ...[
                          leading!,
                          const SizedBox(height: ZSpace.x3),
                        ],
                        Text(
                          title,
                          style: t.headlineSmall!.copyWith(color: z.headerInk),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: ZSpace.x1),
                          DefaultTextStyle.merge(
                            style: t.bodyMedium!.copyWith(color: z.headerInk2),
                            child: subtitle!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  ...actions,
                ],
              ),
              if (bottom != null) ...[
                const SizedBox(height: ZSpace.x4),
                bottom!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A round translucent button for brand surfaces (back, actions).
class ZGlassIconButton extends StatelessWidget {
  const ZGlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Material(
      color: z.onBrand.withValues(alpha: .16),
      shape: CircleBorder(
        side: BorderSide(color: z.onBrand.withValues(alpha: .22)),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        constraints: const BoxConstraints.tightFor(
          width: ZSize.touch,
          height: ZSize.touch,
        ),
        icon: Icon(icon, size: 20, color: z.onBrand),
      ),
    );
  }
}

/// An icon in a translucent circle, for the top of a brand hero.
class ZGlassBadge extends StatelessWidget {
  const ZGlassBadge({super.key, required this.icon, this.size = 56});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: z.onBrand.withValues(alpha: .16),
        shape: BoxShape.circle,
        border: Border.all(color: z.onBrand.withValues(alpha: .22)),
      ),
      child: Icon(icon, size: size * .5, color: z.onBrand),
    );
  }
}

/// For a screen whose purple header scrolls away: keeps the status-bar
/// icons light and fades a textured strip in behind them once content
/// scrolls under the status bar. Wrap the screen's scroll view.
class ZStatusBarScrim extends StatefulWidget {
  const ZStatusBarScrim({super.key, required this.child});

  final Widget child;

  @override
  State<ZStatusBarScrim> createState() => _ZStatusBarScrimState();
}

class _ZStatusBarScrimState extends State<ZStatusBarScrim> {
  final _opacity = ValueNotifier<double>(0);

  @override
  void dispose() {
    _opacity.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth == 0 && n.metrics.axis == Axis.vertical) {
      _opacity.value = (n.metrics.pixels / ZSpace.x6).clamp(0.0, 1.0);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: widget.child,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.paddingOf(context).top,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            ),
            child: ValueListenableBuilder<double>(
              valueListenable: _opacity,
              builder: (context, o, child) => o == 0
                  ? const SizedBox.expand()
                  : Opacity(opacity: o, child: child),
              child: const ZBrandTexture(),
            ),
          ),
        ),
      ],
    );
  }
}
