import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/constants/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/provider/profile_provider.dart';
import 'package:zippy/core/data/profile_repository_impl.dart';
import 'package:zippy/core/domain/profile.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/edit_profile/widgets/text_input_field_container.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

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

    profileAsync.whenData(_prefillIfNeeded);

    return Scaffold(
      backgroundColor: context.z.bg,
      appBar: AppBar(title: Text('editProfile'.tr())),
      body: SafeArea(
        child: profileAsync.isLoading && _loadedProfile == null
            ? const Center(child: CircularProgressIndicator())
            : profileAsync.hasError && _loadedProfile == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'somethingWentWrong'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium!,
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(profileProvider),
                      child: Text('retry'.tr()),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(ZSpace.x4),
                      child: Column(
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
                          const SizedBox(height: ZSpace.x3),
                          TextInputFieldContainer(
                            controller: emailController,
                            inputFieldName: 'emailAddress'.tr(),
                            keyboardType: TextInputType.emailAddress,
                            errorText: _emailError,
                            onChanged: (_) {
                              if (_emailError != null) {
                                setState(() => _emailError = null);
                              }
                            },
                          ),
                          const SizedBox(height: ZSpace.x3),
                          TextInputFieldContainer(
                            controller: phController,
                            inputFieldName: 'phoneNumber'.tr(),
                            enabled: false,
                          ),
                          const SizedBox(height: ZSpace.x3),
                          TextInputFieldContainer(
                            controller: dobController,
                            inputFieldName: 'dateOfBirth'.tr(),
                            onTap: _pickDob,
                          ),
                          const SizedBox(height: ZSpace.x3),
                          DropdownButtonFormField<String>(
                            initialValue: _gender,
                            decoration: InputDecoration(
                              labelText: 'gender'.tr(),
                            ),
                            items: [
                              for (final g in _genders)
                                DropdownMenuItem(
                                  value: g,
                                  child: Text('gender_$g'.tr()),
                                ),
                            ],
                            onChanged: (value) =>
                                setState(() => _gender = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      ZSpace.x4,
                      0,
                      ZSpace.x4,
                      ZSpace.x4,
                    ),
                    child: FilledButton(
                      onPressed: _saving || _loadedProfile == null
                          ? null
                          : _save,
                      child: _saving
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text('save'.tr()),
                    ),
                  ),
                  Image.asset(
                    'assets/brand/zyppi_mark.png',
                    height: 24,
                    semanticLabel: 'Zyppi',
                  ),
                  const SizedBox(height: ZSpace.x2),
                  Text(
                    'appVersion'.tr(args: [Constants.appVersion]),
                    style: Theme.of(context).textTheme.bodySmall!
                        .copyWith(color: context.z.ink2),
                  ),
                  const SizedBox(height: ZSpace.x3),
                ],
              ),
      ),
    );
  }
}
