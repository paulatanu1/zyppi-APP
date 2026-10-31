import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/common_widgets/nav_bar/provider/nav_bar_provider.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/account/presentation/account_screen.dart';
import 'package:zippy/features/explore/presentation/explore_screen.dart';
import 'package:zippy/features/favourite/presentation/favourite_screen.dart';
import 'package:zippy/features/home_screen/presentation/home_screen.dart';
import 'package:zippy/features/my_cart/presentation/my_cart_screen.dart';

const _tabs = [
  (icon: Icons.home_outlined, activeIcon: Icons.home, labelKey: 'home'),
  (
    icon: Icons.explore_outlined,
    activeIcon: Icons.explore,
    labelKey: 'explore',
  ),
  (
    icon: Icons.shopping_bag_outlined,
    activeIcon: Icons.shopping_bag,
    labelKey: 'myCart',
  ),
  (
    icon: Icons.favorite_border,
    activeIcon: Icons.favorite,
    labelKey: 'favourite',
  ),
  (icon: Icons.person_outline, activeIcon: Icons.person, labelKey: 'profile'),
];

class NavBar extends ConsumerWidget {
  final int initialIndex;

  const NavBar({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navBarProvider);
    final changeIndex = ref.read(navBarProvider.notifier);

    final screens = [
      HomeScreen(),
      ExploreScreen(),
      const MyCartScreen(),
      const FavouriteScreen(),
      const AccountScreen(),
    ];

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        body: IndexedStack(index: currentIndex, children: screens),
        bottomNavigationBar: Container(
          height: AppSizes.navBar,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final selected = currentIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => changeIndex.updateIndex(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? tab.activeIcon : tab.icon,
                        color: selected ? AppColors.primary : AppColors.muted,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tab.labelKey.tr(),
                        style: AppTypography.labelSmall.copyWith(
                          color: selected ? AppColors.primary : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
