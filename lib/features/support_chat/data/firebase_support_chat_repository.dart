import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:zippy/features/support_chat/domain/support_chat.dart';
import 'package:zippy/features/support_chat/domain/support_chat_repository.dart';

/// Chats are opened and handed off through Cloud Functions; the app only
/// adds the customer's own messages (firestore.rules → supportChats).
class FirebaseSupportChatRepository implements SupportChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  FirebaseSupportChatRepository(this.firestore, this.functions);

  DocumentReference<Map<String, dynamic>> _chat(String id) =>
      firestore.collection('supportChats').doc(id);

  @override
  Future<String> open({String? orderId, required String locale}) async {
    final result = await functions.httpsCallable('openSupportChat').call({
      'orderId': orderId,
      'locale': locale,
    });
    return (result.data as Map)['chatId'] as String;
  }

  @override
  Stream<SupportChat> watchChat(String chatId) =>
      _chat(chatId).snapshots().where((s) => s.exists).map((s) {
        final d = s.data()!;
        return SupportChat(
          id: s.id,
          status: _status(d['status'] as String?),
          orderId: d['orderId'] as String?,
          unreadByUser: (d['unreadByUser'] as num?)?.toInt() ?? 0,
        );
      });

  @override
  Stream<List<SupportMessage>> watchMessages(String chatId) =>
      _chat(chatId)
          .collection('messages')
          .orderBy('createdAt')
          .snapshots()
          .map((snap) => snap.docs.map(_message).toList());

  @override
  Future<void> send(String chatId, String text, {String? quickReplyId}) =>
      _chat(chatId).collection('messages').add({
        'from': 'user',
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'quickReplyId': ?quickReplyId,
      });

  @override
  Future<void> requestAgent(String chatId) =>
      functions.httpsCallable('requestSupportAgent').call({'chatId': chatId});

  @override
  Future<void> markRead(String chatId) =>
      _chat(chatId).update({'unreadByUser': 0});
}

SupportChatStatus _status(String? value) => switch (value) {
  'waiting_agent' => SupportChatStatus.waitingAgent,
  'agent' => SupportChatStatus.agent,
  'closed' => SupportChatStatus.closed,
  _ => SupportChatStatus.bot,
};

SupportMessage _message(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  final d = doc.data();
  final replies = d['quickReplies'];
  return SupportMessage(
    id: doc.id,
    from: switch (d['from']) {
      'user' => SupportSender.user,
      'agent' => SupportSender.agent,
      'system' => SupportSender.system,
      _ => SupportSender.bot,
    },
    text: d['text'] as String? ?? '',
    createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    quickReplies: replies is List
        ? [
            for (final r in replies.whereType<Map>())
              SupportQuickReply(
                id: r['id'] as String? ?? '',
                label: r['label'] as String? ?? '',
              ),
          ]
        : const [],
    showContactOptions: d['action'] == 'contact_options',
  );
}
