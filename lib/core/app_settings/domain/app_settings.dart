import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

/// Kill switches from `config/features` (functions/src/shared/features.ts,
/// edited in the admin's Settings → Services). A missing doc or field means
/// ON, so the app behaves as before when nothing is set. The server
/// enforces the same switches; the app only hides what's off.
@freezed
abstract class FeatureFlags with _$FeatureFlags {
  const factory FeatureFlags({
    /// Google Places search when picking an address.
    @Default(true) bool placesSearch,

    /// The support bot (off: chats go straight to the team).
    @Default(true) bool supportBot,

    /// Phone OTP sign-in (off: Google and guest only).
    @Default(true) bool phoneOtp,
    @Default(true) bool upi,
    @Default(true) bool card,

    /// No new orders; the app shows [maintenanceMessage].
    @Default(false) bool maintenance,
    @Default('') String maintenanceMessage,

    /// Service areas where ordering is paused.
    @Default(<String>[]) List<String> closedAreaIds,

    /// Older app versions must update (x.y.z), or null.
    String? minAppVersion,
  }) = _FeatureFlags;

  const FeatureFlags._();

  static const defaults = FeatureFlags();

  /// Tolerant read: anything missing or malformed keeps its default.
  factory FeatureFlags.fromMap(Map<String, dynamic>? d) {
    if (d == null) return defaults;
    bool flag(Object? v, bool fallback) => v is bool ? v : fallback;
    final payments = d['payments'] is Map ? d['payments'] as Map : const {};
    final maintenance = d['maintenance'] is Map
        ? d['maintenance'] as Map
        : const {};
    final min = d['minAppVersion'];
    return FeatureFlags(
      placesSearch: flag(d['placesSearch'], true),
      supportBot: flag(d['supportBot'], true),
      phoneOtp: flag(d['phoneOtp'], true),
      upi: flag(payments['upi'], true),
      card: flag(payments['card'], true),
      maintenance: flag(maintenance['enabled'], false),
      maintenanceMessage: maintenance['message'] is String
          ? maintenance['message'] as String
          : '',
      closedAreaIds: d['closedAreaIds'] is List
          ? [
              for (final x in d['closedAreaIds'] as List)
                if (x is String) x,
            ]
          : const [],
      minAppVersion: min is String && _version.hasMatch(min) ? min : null,
    );
  }

  /// Whether ordering is paused for [serviceAreaId].
  bool isAreaClosed(String? serviceAreaId) =>
      serviceAreaId != null && closedAreaIds.contains(serviceAreaId);
}

final _version = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}$');

/// True when [current] (e.g. "1.4.0" or "1.4.0+12") is older than
/// [minimum] ("1.5.0"). Unreadable versions never block anyone.
bool isOlderVersion(String current, String? minimum) {
  if (minimum == null) return false;
  List<int>? parts(String v) {
    final m = RegExp(r'^(\d+)\.(\d+)\.(\d+)').firstMatch(v.trim());
    return m == null ? null : [for (var i = 1; i <= 3; i++) int.parse(m[i]!)];
  }

  final a = parts(current);
  final b = parts(minimum);
  if (a == null || b == null) return false;
  for (var i = 0; i < 3; i++) {
    if (a[i] != b[i]) return a[i] < b[i];
  }
  return false;
}

enum AnnouncementTone { info, warning, offer }

/// `config/app`: support contacts and the Home announcement bar, edited in
/// the admin's Store settings (functions/src/admin/settings_model.ts).
@freezed
abstract class AppConfig with _$AppConfig {
  const factory AppConfig({
    /// +91 and 10 digits, or null.
    String? supportPhone,
    String? whatsappNumber,
    String? supportEmail,
    @Default(false) bool announcementEnabled,
    @Default('') String announcementText,
    @Default(AnnouncementTone.info) AnnouncementTone announcementTone,
  }) = _AppConfig;

  const AppConfig._();

  static const empty = AppConfig();

  factory AppConfig.fromMap(Map<String, dynamic>? d) {
    if (d == null) return empty;
    String? s(Object? v) => v is String && v.trim().isNotEmpty ? v : null;
    final a = d['announcement'] is Map ? d['announcement'] as Map : const {};
    return AppConfig(
      supportPhone: s(d['supportPhone']),
      whatsappNumber: s(d['whatsappNumber']),
      supportEmail: s(d['supportEmail']),
      announcementEnabled: a['enabled'] == true,
      announcementText: s(a['text']) ?? '',
      announcementTone: switch (a['tone']) {
        'warning' => AnnouncementTone.warning,
        'offer' => AnnouncementTone.offer,
        _ => AnnouncementTone.info,
      },
    );
  }

  /// The announcement to show, or null.
  String? get announcement =>
      announcementEnabled && announcementText.trim().isNotEmpty
      ? announcementText.trim()
      : null;
}

/// Digits for wa.me / tel: links ("919830012345"): the admin's number,
/// else the build's SUPPORT_PHONE, else "".
String supportDigits(String? configured, String buildDefault) {
  final digits = (configured ?? '').replaceAll(RegExp(r'\D'), '');
  return digits.isNotEmpty
      ? digits
      : buildDefault.replaceAll(RegExp(r'\D'), '');
}
