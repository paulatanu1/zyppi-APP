import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/features/support_chat/application/support_chat_providers.dart';
import 'package:zippy/features/support_chat/domain/support_chat.dart';
import 'package:zippy/features/support_chat/domain/support_chat_repository.dart';
import 'package:zippy/features/support_chat/presentation/support_chat_screen.dart';

import '../helpers/localized_app.dart';

class _FakeSupport implements SupportChatRepository {
  _FakeSupport({
    this.status = SupportChatStatus.bot,
    List<SupportMessage>? messages,
    this.openFails = false,
    this.openCompleter,
  }) : messages = messages ?? [];

  SupportChatStatus status;
  final List<SupportMessage> messages;
  final bool openFails;
  final Completer<String>? openCompleter;

  final sent = <(String, String?)>[];
  var agentRequests = 0;
  var opens = 0;

  @override
  Future<String> open({String? orderId, required String locale}) {
    opens++;
    if (openCompleter != null) return openCompleter!.future;
    if (openFails) return Future.error(Exception('offline'));
    return Future.value('chat-1');
  }

  @override
  Stream<SupportChat> watchChat(String chatId) =>
      Stream.value(SupportChat(id: chatId, status: status));

  @override
  Stream<List<SupportMessage>> watchMessages(String chatId) =>
      Stream.value(messages);

  @override
  Future<void> send(String chatId, String text, {String? quickReplyId}) async =>
      sent.add((text, quickReplyId));

  @override
  Future<void> requestAgent(String chatId) async => agentRequests++;

  @override
  Future<void> markRead(String chatId) async {}
}

SupportMessage _msg(
  String id,
  SupportSender from,
  String text, {
  List<SupportQuickReply> replies = const [],
  bool contact = false,
}) => SupportMessage(
  id: id,
  from: from,
  text: text,
  createdAt: DateTime(2026, 11, 6, 12),
  quickReplies: replies,
  showContactOptions: contact,
);

final _conversation = [
  _msg(
    '1',
    SupportSender.bot,
    'Hi! I’m Zyppi’s assistant. How can I help with order #3F2A9C1B?',
  ),
  _msg('2', SupportSender.user, 'Where is my order?'),
  _msg(
    '3',
    SupportSender.bot,
    'Order #3F2A9C1B is on its way to you. It should reach you in about 7 min.',
    replies: const [
      SupportQuickReply(id: 'kb:late_order', label: 'My order is late'),
      SupportQuickReply(id: 'agent', label: 'Talk to a person'),
    ],
  ),
];

Future<_FakeSupport> _pump(
  WidgetTester tester,
  _FakeSupport fake, {
  ThemeData? theme,
  double textScale = 1,
}) async {
  final container = ProviderContainer(
    overrides: [supportChatRepositoryProvider.overrideWithValue(fake)],
  );
  addTearDown(container.dispose);
  await pumpLocalizedApp(
    tester,
    container: container,
    home: const SupportChatScreen(orderId: '3f2a9c1b-0000-4000-8000-0000'),
    theme: theme,
    textScale: textScale,
    // The typing dots loop forever otherwise.
    disableAnimations: true,
  );
  return fake;
}

void main() {
  testWidgets('shows a skeleton while the chat opens', (tester) async {
    final opening = Completer<String>();
    await _pump(tester, _FakeSupport(openCompleter: opening));
    expect(find.text('Zyppi support'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    opening.complete('chat-1');
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('retries when the chat fails to open', (tester) async {
    final fake = await _pump(tester, _FakeSupport(openFails: true));
    expect(find.textContaining("Couldn't open the chat"), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(fake.opens, 2);
  });

  testWidgets('shows the conversation with chips under the last reply', (
    tester,
  ) async {
    final fake = await _pump(tester, _FakeSupport(messages: _conversation));
    expect(find.text('Where is my order?'), findsOneWidget);
    expect(find.textContaining('on its way to you'), findsOneWidget);
    expect(find.textContaining('Order #3F2A9C1B'), findsWidgets);
    expect(find.byType(ZChip), findsNWidgets(2));

    await tester.tap(find.text('My order is late'));
    await tester.pumpAndSettle();
    expect(fake.sent, [('My order is late', 'kb:late_order')]);

    await tester.tap(find.widgetWithText(ZChip, 'Talk to a person'));
    await tester.pumpAndSettle();
    expect(fake.agentRequests, 1);
  });

  testWidgets('sends typed messages', (tester) async {
    final fake = await _pump(tester, _FakeSupport(messages: _conversation));
    await tester.enterText(find.byType(TextField), '  Do you take UPI?  ');
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();
    expect(fake.sent, [('Do you take UPI?', null)]);
    expect(find.text('Do you take UPI?'), findsNothing); // field cleared
  });

  testWidgets('shows typing while the bot owes a reply', (tester) async {
    await _pump(tester, _FakeSupport(messages: _conversation.take(2).toList()));
    expect(find.bySemanticsLabel('Assistant is typing'), findsOneWidget);
  });

  testWidgets('after hand-off: no chips, no person button, waiting status', (
    tester,
  ) async {
    await _pump(
      tester,
      _FakeSupport(
        status: SupportChatStatus.waitingAgent,
        messages: [
          ..._conversation,
          _msg(
            '4',
            SupportSender.system,
            'I’ve passed this chat to our team.',
            contact: true,
          ),
        ],
      ),
    );
    expect(find.textContaining('Connecting you to our team'), findsOneWidget);
    expect(find.byType(ZChip), findsNothing);
    expect(find.byTooltip('Talk to a person'), findsNothing);
    expect(find.text('I’ve passed this chat to our team.'), findsOneWidget);
  });

  testWidgets('a closed chat hides the composer', (tester) async {
    await _pump(
      tester,
      _FakeSupport(status: SupportChatStatus.closed, messages: _conversation),
    );
    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining('This chat is closed'), findsOneWidget);
  });

  testWidgets('empty chat shows the welcome hint', (tester) async {
    await _pump(tester, _FakeSupport());
    expect(
      find.textContaining('Ask anything about your orders'),
      findsOneWidget,
    );
  });

  for (final dark in [false, true]) {
    testWidgets('no overflow at 2× text (${dark ? 'dark' : 'light'})', (
      tester,
    ) async {
      await _pump(
        tester,
        _FakeSupport(
          status: SupportChatStatus.waitingAgent,
          messages: [
            ..._conversation,
            _msg('4', SupportSender.agent, 'Hi, this is Riya from Zyppi.'),
          ],
        ),
        theme: dark ? ZyppiTheme.dark : ZyppiTheme.light,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Zyppi team'), findsOneWidget);
    });
  }
}
