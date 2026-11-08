import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/firebase/firebase_setup.dart';
import 'package:zippy/features/support_chat/data/firebase_support_chat_repository.dart';
import 'package:zippy/features/support_chat/data/mock_support_chat_repository.dart';
import 'package:zippy/features/support_chat/domain/support_chat.dart';
import 'package:zippy/features/support_chat/domain/support_chat_repository.dart';

final supportChatRepositoryProvider = Provider<SupportChatRepository>(
  (ref) => Env.isMockDataSource
      ? MockSupportChatRepository()
      : FirebaseSupportChatRepository(
          FirebaseFirestore.instance,
          zyppiFunctions(),
        ),
);

/// Which chat to open: about an order, or the general one (null).
typedef SupportChatRequest = ({String? orderId, String locale});

/// Opens the chat. No automatic retry: the screen shows the error and a
/// Retry button (which invalidates this).
final openSupportChatProvider = FutureProvider.autoDispose
    .family<String, SupportChatRequest>(
      (ref, request) => ref
          .watch(supportChatRepositoryProvider)
          .open(orderId: request.orderId, locale: request.locale),
      retry: (_, _) => null,
    );

final supportChatProvider = StreamProvider.autoDispose
    .family<SupportChat, String>(
      (ref, chatId) =>
          ref.watch(supportChatRepositoryProvider).watchChat(chatId),
    );

final supportMessagesProvider = StreamProvider.autoDispose
    .family<List<SupportMessage>, String>(
      (ref, chatId) =>
          ref.watch(supportChatRepositoryProvider).watchMessages(chatId),
    );
