import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/legal/application/legal_providers.dart';
import 'package:zippy/core/legal/data/legal_repository_impl.dart';
import 'package:zippy/core/legal/domain/legal_doc.dart';
import 'package:zippy/core/legal/presentation/legal_consent_row.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// Wraps the signed-in app. When the customer hasn't accepted the live
/// version of the terms, privacy or refund policy:
/// - if they ticked "I agree" on the login screen this session, the
///   acceptance is recorded quietly;
/// - otherwise (a new version, or an account from before consents were
///   recorded) a full-screen prompt asks them to accept.
///
/// While checking, or if the check fails (offline), the app is shown: a
/// network blip must not lock customers out. It is checked again on the
/// next start.
class LegalGate extends ConsumerStatefulWidget {
  const LegalGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LegalGate> createState() => _LegalGateState();
}

class _LegalGateState extends ConsumerState<LegalGate> {
  bool _autoTried = false;

  Future<void> _autoAccept(List<PendingLegalDoc> docs) async {
    _autoTried = true;
    try {
      await ref.read(legalRepositoryProvider).accept(docs);
      ref.read(legalAgreedAtLoginProvider.notifier).set(false);
      ref.invalidate(legalPendingProvider);
    } catch (_) {
      // Falls through to the prompt.
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(legalPendingProvider).value ?? const [];
    if (pending.isEmpty) return widget.child;

    final agreed = ref.watch(legalAgreedAtLoginProvider);
    if (agreed && !_autoTried) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _autoAccept(pending));
      return widget.child;
    }
    return LegalUpdatePrompt(docs: pending);
  }
}

/// Asks to accept new or updated documents before carrying on.
class LegalUpdatePrompt extends ConsumerStatefulWidget {
  const LegalUpdatePrompt({super.key, required this.docs});

  final List<PendingLegalDoc> docs;

  @override
  ConsumerState<LegalUpdatePrompt> createState() => _LegalUpdatePromptState();
}

class _LegalUpdatePromptState extends ConsumerState<LegalUpdatePrompt> {
  bool _agreed = false;
  bool _tried = false;
  bool _saving = false;
  String? _error;

  Future<void> _accept() async {
    setState(() {
      _tried = true;
      _error = null;
    });
    if (!_agreed) return;
    setState(() => _saving = true);
    try {
      await ref.read(legalRepositoryProvider).accept(widget.docs);
      ref.invalidate(legalPendingProvider);
    } catch (_) {
      // TERMS_CHANGED or offline: reload what is live and let them retry.
      ref.invalidate(legalPendingProvider);
      if (mounted) setState(() => _error = 'legalAcceptFailed'.tr());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: z.bg,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              ZSpace.x5,
              ZSpace.x8,
              ZSpace.x5,
              ZSpace.x6,
            ),
            children: [
              Icon(Icons.verified_user_outlined, size: 48, color: z.brandText),
              const SizedBox(height: ZSpace.x4),
              Text('legalUpdatedTitle'.tr(), style: t.headlineMedium),
              const SizedBox(height: ZSpace.x2),
              Text('legalUpdatedBody'.tr(), style: t.bodyLarge),
              const SizedBox(height: ZSpace.x5),
              LegalConsentRow(
                value: _agreed,
                showError: _tried,
                types: [for (final d in widget.docs) d.type],
                onChanged: (v) => setState(() => _agreed = v),
              ),
              if (_error != null) ...[
                const SizedBox(height: ZSpace.x3),
                Text(_error!, style: t.bodySmall!.copyWith(color: z.danger)),
              ],
              const SizedBox(height: ZSpace.x5),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, ZSize.button),
                ),
                onPressed: _saving ? null : _accept,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text('legalAgreeContinue'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
