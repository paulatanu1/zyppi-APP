import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/profile_repository_impl.dart';
import 'package:zippy/core/data/provider/profile_provider.dart';
import 'package:zippy/core/domain/profile.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/core/payments/presentation/payment_options.dart';
import 'package:zippy/features/account/widgets/settings_scaffold.dart';

/// Account → Payment settings: the method checkout starts with. Cards are
/// never stored by the app — PhonePe handles them at payment time.
class PaymentSettingsScreen extends ConsumerWidget {
  const PaymentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final text = Theme.of(context).textTheme;

    return SettingsScaffold(
      title: 'paymentSettings'.tr(),
      async: profileAsync,
      onRetry: () => ref.invalidate(profileProvider),
      builder: (profile) => ListView(
        padding: const EdgeInsets.all(ZSpace.screen),
        children: [
          Text('preferredPaymentHint'.tr(), style: text.bodyMedium),
          const SizedBox(height: ZSpace.x4),
          PaymentOptions(
            selected:
                availablePaymentMethods.contains(profile.preferredPaymentMethod)
                ? profile.preferredPaymentMethod!
                : defaultPaymentMethod,
            onSelect: (method) =>
                _save(ref, profile.copyWith(preferredPaymentMethod: method)),
          ),
          const SizedBox(height: ZSpace.x4),
          Text('cardsNotStored'.tr(), style: text.bodySmall),
        ],
      ),
    );
  }

  Future<void> _save(WidgetRef ref, Profile profile) async {
    try {
      await ref.read(profileRepositoryProvider).updatePreferences(profile);
      ref.invalidate(profileProvider);
    } catch (error) {
      showError(error);
    }
  }
}
