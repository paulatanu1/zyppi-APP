import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zippy/core/utils/snack_bar.dart';

/// Opens [uri] in the app that handles it (dialer, WhatsApp, browser).
/// Shows a message instead of failing silently when nothing can open it.
Future<void> openExternal(Uri uri) async {
  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) showError('couldNotOpenLink'.tr());
  } catch (_) {
    showError('couldNotOpenLink'.tr());
  }
}

Uri phoneUri(String phone) => Uri(scheme: 'tel', path: phone);

/// [phone] in international format without '+', e.g. 919876543210.
Uri whatsAppUri(String phone, {String? message}) =>
    Uri.https('wa.me', '/$phone', message == null ? null : {'text': message});
