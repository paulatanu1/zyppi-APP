import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/constants/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/data/provider/profile_provider.dart';
import 'package:zippy/core/data/profile_repository_impl.dart';
import 'package:zippy/core/domain/profile.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/edit_profile/widgets/text_input_field_container.dart';

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
  final genderController = TextEditingController();

  Profile? _loadedProfile;
  bool _saving = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phController.dispose();
    dobController.dispose();
    genderController.dispose();
    super.dispose();
  }

  void _prefillIfNeeded(Profile profile) {
    if (_loadedProfile?.id == profile.id) return;
    _loadedProfile = profile;
    nameController.text = profile.fullName ?? '';
    emailController.text = profile.email ?? '';
    phController.text = profile.phone ?? '';
    dobController.text = profile.dob == null
        ? ''
        : '${profile.dob!.year}-${profile.dob!.month.toString().padLeft(2, '0')}-${profile.dob!.day.toString().padLeft(2, '0')}';
    genderController.text = profile.gender ?? '';
  }

  Future<void> _save() async {
    final current = _loadedProfile;
    if (current == null) return;

    setState(() => _saving = true);

    DateTime? dob;
    if (dobController.text.trim().isNotEmpty) {
      dob = DateTime.tryParse(dobController.text.trim());
    }

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
              gender: genderController.text.trim().isEmpty
                  ? null
                  : genderController.text.trim(),
            ),
          );

      ref.invalidate(profileProvider);
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
      backgroundColor: context.colors.background,
      appBar: AppBar(title: Text('editProfile'.tr())),
      body: SafeArea(
        child: profileAsync.isLoading && _loadedProfile == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Column(
                        children: [
                          TextInputFieldContainer(
                            controller: nameController,
                            inputFieldName: 'fullName'.tr(),
                          ),
                          const SizedBox(height: AppSpacing.base),
                          TextInputFieldContainer(
                            controller: emailController,
                            inputFieldName: 'emailAddress'.tr(),
                          ),
                          const SizedBox(height: AppSpacing.base),
                          TextInputFieldContainer(
                            controller: phController,
                            inputFieldName: 'phoneNumber'.tr(),
                            enabled: false,
                          ),
                          const SizedBox(height: AppSpacing.base),
                          TextInputFieldContainer(
                            controller: dobController,
                            inputFieldName: 'dateOfBirth'.tr(),
                          ),
                          const SizedBox(height: AppSpacing.base),
                          TextInputFieldContainer(
                            controller: genderController,
                            inputFieldName: 'gender'.tr(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xxl,
                      0,
                      AppSpacing.xxl,
                      AppSpacing.xxl,
                    ),
                    child: PrimaryButton(
                      buttonTitle: _saving ? '…' : 'save'.tr(),
                      action: _saving || _loadedProfile == null ? () {} : _save,
                    ),
                  ),
                  Image.asset('assets/images/prof_logo.png', height: 32),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'appVersion'.tr(args: [Constants.appVersion]),
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.muted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                ],
              ),
      ),
    );
  }
}
