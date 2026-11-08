import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/launch.dart';
import 'package:zippy/core/utils/order_id.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/support_chat/application/support_chat_providers.dart';
import 'package:zippy/features/support_chat/domain/support_chat.dart';

/// In-app support: the Zyppi assistant answers first (a free retrieval
/// bot in Cloud Functions — functions/src/support), then hands off to the
/// team, with WhatsApp / Call as the fallback. Opened from order tracking
/// (about that order) and from Help (general).
class SupportChatScreen extends ConsumerWidget {
  const SupportChatScreen({super.key, this.orderId});

  final String? orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = (orderId: orderId, locale: context.locale.toString());
    final open = ref.watch(openSupportChatProvider(request));

    return Scaffold(
      backgroundColor: context.z.bg,
      body: SafeArea(
        child: open.value != null
            ? _ChatView(chatId: open.value!, orderId: orderId)
            : Column(
                children: [
                  _Header(orderId: orderId, chat: null),
                  Expanded(
                    child: open.hasError
                        ? _Problem(
                            message: 'supportOpenError'.tr(),
                            onRetry: () => ref.invalidate(
                              openSupportChatProvider(request),
                            ),
                          )
                        : const _MessagesSkeleton(),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ChatView extends ConsumerStatefulWidget {
  const _ChatView({required this.chatId, required this.orderId});

  final String chatId;
  final String? orderId;

  @override
  ConsumerState<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<_ChatView> {
  final _input = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send(String text, {String? quickReplyId}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(supportChatRepositoryProvider)
          .send(widget.chatId, trimmed, quickReplyId: quickReplyId);
      if (quickReplyId == null) _input.clear();
    } catch (_) {
      showError('supportSendError'.tr());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _requestAgent() async {
    try {
      await ref.read(supportChatRepositoryProvider).requestAgent(widget.chatId);
    } catch (_) {
      showError('supportSendError'.tr());
    }
  }

  void _onQuickReply(SupportQuickReply reply) => reply.isAgent
      ? _requestAgent()
      : _send(reply.label, quickReplyId: reply.id);

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(supportChatProvider(widget.chatId)).value;
    final messagesAsync = ref.watch(supportMessagesProvider(widget.chatId));
    final messages = messagesAsync.value;

    ref.listen(supportChatProvider(widget.chatId), (_, next) {
      if ((next.value?.unreadByUser ?? 0) > 0) {
        ref.read(supportChatRepositoryProvider).markRead(widget.chatId);
      }
    });

    final status = chat?.status ?? SupportChatStatus.bot;
    final closed = status == SupportChatStatus.closed;

    return Column(
      children: [
        _Header(
          orderId: widget.orderId,
          chat: chat,
          onTalkToPerson: status == SupportChatStatus.bot
              ? _requestAgent
              : null,
        ),
        Expanded(
          child: messages != null
              ? _Messages(
                  messages: messages,
                  typing:
                      status == SupportChatStatus.bot &&
                      messages.isNotEmpty &&
                      messages.last.from == SupportSender.user,
                  quickRepliesEnabled: status == SupportChatStatus.bot,
                  onQuickReply: _onQuickReply,
                )
              : messagesAsync.hasError
              ? _Problem(
                  message: 'supportLoadError'.tr(),
                  onRetry: () =>
                      ref.invalidate(supportMessagesProvider(widget.chatId)),
                )
              : const _MessagesSkeleton(),
        ),
        if (closed)
          Padding(
            padding: const EdgeInsets.all(ZSpace.screen),
            child: Text(
              'supportClosedNote'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        else
          _Composer(
            controller: _input,
            sending: _sending,
            onSend: () => _send(_input.text),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.orderId,
    required this.chat,
    this.onTalkToPerson,
  });

  final String? orderId;
  final SupportChat? chat;
  final VoidCallback? onTalkToPerson;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final (statusLabel, statusColor) = switch (chat?.status) {
      SupportChatStatus.waitingAgent => ('supportStatusWaiting'.tr(), z.warn),
      SupportChatStatus.agent => ('supportStatusAgent'.tr(), z.ok),
      SupportChatStatus.closed => ('supportStatusClosed'.tr(), z.ink3),
      _ => ('supportStatusBot'.tr(), z.ok),
    };

    return Material(
      color: z.surface,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: z.line)),
        ),
        padding: const EdgeInsets.fromLTRB(
          ZSpace.x1,
          ZSpace.x2,
          ZSpace.x2,
          ZSpace.x2,
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'back'.tr(),
              constraints: const BoxConstraints.tightFor(
                width: ZSize.touch,
                height: ZSize.touch,
              ),
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/navBar'),
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: z.ink),
            ),
            CircleAvatar(
              radius: 20,
              backgroundColor: z.brandSoft,
              child: Icon(Icons.support_agent_rounded, color: z.brandText),
            ),
            const SizedBox(width: ZSpace.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'supportChatTitle'.tr(),
                    style: t.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: ZSpace.x1),
                      Flexible(
                        child: Text(
                          orderId == null
                              ? statusLabel
                              : '$statusLabel · ${'supportAboutOrder'.tr(args: [shortOrderId(orderId!)])}',
                          style: t.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onTalkToPerson != null)
              IconButton(
                tooltip: 'supportTalkToPerson'.tr(),
                constraints: const BoxConstraints.tightFor(
                  width: ZSize.touch,
                  height: ZSize.touch,
                ),
                onPressed: onTalkToPerson,
                icon: Icon(Icons.headset_mic_outlined, color: z.ink),
              ),
          ],
        ),
      ),
    );
  }
}

class _Messages extends StatelessWidget {
  const _Messages({
    required this.messages,
    required this.typing,
    required this.quickRepliesEnabled,
    required this.onQuickReply,
  });

  final List<SupportMessage> messages;
  final bool typing;
  final bool quickRepliesEnabled;
  final ValueChanged<SupportQuickReply> onQuickReply;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(ZSpace.x6),
          child: Text(
            'supportEmpty'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    // Newest at the bottom; reversed so the list starts scrolled there.
    final items = <Widget>[
      if (typing) const _Typing(key: ValueKey('typing')),
      for (var i = messages.length - 1; i >= 0; i--)
        ZEntrance(
          key: ValueKey(messages[i].id),
          child: _MessageTile(
            message: messages[i],
            // Chips only under the newest message, while the bot answers.
            quickReplies: i == messages.length - 1 && quickRepliesEnabled
                ? messages[i].quickReplies
                : const [],
            onQuickReply: onQuickReply,
          ),
        ),
    ];
    return ListView.separated(
      reverse: true,
      padding: const EdgeInsets.all(ZSpace.screen),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: ZSpace.x3),
      itemBuilder: (_, i) => items[i],
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    required this.message,
    required this.quickReplies,
    required this.onQuickReply,
  });

  final SupportMessage message;
  final List<SupportQuickReply> quickReplies;
  final ValueChanged<SupportQuickReply> onQuickReply;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;

    if (message.from == SupportSender.system) {
      return Container(
        padding: const EdgeInsets.all(ZSpace.x3),
        decoration: BoxDecoration(
          color: z.blueSoft,
          borderRadius: ZRadius.all(ZRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              message.text,
              textAlign: TextAlign.center,
              style: t.bodyMedium!.copyWith(color: z.ink),
            ),
            if (message.showContactOptions) const _ContactOptions(),
          ],
        ),
      );
    }

    final mine = message.from == SupportSender.user;
    final bubble = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * .78,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ZSpace.x4,
          vertical: ZSpace.x3,
        ),
        decoration: BoxDecoration(
          color: mine ? z.brand : z.surface,
          border: mine ? null : Border.all(color: z.line),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(ZRadius.card),
            topRight: const Radius.circular(ZRadius.card),
            bottomLeft: Radius.circular(mine ? ZRadius.card : ZRadius.badge),
            bottomRight: Radius.circular(mine ? ZRadius.badge : ZRadius.card),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.from == SupportSender.agent)
              Padding(
                padding: const EdgeInsets.only(bottom: ZSpace.x1),
                child: Text(
                  'supportStatusAgent'.tr(),
                  style: t.labelSmall!.copyWith(color: z.brandText),
                ),
              ),
            Text(
              message.text,
              style: t.bodyLarge!.copyWith(color: mine ? z.onBrand : z.ink),
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: mine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        bubble,
        if (quickReplies.isNotEmpty) ...[
          const SizedBox(height: ZSpace.x2),
          Wrap(
            spacing: ZSpace.x2,
            runSpacing: ZSpace.x2,
            children: [
              for (final reply in quickReplies)
                ZChip(
                  label: reply.label,
                  icon: reply.isAgent ? Icons.headset_mic_outlined : null,
                  onTap: () => onQuickReply(reply),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// WhatsApp / Call buttons under the hand-off message (same numbers as
/// the Help sheet).
class _ContactOptions extends StatelessWidget {
  const _ContactOptions();

  @override
  Widget build(BuildContext context) {
    final phone = Env.supportPhone;
    if (phone.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: ZSpace.x3),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: ZSpace.x2,
        runSpacing: ZSpace.x2,
        children: [
          OutlinedButton.icon(
            onPressed: () =>
                openExternal(whatsAppUri(phone, message: 'helpMessage'.tr())),
            icon: const Icon(Icons.chat_outlined),
            label: Text('helpWhatsApp'.tr()),
          ),
          OutlinedButton.icon(
            onPressed: () => openExternal(phoneUri('+$phone')),
            icon: const Icon(Icons.call_outlined),
            label: Text('helpCall'.tr()),
          ),
        ],
      ),
    );
  }
}

class _Typing extends StatelessWidget {
  const _Typing({super.key});

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Semantics(
      label: 'supportTyping'.tr(),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ZSpace.x4,
            vertical: ZSpace.x3,
          ),
          decoration: BoxDecoration(
            color: z.surface,
            border: Border.all(color: z.line),
            borderRadius: ZRadius.all(ZRadius.card),
          ),
          child: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: ZSpace.x1),
                  ZLoop(
                    phase: i / 3,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: z.ink3,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Material(
      color: z.surface,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: z.line)),
        ),
        padding: const EdgeInsets.fromLTRB(
          ZSpace.screen,
          ZSpace.x2,
          ZSpace.x2,
          ZSpace.x2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                maxLength: 1000,
                textInputAction: TextInputAction.send,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'supportComposerHint'.tr(),
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(width: ZSpace.x2),
            IconButton.filled(
              tooltip: 'supportSend'.tr(),
              style: IconButton.styleFrom(
                backgroundColor: z.brand,
                foregroundColor: z.onBrand,
                minimumSize: const Size.square(ZSize.input),
                shape: RoundedRectangleBorder(
                  borderRadius: ZRadius.all(ZRadius.input),
                ),
              ),
              onPressed: sending ? null : onSend,
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesSkeleton extends StatelessWidget {
  const _MessagesSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ZSpace.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ZSkeleton(width: 240, height: 64),
          const SizedBox(height: ZSpace.x3),
          Align(
            alignment: Alignment.centerRight,
            child: const ZSkeleton(width: 160, height: 44),
          ),
          const SizedBox(height: ZSpace.x3),
          const ZSkeleton(width: 200, height: 44),
        ],
      ),
    );
  }
}

class _Problem extends StatelessWidget {
  const _Problem({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ZSpace.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: ZSpace.x3),
            TextButton(onPressed: onRetry, child: Text('retry'.tr())),
          ],
        ),
      ),
    );
  }
}
