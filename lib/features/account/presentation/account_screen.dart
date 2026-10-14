import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';

/// docs/mockups/Profile.dc.html.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: AppColors.white,
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        'A',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Atanu', style: AppTypography.titleLarge),
                          Text(
                            '+91 98765 43210',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.muted,
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
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
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
                          onTap: () {},
                        ),
                        _GroupItem(
                          icon: Icons.notifications_none,
                          label: 'notificationPref'.tr(),
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _Group(
                      items: [
                        _GroupItem(
                          icon: Icons.description_outlined,
                          label: 'accountPrivacy'.tr(),
                          onTap: () {},
                        ),
                        _GroupItem(
                          icon: Icons.logout,
                          label: 'logOut'.tr(),
                          color: AppColors.danger,
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
                        'v1.0.0'.tr(),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.muted,
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
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: AppTypography.bodySmall),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];

          return Column(
            children: [
              ListTile(
                onTap: item.onTap,
                leading: Icon(item.icon, color: item.color ?? AppColors.ink),
                title: Text(
                  item.label,
                  style: AppTypography.bodyMedium.copyWith(color: item.color),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.muted,
                ),
              ),
              if (index != items.length - 1)
                const Divider(height: 1, color: AppColors.divider),
            ],
          );
        }),
      ),
    );
  }
}
