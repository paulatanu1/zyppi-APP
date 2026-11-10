import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/nav_bar/provider/nav_bar_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/features/account/presentation/account_screen.dart';
import 'package:zippy/features/explore/presentation/explore_screen.dart';
import 'package:zippy/features/favourite/presentation/favourite_screen.dart';
import 'package:zippy/features/home_screen/presentation/home_screen.dart';
import 'package:zippy/features/my_cart/presentation/my_cart_screen.dart';

/// Home · Explore · Cart · Favourite · Account, in [ZNavBar] order.
const _tabCount = 5;

class NavBar extends ConsumerStatefulWidget {
  /// Tab to show when opened via `/navBar?index=`.
  final int initialIndex;

  const NavBar({super.key, this.initialIndex = 0});

  @override
  ConsumerState<NavBar> createState() => _NavBarState();
}

class _NavBarState extends ConsumerState<NavBar>
    with SingleTickerProviderStateMixin {
  /// Tabs are built the first time they're shown, then kept alive by the
  /// [IndexedStack] — so launch doesn't build all five screens at once.
  final _visited = <int>{};

  /// Short fade + rise of the tab being switched to.
  late final AnimationController _switch = AnimationController(
    vsync: this,
    duration: ZMotion.ui,
    value: 1,
  );
  late final Animation<double> _switchCurve = CurvedAnimation(
    parent: _switch,
    curve: ZMotion.standard,
  );

  late final Animation<Offset> _switchSlide = Tween(
    begin: const Offset(0, .015),
    end: Offset.zero,
  ).animate(_switchCurve);

  @override
  void initState() {
    super.initState();
    _applyIndex();
  }

  @override
  void dispose() {
    _switch.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) _applyIndex();
  }

  void _applyIndex() {
    final index = widget.initialIndex.clamp(0, _tabCount - 1);
    // After this frame: providers can't be modified during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(navBarProvider.notifier).updateIndex(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navBarProvider);
    final changeIndex = ref.read(navBarProvider.notifier);
    ref.listen(navBarProvider, (previous, next) {
      if (previous != next && !MediaQuery.disableAnimationsOf(context)) {
        _switch.forward(from: 0);
      }
    });
    // Only the badge number: a whole-cart watch rebuilt the nav bar (and
    // re-diffed every tab) on each +/- anywhere in the app.
    final cartCount = ref.watch(
      cartProvider.select(
        (cart) => cart.loading
            ? 0
            : cart.lines.fold<int>(0, (sum, l) => sum + l.quantity),
      ),
    );
    _visited.add(currentIndex);

    Widget screen(int i) => switch (i) {
      0 => const HomeScreen(),
      1 => const ExploreScreen(),
      2 => const MyCartScreen(),
      3 => const FavouriteScreen(),
      _ => const AccountScreen(),
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: [
            for (var i = 0; i < _tabCount; i++)
              // Hidden tabs stay mounted but stop animating: IndexedStack
              // keeps their tickers running, so the Home header pulse,
              // banner autoplay and skeleton shimmers otherwise kept
              // drawing frames behind whichever tab was open.
              TickerMode(
                enabled: i == currentIndex,
                // Same wrappers for every tab, visible or not, so switching
                // never remounts a screen (and loses its scroll/state).
                child: FadeTransition(
                  opacity: i == currentIndex
                      ? _switchCurve
                      : kAlwaysCompleteAnimation,
                  child: SlideTransition(
                    position: i == currentIndex
                        ? _switchSlide
                        : const AlwaysStoppedAnimation(Offset.zero),
                    child: _visited.contains(i)
                        ? screen(i)
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: ZNavBar(
          index: currentIndex,
          cartCount: cartCount,
          onTap: changeIndex.updateIndex,
        ),
      ),
    );
  }
}
