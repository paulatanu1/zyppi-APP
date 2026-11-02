import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// The four supported locales (bootstrap.dart), each named in its own
/// script so people can find theirs whatever language is active.
const appLanguages = [
  (locale: Locale('en', 'UK'), name: 'English'),
  (locale: Locale('bn', 'BN'), name: 'বাংলা'),
  (locale: Locale('hi', 'IN'), name: 'हिन्दी'),
  (locale: Locale('pa', 'Guru'), name: 'ਪੰਜਾਬੀ'),
];

String currentLanguageName(BuildContext context) =>
    appLanguages
        .where((l) => l.locale == context.locale)
        .map((l) => l.name)
        .firstOrNull ??
    appLanguages.first.name;

Future<void> showLanguageSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: ZRadius.sheetTop),
    builder: (sheetContext) {
      final z = sheetContext.z;
      final text = Theme.of(sheetContext).textTheme;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            ZSpace.screen,
            ZSpace.x5,
            ZSpace.screen,
            ZSpace.x4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('language'.tr(), style: text.titleMedium),
              const SizedBox(height: ZSpace.x2),
              for (final language in appLanguages)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(language.name, style: text.labelLarge),
                  trailing: sheetContext.locale == language.locale
                      ? Icon(Icons.check_circle_rounded, color: z.brand)
                      : null,
                  onTap: () async {
                    await sheetContext.setLocale(language.locale);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}
