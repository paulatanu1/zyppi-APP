import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:zippy/features/support_chat/domain/support_chat.dart';
import 'package:zippy/features/support_chat/domain/support_chat_repository.dart';

/// Mock data source (no backend): the bot runs in Cloud Functions, so
/// here every message is answered with the hand-off note and the
/// WhatsApp / Call options.
class MockSupportChatRepository implements SupportChatRepository {
  final _messages = <SupportMessage>[];
  final _chat = StreamController<SupportChat>.broadcast();
  final _feed = StreamController<List<SupportMessage>>.broadcast();
  var _status = SupportChatStatus.bot;

  void _emit() {
    _chat.add(SupportChat(id: 'mock', status: _status));
    _feed.add(List.unmodifiable(_messages));
  }

  void _add(SupportSender from, String text, {bool contact = false}) {
    _messages.add(
      SupportMessage(
        id: '${_messages.length}',
        from: from,
        text: text,
        createdAt: DateTime.now(),
        showContactOptions: contact,
      ),
    );
  }

  @override
  Future<String> open({String? orderId, required String locale}) async =>
      'mock';

  @override
  Stream<SupportChat> watchChat(String chatId) async* {
    yield SupportChat(id: chatId, status: _status);
    yield* _chat.stream;
  }

  @override
  Stream<List<SupportMessage>> watchMessages(String chatId) async* {
    yield List.unmodifiable(_messages);
    yield* _feed.stream;
  }

  @override
  Future<void> send(String chatId, String text, {String? quickReplyId}) async {
    _add(SupportSender.user, text);
    if (_status == SupportChatStatus.bot) {
      _status = SupportChatStatus.waitingAgent;
      _add(SupportSender.system, 'supportHandoffOffline'.tr(), contact: true);
    }
    _emit();
  }

  @override
  Future<void> requestAgent(String chatId) async {
    if (_status != SupportChatStatus.bot) return;
    _status = SupportChatStatus.waitingAgent;
    _add(SupportSender.system, 'supportHandoffOffline'.tr(), contact: true);
    _emit();
  }

  @override
  Future<void> markRead(String chatId) async {}
}
