import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/constants/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/data/provider/profile_provider.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/theme_mode_provider.dart';
import 'package:zippy/core/utils/snack_bar.dart';

/// docs/mockups/Profile.dc.html.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final name = profileAsync.value?.fullName?.trim();
    final displayName = (name == null || name.isEmpty) ? 'Zyppi user' : name;
    final phone = profileAsync.value?.phone ?? '';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'Z';

    return Scaffold(
      backgroundColor: context.colors.backgroundAlt,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: context.colors.surface,
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: context.colors.primary,
                      child: Text(
                        initial,
                        style: AppTypography.headlineSmall.copyWith(
                          color: context.colors.surface,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName, style: AppTypography.titleLarge),
                          if (phone.isNotEmpty)
                            Text(
                              phone,
                              style: AppTypography.bodySmall.copyWith(
                                color: context.colors.muted,
                              ),
                            ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pushNamed('EditProfileScreen'),
                      child: Text('editProfile'.tr()),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.receipt_long_outlined,
                            label: 'yourOrder'.tr(),
                            onTap: () => context.pushNamed('YourOrderScreen'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.favorite_border,
                            label: 'favourite'.tr(),
                            onTap: () => context.go('/navBar?index=3'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.help_outline,
                            label: 'help'.tr(),
                            onTap: () =>
                                showSuccessToast(message: 'comingSoon'.tr()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _AppearanceCard(),
                    const SizedBox(height: AppSpacing.lg),
                    _Group(
                      items: [
                        _GroupItem(
                          icon: Icons.location_on_outlined,
                          label: 'addressBook'.tr(),
                          onTap: () => context.pushNamed('MyAddressScreen'),
                        ),
                        _GroupItem(
                          icon: Icons.credit_card_outlined,
                          label: 'paymentSettings'.tr(),
                          onTap: () =>
                              showSuccessToast(message: 'comingSoon'.tr()),
                        ),
                        _GroupItem(
                          icon: Icons.notifications_none,
                          label: 'notificationPref'.tr(),
                          onTap: () =>
                              showSuccessToast(message: 'comingSoon'.tr()),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _Group(
                      items: [
                        _GroupItem(
                          icon: Icons.description_outlined,
                          label: 'accountPrivacy'.tr(),
                          onTap: () =>
                              showSuccessToast(message: 'comingSoon'.tr()),
                        ),
                        _GroupItem(
                          icon: Icons.logout,
                          label: 'logOut'.tr(),
                          color: context.colors.danger,
                          onTap: () async {
                            await ref
                                .read(sharedPreferenceProvider.notifier)
                                .logOut();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Center(
                      child: Text(
                        'appVersion'.tr(args: [Constants.appVersion]),
                        style: AppTypography.bodySmall.copyWith(
                          color: context.colors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          children: [
            Icon(icon, color: context.colors.primary),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  _GroupItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
}

class _Group extends StatelessWidget {
  final List<_GroupItem> items;

  const _Group({required this.items});

  @override
  Widget build(BuildContext context) {
    // A Material (not a coloured box) so the ListTiles' ink splashes paint
    // on it and are clipped to the rounded corners.
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];

          return Column(
            children: [
              ListTile(
                onTap: item.onTap,
                leading: Icon(
                  item.icon,
                  color: item.color ?? context.colors.ink,
                ),
                title: Text(
                  item.label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: item.color ?? context.colors.ink,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: context.colors.muted,
                ),
              ),
              if (index != items.length - 1)
                Divider(height: 1, color: context.colors.divider),
            ],
          );
        }),
      ),
    );
  }
}

class _AppearanceCard extends ConsumerWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('appearance'.tr(), style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.base),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: context.colors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: Row(
              children: [
                _AppearanceOption(
                  label: 'light'.tr(),
                  icon: Icons.light_mode_outlined,
                  selected: mode == ThemeMode.light,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(ThemeMode.light),
                ),
                _AppearanceOption(
                  label: 'dark'.tr(),
                  icon: Icons.dark_mode_outlined,
                  selected: mode == ThemeMode.dark,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(ThemeMode.dark),
                ),
                _AppearanceOption(
                  label: 'system'.tr(),
                  icon: Icons.settings_suggest_outlined,
                  selected: mode == ThemeMode.system,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(ThemeMode.system),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _AppearanceOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.stepper),
        child: Container(
          height: AppSizes.stepper,
          decoration: BoxDecoration(
            color: selected ? context.colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.stepper),
            boxShadow: selected
                ? [BoxShadow(color: context.colors.shadow, blurRadius: 4)]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? context.colors.ink : context.colors.muted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.label.copyWith(
                  color: selected ? context.colors.ink : context.colors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
