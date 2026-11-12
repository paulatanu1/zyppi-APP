import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/widgets/z_hero_header.dart';
import 'package:zippy/core/account/account_repository.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/launch.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/core/common_widgets/section_card.dart';

/// Account → Account & privacy: policy links and account deletion (Google
/// Play requires an in-app way to delete an account).
class AccountPrivacyScreen extends ConsumerWidget {
  const AccountPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final text = Theme.of(context).textTheme;

    Widget link(String label, String url) => ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: text.labelLarge),
      trailing: Icon(Icons.open_in_new_rounded, size: 18, color: z.ink3),
      onTap: () => openExternal(Uri.parse(url)),
    );

    return Scaffold(
      backgroundColor: z.bg,
      appBar: ZHeroAppBar(title: 'accountPrivacy'.tr()),
      body: ListView(
        padding: const EdgeInsets.all(ZSpace.screen),
        children: [
          if (Env.privacyPolicyUrl.isNotEmpty || Env.termsUrl.isNotEmpty) ...[
            SectionCard(
              child: Column(
                children: [
                  if (Env.privacyPolicyUrl.isNotEmpty)
                    link('privacyPolicy'.tr(), Env.privacyPolicyUrl),
                  if (Env.termsUrl.isNotEmpty)
                    link('termsOfService'.tr(), Env.termsUrl),
                ],
              ),
            ),
            const SizedBox(height: ZSpace.x3),
          ],
          SectionCard(
            title: 'deleteAccount'.tr(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('deleteAccountExplainer'.tr(), style: text.bodyMedium),
                const SizedBox(height: ZSpace.x4),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: z.danger,
                    side: BorderSide(color: z.danger),
                  ),
                  onPressed: () => _confirmDelete(context, ref),
                  child: Text('deleteAccount'.tr()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _DeleteAccountDialog(),
    );
    if (confirmed != true) return;

    try {
      await ref.read(accountRepositoryProvider).deleteAccount();
    } catch (error) {
      showError(error);
      return;
    }

    showSuccessToast(message: 'accountDeleted'.tr());
    // Same local cleanup as logging out; the router then shows login.
    await ref.read(sharedPreferenceProvider.notifier).logOut();
  }
}

/// Second step: the user types DELETE, so it can't happen by a stray tap.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  static const _word = 'DELETE';
  final _controller = TextEditingController();
  bool _deleting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final matches = _controller.text.trim().toUpperCase() == _word;

    return AlertDialog(
      title: Text('deleteAccountConfirmTitle'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('deleteAccountConfirmBody'.tr(args: [_word])),
          const SizedBox(height: ZSpace.x3),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: _word),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _deleting ? null : () => Navigator.pop(context, false),
          child: Text('cancel'.tr()),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: z.danger),
          onPressed: matches && !_deleting
              ? () {
                  setState(() => _deleting = true);
                  Navigator.pop(context, true);
                }
              : null,
          child: Text('deleteAccount'.tr()),
        ),
      ],
    );
  }
}
