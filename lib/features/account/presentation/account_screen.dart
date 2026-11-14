import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/push/data/push_token_repository_impl.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/constants/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/nav_bar/provider/nav_bar_provider.dart';
import 'package:zippy/core/data/provider/profile_provider.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/theme/theme_mode_provider.dart';
import 'package:zippy/core/common_widgets/help_sheet.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/account/widgets/language_sheet.dart';

/// docs/mockups/Profile.dc.html.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.value;
    final isGuest = profile?.isGuest ?? false;
    final name = profile?.fullName?.trim();
    final displayName = isGuest
        ? 'guestUser'.tr()
        : (name == null || name.isEmpty)
        ? 'zyppiUser'.tr()
        : name;
    final phone = profile?.phone ?? '';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'Z';

    final z = context.z;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: z.bg,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Magenta header; the quick-action card below overlaps
                  // its bottom edge (the translate leaves that space at the
                  // end of the scroll).
                  Container(
                    color: z.header,
                    padding: const EdgeInsets.fromLTRB(
                      ZSpace.screen,
                      ZSpace.x4,
                      ZSpace.screen,
                      ZSpace.x8 + ZSpace.x6,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: z.onBrand.withValues(alpha: .16),
                          child: Text(
                            initial,
                            style: t.headlineSmall!.copyWith(color: z.onBrand),
                          ),
                        ),
                        const SizedBox(width: ZSpace.x3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (profileAsync.isLoading && profile == null)
                                const ZSkeleton(
                                  width: 140,
                                  height: 18,
                                  radius: ZRadius.badge,
                                )
                              else
                                Text(
                                  displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.headlineSmall!.copyWith(
                                    color: z.headerInk,
                                  ),
                                ),
                              if (profileAsync.hasError && profile == null)
                                GestureDetector(
                                  onTap: () => ref.invalidate(profileProvider),
                                  child: Text(
                                    'profileLoadFailed'.tr(),
                                    style: t.bodySmall!.copyWith(
                                      color: z.headerInk,
                                      decoration: TextDecoration.underline,
                                      decorationColor: z.headerInk,
                                    ),
                                  ),
                                )
                              else if (isGuest)
                                Text(
                                  'guestHint'.tr(),
                                  style: t.bodySmall!.copyWith(
                                    color: z.headerInk2,
                                  ),
                                )
                              else if (phone.isNotEmpty)
                                Text(
                                  phone,
                                  style: t.bodyMedium!.copyWith(
                                    color: z.headerInk2,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Flexible: a long label can't push the name out.
                        if (isGuest)
                          Flexible(
                            child: _HeaderPill(
                              label: 'saveAccount'.tr(),
                              onTap: () =>
                                  context.pushNamed('GuestUpgradeScreen'),
                            ),
                          )
                        else if (profile != null)
                          Flexible(
                            child: _HeaderPill(
                              label: 'editProfile'.tr(),
                              onTap: () =>
                                  context.pushNamed('EditProfileScreen'),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -(ZSpace.x8 + ZSpace.x2)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ZSpace.screen,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Card(
                            padding: const EdgeInsets.symmetric(
                              vertical: ZSpace.x4,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _QuickAction(
                                    icon: Icons.shopping_bag_outlined,
                                    background: z.brandSoft,
                                    foreground: z.brandText,
                                    label: 'yourOrder'.tr(),
                                    onTap: () =>
                                        context.pushNamed('YourOrderScreen'),
                                  ),
                                ),
                                Expanded(
                                  child: _QuickAction(
                                    icon: Icons.favorite_border_rounded,
                                    background: z.blueSoft,
                                    foreground: z.blue,
                                    label: 'favourite'.tr(),
                                    onTap: () => ref
                                        .read(navBarProvider.notifier)
                                        .updateIndex(3),
                                  ),
                                ),
                                Expanded(
                                  child: _QuickAction(
                                    icon: Icons.help_outline_rounded,
                                    background: z.okSoft,
                                    foreground: z.ok,
                                    label: 'help'.tr(),
                                    onTap: () => showHelpSheet(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: ZSpace.x3),
                          const _AppearanceCard(),
                          const SizedBox(height: ZSpace.x3),
                          _Group(
                            items: [
                              _GroupItem(
                                icon: Icons.location_on_outlined,
                                label: 'addressBook'.tr(),
                                onTap: () =>
                                    context.pushNamed('MyAddressScreen'),
                              ),
                              _GroupItem(
                                icon: Icons.credit_card_outlined,
                                label: 'paymentSettings'.tr(),
                                onTap: () =>
                                    context.pushNamed('PaymentSettingsScreen'),
                              ),
                              _GroupItem(
                                icon: Icons.language_rounded,
                                label: 'language'.tr(),
                                trailingText: currentLanguageName(context),
                                onTap: () => showLanguageSheet(
                                  context,
                                  pushTokens: ref.read(
                                    pushTokenRepositoryProvider,
                                  ),
                                ),
                              ),
                              _GroupItem(
                                icon: Icons.notifications_none_rounded,
                                label: 'notificationPref'.tr(),
                                onTap: () => context.pushNamed(
                                  'NotificationSettingsScreen',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: ZSpace.x3),
                          _Group(
                            items: [
                              _GroupItem(
                                icon: Icons.description_outlined,
                                label: 'accountPrivacy'.tr(),
                                onTap: () =>
                                    context.pushNamed('AccountPrivacyScreen'),
                              ),
                              _GroupItem(
                                icon: Icons.logout_rounded,
                                label: 'logOut'.tr(),
                                danger: true,
                                onTap: () =>
                                    _confirmLogOut(context, ref, isGuest),
                              ),
                            ],
                          ),
                          const SizedBox(height: ZSpace.x4),
                          Text(
                            'appVersion'.tr(args: [Constants.appVersion]),
                            textAlign: TextAlign.center,
                            style: t.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const ZStatusBarStrip(),
        ],
      ),
    );
  }
}

/// Logging out of a guest account loses its orders and addresses for
/// good (there's no credential to sign back in with), so say so.
Future<void> _confirmLogOut(
  BuildContext context,
  WidgetRef ref,
  bool isGuest,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(
        isGuest ? 'guestLogOutTitle'.tr() : 'logOutConfirmTitle'.tr(),
      ),
      content: Text(
        isGuest ? 'guestLogOutBody'.tr() : 'logOutConfirmBody'.tr(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text('cancel'.tr()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(isGuest ? 'continueLabel'.tr() : 'logOut'.tr()),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await ref.read(sharedPreferenceProvider.notifier).logOut();
  }
}

/// White rounded card with a hairline border.
class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Container(
      padding: padding ?? const EdgeInsets.all(ZSpace.x4),
      decoration: BoxDecoration(
        color: z.surface,
        borderRadius: ZRadius.all(ZRadius.card),
        border: Border.all(color: z.line),
        boxShadow: [
          BoxShadow(
            color: z.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// "Edit" / "Save account" on the magenta header.
class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Semantics(
      button: true,
      child: ZPressable(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: ZSize.touch),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: ZSpace.x4),
          decoration: BoxDecoration(
            color: z.onBrand.withValues(alpha: .16),
            borderRadius: ZRadius.all(ZRadius.control),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge!
                .copyWith(color: z.onBrand),
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background, foreground;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: ZPressable(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: ZSize.touch,
              height: ZSize.touch,
              decoration: BoxDecoration(
                color: background,
                borderRadius: ZRadius.all(ZRadius.input),
              ),
              child: Icon(icon, color: foreground),
            ),
            const SizedBox(height: ZSpace.x2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge!
                  .copyWith(color: context.z.brandText),
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
  final bool danger;
  final String? trailingText;

  _GroupItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
    this.trailingText,
  });
}

/// Settings rows: icon tile · label · optional value · chevron.
class _Group extends StatelessWidget {
  final List<_GroupItem> items;

  const _Group({required this.items});

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    // A Material (not a coloured box) so the ListTiles' ink splashes paint
    // on it and are clipped to the rounded corners.
    return Material(
      color: z.surface,
      shape: RoundedRectangleBorder(
        borderRadius: ZRadius.all(ZRadius.card),
        side: BorderSide(color: z.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, color: z.line),
            ListTile(
              onTap: items[i].onTap,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: ZSpace.x4,
                vertical: ZSpace.x1,
              ),
              leading: Container(
                width: ZSize.touch - 4,
                height: ZSize.touch - 4,
                decoration: BoxDecoration(
                  color: items[i].danger ? z.dangerSoft : z.surface2,
                  borderRadius: ZRadius.all(ZRadius.control),
                ),
                child: Icon(
                  items[i].icon,
                  size: 20,
                  color: items[i].danger ? z.danger : z.ink2,
                ),
              ),
              title: Text(
                items[i].label,
                style: t.labelLarge!.copyWith(
                  color: items[i].danger ? z.danger : z.ink,
                ),
              ),
              trailing: items[i].danger
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (items[i].trailingText != null)
                          Padding(
                            padding: const EdgeInsets.only(right: ZSpace.x2),
                            child: Text(
                              items[i].trailingText!,
                              style: t.bodySmall,
                            ),
                          ),
                        Icon(Icons.chevron_right_rounded, color: z.ink3),
                      ],
                    ),
            ),
          ],
        ],
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
        color: context.z.surface,
        borderRadius: BorderRadius.circular(ZRadius.card),
        border: Border.all(color: context.z.line),
      ),
      padding: const EdgeInsets.all(ZSpace.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'appearance'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: ZSpace.x3),
          Container(
            padding: const EdgeInsets.all(ZSpace.x1),
            decoration: BoxDecoration(
              color: context.z.surface2,
              borderRadius: BorderRadius.circular(ZRadius.input),
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
        borderRadius: BorderRadius.circular(ZRadius.control),
        child: Container(
          height: ZSize.addButton,
          decoration: BoxDecoration(
            color: selected ? context.z.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(ZRadius.control),
            boxShadow: selected
                ? [BoxShadow(color: context.z.shadow, blurRadius: 4)]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: ZSpace.x1),
          // Three options share the row: shrink rather than overflow.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: selected ? context.z.ink : context.z.ink2,
                ),
                const SizedBox(width: ZSpace.x1),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: selected ? context.z.ink : context.z.ink2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
