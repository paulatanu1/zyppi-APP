import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/legal/application/legal_providers.dart';
import 'package:zippy/core/legal/domain/legal_doc.dart';
import 'package:zippy/core/legal/presentation/legal_markdown.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_motion.dart';

/// Reads one legal document's live version (route `/legal?type=…`),
/// signed in or not.
class LegalDocScreen extends ConsumerWidget {
  const LegalDocScreen({super.key, required this.type});

  final String type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final key = (type: type, lang: legalLang(context.locale.languageCode));
    final doc = ref.watch(legalDocTextProvider(key));

    return Scaffold(
      backgroundColor: z.bg,
      appBar: AppBar(title: Text(LegalTypes.labelKey(type).tr())),
      body: SafeArea(
        child: doc.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(ZSpace.screen),
            children: [
              const ZSkeleton(width: 220, height: 28),
              const SizedBox(height: ZSpace.x4),
              for (var i = 0; i < 8; i++) ...[
                const ZSkeleton(height: 14),
                const SizedBox(height: ZSpace.x2),
              ],
            ],
          ),
          error: (_, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(ZSpace.x6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'somethingWentWrong'.tr(),
                    style: t.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: ZSpace.x4),
                  FilledButton(
                    onPressed: () => ref.invalidate(legalDocTextProvider(key)),
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            ),
          ),
          data: (d) => d == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(ZSpace.x6),
                    child: Text(
                      'legalNotPublished'.tr(),
                      style: t.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                    ZSpace.screen,
                    ZSpace.x2,
                    ZSpace.screen,
                    ZSpace.x8,
                  ),
                  children: [
                    LegalMarkdown(d.body),
                    const SizedBox(height: ZSpace.x4),
                    Text(
                      'legalVersion'.tr(args: ['${d.version}']),
                      style: t.bodySmall,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
