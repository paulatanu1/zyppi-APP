import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/account/account_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/legal/domain/legal_doc.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/core/common_widgets/section_card.dart';
import 'package:zippy/core/widgets/z_commerce.dart';

/// Account → Account & privacy: policy links and account deletion (Google
/// Play requires an in-app way to delete an account).
class AccountPrivacyScreen extends ConsumerWidget {
  const AccountPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final text = Theme.of(context).textTheme;

    // The live, versioned text from legalDocs (what the customer accepted).
    Widget link(String type) => ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(LegalTypes.labelKey(type).tr(), style: text.labelLarge),
      trailing: Icon(Icons.chevron_right_rounded, color: z.ink3),
      onTap: () => context.push(
        Uri(path: '/legal', queryParameters: {'type': type}).toString(),
      ),
    );

    return Scaffold(
      backgroundColor: z.bg,
      appBar: AppBar(title: Text('accountPrivacy'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(ZSpace.screen),
        children: [
          SectionCard(
            child: Column(
              children: [for (final type in LegalTypes.forCustomer) link(type)],
            ),
          ),
          const SizedBox(height: ZSpace.x3),
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
    } on WalletNotEmpty catch (e) {
      // Money in the wallet is lost with the account: say so first.
      if (!context.mounted) return;
      final forfeit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('deleteWalletTitle'.tr()),
          content: Text('deleteWalletBody'.tr(args: [rupees(e.walletPaise)])),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: context.z.danger),
              onPressed: () => Navigator.pop(context, true),
              child: Text('deleteAnyway'.tr()),
            ),
          ],
        ),
      );
      if (forfeit != true) return;
      try {
        await ref
            .read(accountRepositoryProvider)
            .deleteAccount(forfeitWallet: true);
      } catch (error) {
        showError(error);
        return;
      }
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
