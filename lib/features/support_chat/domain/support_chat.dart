import 'package:freezed_annotation/freezed_annotation.dart';

part 'support_chat.freezed.dart';

/// Who is answering: the bot, nobody yet (handed off), a person, or no one.
enum SupportChatStatus { bot, waitingAgent, agent, closed }

enum SupportSender { user, bot, agent, system }

/// supportChats/{chatId}: one per customer per order, plus a general one.
/// Opened by the openSupportChat function (functions/src/support/chat.ts).
@freezed
abstract class SupportChat with _$SupportChat {
  const factory SupportChat({
    required String id,
    required SupportChatStatus status,
    String? orderId,
    @Default(0) int unreadByUser,
  }) = _SupportChat;
}

/// A tappable chip under a bot message: `kb:<topic>` asks that topic,
/// [SupportQuickReply.agentId] hands the chat to a person.
@freezed
abstract class SupportQuickReply with _$SupportQuickReply {
  const SupportQuickReply._();

  const factory SupportQuickReply({required String id, required String label}) =
      _SupportQuickReply;

  static const agentId = 'agent';

  bool get isAgent => id == agentId;
}

@freezed
abstract class SupportMessage with _$SupportMessage {
  const factory SupportMessage({
    required String id,
    required SupportSender from,
    required String text,

    /// Null while the customer's own message is still pending the server.
    DateTime? createdAt,
    @Default([]) List<SupportQuickReply> quickReplies,

    /// The hand-off message: show WhatsApp / Call buttons under it.
    @Default(false) bool showContactOptions,
  }) = _SupportMessage;
}
