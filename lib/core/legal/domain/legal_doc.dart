import 'package:freezed_annotation/freezed_annotation.dart';

part 'legal_doc.freezed.dart';

/// The legal documents the server knows (functions/src/legal/model.ts).
abstract final class LegalTypes {
  static const customerTerms = 'customer_terms';
  static const privacyPolicy = 'privacy_policy';
  static const refundPolicy = 'refund_policy';

  /// What a customer accepts, in the order shown.
  static const forCustomer = [customerTerms, privacyPolicy, refundPolicy];

  /// Translation key for a document's short name.
  static String labelKey(String type) => switch (type) {
    customerTerms => 'legalTerms',
    privacyPolicy => 'legalPrivacy',
    refundPolicy => 'legalRefund',
    _ => 'legalTerms',
  };
}

/// A published version the signed-in user still has to accept
/// (legalStatus callable).
@freezed
abstract class PendingLegalDoc with _$PendingLegalDoc {
  const factory PendingLegalDoc({
    required String type,
    required int version,
    required String title,
    required String sha256,
  }) = _PendingLegalDoc;
}

/// The text of a document's live version, in one language.
@freezed
abstract class LegalDocText with _$LegalDocText {
  const factory LegalDocText({
    required String type,
    required int version,
    required String title,

    /// Markdown.
    required String body,
  }) = _LegalDocText;
}
