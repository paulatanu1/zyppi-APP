import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/connectivity/connectivity_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// App-wide strip under the status bar: "You're offline — showing saved
/// items" while there's no network, then "Back online" for a moment.
/// Wraps the whole navigator (MaterialApp.builder). While the strip shows
/// it owns the status-bar inset, so the screen below drops its top
/// padding instead of leaving a gap.
class OfflineBannerHost extends ConsumerStatefulWidget {
  const OfflineBannerHost({super.key, required this.child});

  final Widget child;

  /// How long "Back online" stays before the strip collapses.
  static const Duration backOnlineHold = Duration(seconds: 2);

  @override
  ConsumerState<OfflineBannerHost> createState() => _OfflineBannerHostState();
}

enum _Banner { hidden, offline, backOnline }

class _OfflineBannerHostState extends ConsumerState<OfflineBannerHost> {
  _Banner _banner = _Banner.hidden;
  Timer? _hide;

  @override
  void initState() {
    super.initState();
    ref.listenManual(isOnlineProvider, (_, next) {
      final online = next.value;
      if (online != null) _onChange(online);
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _hide?.cancel();
    super.dispose();
  }

  void _onChange(bool online) {
    _hide?.cancel();
    if (!online) {
      setState(() => _banner = _Banner.offline);
    } else if (_banner == _Banner.offline) {
      setState(() => _banner = _Banner.backOnline);
      _hide = Timer(OfflineBannerHost.backOnlineHold, () {
        if (mounted) setState(() => _banner = _Banner.hidden);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final media = MediaQuery.of(context);
    final shown = _banner != _Banner.hidden;
    final offline = _banner == _Banner.offline;
    final motion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : ZMotion.ui;
    final background = offline ? z.ink : z.ok;
    // Readable on both strips in both themes.
    final foreground = offline ? z.bg : z.onBrand;

    final strip = AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark && offline
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: Semantics(
        liveRegion: true,
        child: Material(
          color: background,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              ZSpace.screen,
              media.padding.top + ZSpace.x1 + 2,
              ZSpace.screen,
              ZSpace.x2,
            ),
            child: Row(
              children: [
                Icon(
                  offline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                  size: 16,
                  color: foreground,
                ),
                const SizedBox(width: ZSpace.x2),
                Expanded(
                  child: Text(
                    offline ? 'offlineBanner'.tr() : 'backOnline'.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.labelMedium!.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Column(
      children: [
        AnimatedSize(
          duration: motion,
          curve: ZMotion.emphasized,
          alignment: Alignment.topCenter,
          child: shown
              ? KeyedSubtree(
                  key: const ValueKey('offline-banner'),
                  child: strip,
                )
              : const SizedBox(width: double.infinity),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: shown,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
