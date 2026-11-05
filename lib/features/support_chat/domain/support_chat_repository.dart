import 'package:zippy/features/support_chat/domain/support_chat.dart';

/// Support chat with the Zyppi bot / team. Screens use only this
/// interface; Firestore and Cloud Functions stay in the data layer.
abstract class SupportChatRepository {
  /// Opens (or reopens) the chat about [orderId], or the general chat,
  /// and returns its id. [locale] picks the greeting's language.
  Future<String> open({String? orderId, required String locale});

  Stream<SupportChat> watchChat(String chatId);

  /// Oldest first.
  Stream<List<SupportMessage>> watchMessages(String chatId);

  /// The bot replies server-side; [quickReplyId] when a chip was tapped.
  Future<void> send(String chatId, String text, {String? quickReplyId});

  /// "Talk to a person".
  Future<void> requestAgent(String chatId);

  Future<void> markRead(String chatId);
}
