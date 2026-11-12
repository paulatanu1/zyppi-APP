import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/nav_bar/provider/nav_bar_provider.dart';
import 'package:zippy/core/widgets/z_back_to_exit.dart';
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

class _NavBarState extends ConsumerState<NavBar> {
  @override
  void initState() {
    super.initState();
    _applyIndex();
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
    final cart = ref.watch(cartProvider);
    final cartCount = cart.loading
        ? 0
        : cart.lines.fold<int>(0, (sum, l) => sum + l.quantity);

    final screens = [
      const HomeScreen(),
      const ExploreScreen(),
      const MyCartScreen(),
      const FavouriteScreen(),
      const AccountScreen(),
    ];

    // Back goes to Home first; on Home it takes two presses to exit.
    return ZBackToExit(
      atHome: currentIndex == 0,
      onGoHome: () => changeIndex.updateIndex(0),
      child: Scaffold(
        body: IndexedStack(index: currentIndex, children: screens),
        bottomNavigationBar: ZNavBar(
          index: currentIndex,
          cartCount: cartCount,
          onTap: changeIndex.updateIndex,
        ),
      ),
    );
  }
}
