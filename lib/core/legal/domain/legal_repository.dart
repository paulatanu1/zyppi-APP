import 'package:zippy/core/legal/domain/legal_doc.dart';

/// Terms, privacy and refund policy: reading them and recording that the
/// customer accepted them. Server side: functions/src/legal.
abstract class LegalRepository {
  /// Documents the signed-in customer hasn't accepted in their live
  /// version (empty when everything is accepted or nothing is published).
  Future<List<PendingLegalDoc>> pending();

  /// The live text of [type] in [languageCode] (English when there is no
  /// translation); null when the document isn't published yet.
  Future<LegalDocText?> fetchText(String type, String languageCode);

  /// Records acceptance of exactly these versions. Throws when a document
  /// changed in the meantime, so the caller reloads [pending].
  Future<void> accept(List<PendingLegalDoc> docs);
}
