import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/constants/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/provider/profile_provider.dart';
import 'package:zippy/core/data/profile_repository_impl.dart';
import 'package:zippy/core/domain/profile.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/edit_profile/widgets/text_input_field_container.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/data/provider/addresses_provider.dart';
import 'package:zippy/core/order/domain/order_repository.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/core/widgets/z_commerce.dart';
import 'package:zippy/features/wallet/data/wallet_repository.dart';
import 'package:zippy/features/your_order/application/orders_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phController = TextEditingController();
  final dobController = TextEditingController();

  Profile? _loadedProfile;
  DateTime? _dob;
  String? _gender;
  bool _saving = false;
  String? _nameError;
  String? _emailError;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phController.dispose();
    dobController.dispose();
    super.dispose();
  }

  void _prefillIfNeeded(Profile profile) {
    if (_loadedProfile?.id == profile.id) return;
    _loadedProfile = profile;
    nameController.text = profile.fullName ?? '';
    emailController.text = profile.email ?? '';
    phController.text = profile.phone ?? '';
    _dob = profile.dob;
    dobController.text = _formatDob(profile.dob);
    _gender = _genders.contains(profile.gender) ? profile.gender : null;
  }

  static const _genders = ['male', 'female', 'other'];
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  bool _validate() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    setState(() {
      _nameError = name.isEmpty ? 'nameRequired'.tr() : null;
      _emailError = email.isNotEmpty && !_emailPattern.hasMatch(email)
          ? 'invalidEmail'.tr()
          : null;
    });
    return _nameError == null && _emailError == null;
  }

  static String _formatDob(DateTime? dob) => dob == null
      ? ''
      : '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}';

  /// DOB is picked, never typed, so it can't be lost to unparseable text.
  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;

    _dob = picked;
    dobController.text = _formatDob(picked);
  }

  Future<void> _save() async {
    final current = _loadedProfile;
    if (current == null || !_validate()) return;

    setState(() => _saving = true);

    // Captured up front: if the user leaves mid-save, this widget's ref is
    // gone but the account screen must still refresh.
    final container = ProviderScope.containerOf(context, listen: false);

    // The field's clear button empties the text; that's the only way to
    // remove a DOB.
    final dob = dobController.text.isEmpty ? null : _dob;

    try {
      await ref
          .read(profileRepositoryProvider)
          .updateProfile(
            current.copyWith(
              fullName: nameController.text.trim(),
              email: emailController.text.trim().isEmpty
                  ? null
                  : emailController.text.trim(),
              dob: dob,
              gender: _gender,
            ),
          );

      container.invalidate(profileProvider);
      showSuccessToast(message: 'profileUpdated'.tr());
      if (mounted) Navigator.pop(context);
    } catch (error) {
      showError(error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final z = context.z;
    final t = Theme.of(context).textTheme;

    profileAsync.whenData(_prefillIfNeeded);

    final Widget body;
    if (profileAsync.isLoading && _loadedProfile == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (profileAsync.hasError && _loadedProfile == null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('somethingWentWrong'.tr(), style: t.bodyMedium),
            TextButton(
              onPressed: () => ref.invalidate(profileProvider),
              child: Text('retry'.tr()),
            ),
          ],
        ),
      );
    } else {
      // An email that came with the sign-in can't be changed here.
      final emailLocked = (_loadedProfile?.email ?? '').isNotEmpty;
      body = SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: ZSpace.x6 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileHeader(
              name: nameController.text,
              email: _loadedProfile?.email,
              saving: _saving,
              onSave: _loadedProfile == null ? null : _save,
            ),
            const SizedBox(height: ZSpace.x3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ZSpace.screen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FormCard(
                    children: [
                      TextInputFieldContainer(
                        controller: nameController,
                        inputFieldName: 'fullName'.tr(),
                        errorText: _nameError,
                        onChanged: (_) {
                          if (_nameError != null) {
                            setState(() => _nameError = null);
                          }
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextInputFieldContainer(
                              controller: dobController,
                              inputFieldName: 'dateOfBirth'.tr(),
                              onTap: _pickDob,
                            ),
                          ),
                          const SizedBox(width: ZSpace.x2),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _gender,
                              isExpanded: true,
                              // Same text as the other fields.
                              style: t.bodyLarge!.copyWith(color: z.ink),
                              decoration: InputDecoration(
                                labelText: 'gender'.tr(),
                              ),
                              items: [
                                for (final g in _genders)
                                  DropdownMenuItem(
                                    value: g,
                                    child: Text(
                                      'gender_$g'.tr(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                              onChanged: (value) =>
                                  setState(() => _gender = value),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: ZSpace.x3),
                  _FormCard(
                    children: [
                      TextInputFieldContainer(
                        controller: emailController,
                        inputFieldName: 'emailAddress'.tr(),
                        keyboardType: TextInputType.emailAddress,
                        enabled: !emailLocked,
                        errorText: _emailError,
                        onChanged: (_) {
                          if (_emailError != null) {
                            setState(() => _emailError = null);
                          }
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextInputFieldContainer(
                            controller: phController,
                            inputFieldName: 'phoneNumber'.tr(),
                            enabled: false,
                          ),
                          const SizedBox(height: ZSpace.x1),
                          Row(
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 14,
                                color: z.ink3,
                              ),
                              const SizedBox(width: ZSpace.x1),
                              Text('cantBeEdited'.tr(), style: t.bodySmall),
                            ],
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                            ),
                            onPressed: () => context.push('/supportChat'),
                            child: Text('changePhoneChat'.tr()),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: ZSpace.x6),
                  Image.asset(
                    'assets/brand/zyppi_mark.png',
                    height: 24,
                    semanticLabel: 'Zyppi',
                  ),
                  const SizedBox(height: ZSpace.x2),
                  Text(
                    'appVersion'.tr(args: [Constants.appVersion]),
                    textAlign: TextAlign.center,
                    style: t.bodySmall!.copyWith(color: z.ink2),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: z.bg,
        appBar: _loadedProfile == null
            ? AppBar(title: Text('editProfile'.tr()))
            : null,
        body: body,
      ),
    );
  }
}

/// Edit profile B: the pink header band (back · "Edit profile" · Save,
/// initials avatar, name and email) with a stats card floating over its
/// rounded bottom.
class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.saving,
    required this.onSave,
  });

  final String name;
  final String? email;
  final bool saving;
  final VoidCallback? onSave;

  static const _overlap = 34.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final top = MediaQuery.paddingOf(context).top;
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w.characters.first.toUpperCase())
        .join();
    const bottom = BorderRadius.vertical(
      bottom: Radius.circular(ZRadius.sheet),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: _overlap),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: bottom,
              boxShadow: z.headerShadow,
            ),
            child: ZHeaderFill(
              offsetY: 0,
              borderRadius: bottom,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  ZSpace.x2,
                  top + ZSpace.x1,
                  ZSpace.x2,
                  ZSpace.x6 + _overlap,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: MaterialLocalizations.of(context)
                              .backButtonTooltip,
                          style: IconButton.styleFrom(
                            backgroundColor: z.onBrand.withValues(alpha: .18),
                          ),
                          onPressed: () => Navigator.maybePop(context),
                          icon: Icon(
                            Icons.chevron_left_rounded,
                            color: z.headerInk,
                          ),
                        ),
                        const SizedBox(width: ZSpace.x2),
                        Expanded(
                          child: Text(
                            'editProfile'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.titleLarge!.copyWith(color: z.headerInk),
                          ),
                        ),
                        saving
                            ? Padding(
                                padding: const EdgeInsets.all(ZSpace.x3),
                                child: SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: z.headerInk,
                                  ),
                                ),
                              )
                            : TextButton(
                                onPressed: onSave,
                                style: TextButton.styleFrom(
                                  foregroundColor: z.headerInk,
                                ),
                                child: Text(
                                  'save'.tr(),
                                  style: t.labelLarge!.copyWith(
                                    color: z.headerInk,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: ZSpace.x3),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ZSpace.x2,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              // White in both themes, like the mockup.
                              color: z.onBrand,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              initials.isEmpty ? '?' : initials,
                              style: t.titleLarge!.copyWith(color: z.brand),
                            ),
                          ),
                          const SizedBox(width: ZSpace.x3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.trim().isEmpty ? '—' : name.trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.titleMedium!.copyWith(
                                    color: z.headerInk,
                                  ),
                                ),
                                if (email case final email?
                                    when email.isNotEmpty)
                                  Text(
                                    email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: t.bodySmall!.copyWith(
                                      color: z.headerInk2,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          left: ZSpace.screen,
          right: ZSpace.screen,
          bottom: 0,
          child: _StatsCard(),
        ),
      ],
    );
  }
}

/// Orders · Wallet · Addresses. Each value shows "–" until it loads.
class _StatsCard extends ConsumerWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final orders = ref.watch(ordersProvider).value;
    final wallet = ref.watch(walletBalanceProvider).value;
    final addresses = ref.watch(addressesProvider).value;
    String count(List<Object?>? list, {int? cap}) => switch (list) {
      null => '–',
      final l when cap != null && l.length >= cap => '$cap+',
      final l => '${l.length}',
    };
    final stats = [
      (count(orders, cap: recentOrdersLimit), 'statOrders'.tr()),
      (wallet == null ? '–' : rupees(wallet), 'statWallet'.tr()),
      (count(addresses), 'statAddresses'.tr()),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: ZSpace.x3),
      decoration: z.card(),
      child: Row(
        children: [
          for (final (value, label) in stats)
            Expanded(
              child: Column(
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleMedium,
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodySmall!.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A floating card of fields, spaced evenly.
class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(ZSpace.x4),
    decoration: context.z.card(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: ZSpace.x3),
          children[i],
        ],
      ],
    ),
  );
}
