import 'package:easy_localization/easy_localization.dart';

/// Address labels are stored in English so they stay the same whatever
/// language the address was saved in; show them through
/// [addressLabelText].
const addressLabels = ['Home', 'Work', 'Other'];

/// The translated text for a stored address label. A label that isn't
/// one of [addressLabels] is shown as it is.
String addressLabelText(String label) => switch (label) {
  'Home' => 'addressLabelHome'.tr(),
  'Work' => 'addressLabelWork'.tr(),
  'Other' => 'addressLabelOther'.tr(),
  _ => label,
};
