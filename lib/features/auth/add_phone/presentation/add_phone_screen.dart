import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/data/profile_repository_impl.dart';
import 'package:zippy/core/data/provider/profile_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/phone.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/auth/session/auth_session.dart';
import 'package:zippy/features/auth/widgets/auth_widgets.dart';

/// "One last step": the mobile number for an account that has none yet
/// (after a first Google sign-in, or a guest saving their account). Riders
/// call it, so ordering needs it. No OTP; checked as typed.
class AddPhoneScreen extends ConsumerStatefulWidget {
  const AddPhoneScreen({super.key});

  @override
  ConsumerState<AddPhoneScreen> createState() => _AddPhoneScreenState();
}

class _AddPhoneScreenState extends ConsumerState<AddPhoneScreen> {
  final _phone = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final phone = toIndianE164(_phone.text);
    if (phone == null) {
      setState(() => _error = 'invalidPhone'.tr());
      return;
    }
    FocusScope.of(context).unfocus();
    final session = ref.read(authSessionProvider);
    final uid = ref.read(currentAccountProvider)?.uid;
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      await ref.read(profileRepositoryProvider).savePhone(phone);
      ref.invalidate(profileProvider);
      if (uid != null) await session.markSignedIn(uid);
      if (!mounted) return;
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go('/navBar');
      }
    } catch (e) {
      showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final account = ref.watch(currentAccountProvider);
    final user = (name: account?.name ?? '', email: account?.email ?? '');
    final initial = (user.name.isNotEmpty ? user.name : user.email).characters
        .take(1)
        .toString()
        .toUpperCase();

    return Scaffold(
      backgroundColor: z.bg,
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          ZSpace.x5,
          ZSpace.x2,
          ZSpace.x5,
          ZSpace.x6,
        ),
        children: [
          if (user.email.isNotEmpty || user.name.isNotEmpty)
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: z.brandSoft,
                  child: Text(
                    initial,
                    style: t.titleMedium!.copyWith(color: z.brandText),
                  ),
                ),
                const SizedBox(width: ZSpace.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user.name.isNotEmpty)
                        Text(user.name, style: t.labelLarge),
                      Text(
                        user.email,
                        style: t.bodySmall!.copyWith(color: z.ink3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: ZSpace.x5),
          Text('addPhoneTitle'.tr(), style: t.headlineSmall),
          const SizedBox(height: ZSpace.x1),
          Text(
            'addPhoneBody'.tr(),
            style: t.bodyLarge!.copyWith(color: z.ink2),
          ),
          const SizedBox(height: ZSpace.x5),
          PhoneField(
            controller: _phone,
            autofocus: true,
            error: _error,
            helper: 'addPhoneHint'.tr(),
            onSubmitted: (_) => _save(),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: ZSpace.x4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ZSpace.x3,
              vertical: ZSpace.x1,
            ),
            decoration: BoxDecoration(
              color: z.surface,
              borderRadius: ZRadius.all(ZRadius.card),
              boxShadow: [
                BoxShadow(
                  color: z.shadow,
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                AuthReassurance(
                  icon: Icons.bolt_rounded,
                  title: 'riderCallsTitle'.tr(),
                  body: 'riderCallsBody'.tr(),
                ),
                Divider(height: 1, color: z.line),
                AuthReassurance(
                  icon: Icons.lock_outline_rounded,
                  title: 'neverSharedTitle'.tr(),
                  body: 'neverSharedBody'.tr(),
                ),
              ],
            ),
          ),
          const SizedBox(height: ZSpace.x6),
          BusyButton(
            label: 'continueLabel'.tr(),
            busy: _busy,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
