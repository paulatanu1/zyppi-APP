import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/app_settings/data/app_settings_repository.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/launch.dart';
import 'package:zippy/core/utils/order_id.dart';

/// "Help" from Account, order details and tracking: chat in the app
/// (the Zyppi assistant, then the team), WhatsApp or call support. With an
/// [orderId] the chat is about that order and the WhatsApp message quotes
/// its short id, so support can find it straight away.
Future<void> showHelpSheet(BuildContext context, {String? orderId}) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: ZRadius.sheetTop),
    builder: (sheetContext) => Consumer(
      builder: (sheetContext, ref, _) {
        final z = sheetContext.z;
        final text = Theme.of(sheetContext).textTheme;
        // Store settings in the admin, else the build's SUPPORT_PHONE.
        // Watched, so WhatsApp and Call appear if config/app arrives after
        // the sheet opened.
        final phone = ref.watch(supportPhoneProvider);
        final whatsApp = ref.watch(supportWhatsAppProvider);

        Widget option({
          required IconData icon,
          required String title,
          required String subtitle,
          required VoidCallback onTap,
        }) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: z.brandSoft,
                borderRadius: ZRadius.all(ZRadius.control),
              ),
              child: Icon(icon, color: z.brandText),
            ),
            title: Text(title, style: text.labelLarge),
            subtitle: Text(subtitle, style: text.bodySmall),
            trailing: Icon(Icons.chevron_right_rounded, color: z.ink3),
            onTap: () {
              Navigator.pop(sheetContext);
              onTap();
            },
          );
        }

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
                Text('helpTitle'.tr(), style: text.titleMedium),
                const SizedBox(height: ZSpace.x1),
                Text('helpSubtitle'.tr(), style: text.bodySmall),
                const SizedBox(height: ZSpace.x3),
                option(
                  icon: Icons.forum_outlined,
                  title: 'helpChat'.tr(),
                  subtitle: 'helpChatSubtitle'.tr(),
                  onTap: () => context.push(
                    orderId == null
                        ? '/supportChat'
                        : '/supportChat?orderId=$orderId',
                  ),
                ),
                // Chat always works; WhatsApp and Call only with a number.
                if (phone.isNotEmpty) ...[
                  option(
                    icon: Icons.chat_outlined,
                    title: 'helpWhatsApp'.tr(),
                    subtitle: 'helpWhatsAppSubtitle'.tr(),
                    onTap: () => openExternal(
                      whatsAppUri(
                        whatsApp,
                        message: orderId == null
                            ? 'helpMessage'.tr()
                            : 'helpMessageOrder'.tr(
                                args: [shortOrderId(orderId)],
                              ),
                      ),
                    ),
                  ),
                  option(
                    icon: Icons.call_outlined,
                    title: 'helpCall'.tr(),
                    subtitle: '+$phone',
                    onTap: () => openExternal(phoneUri('+$phone')),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
}
