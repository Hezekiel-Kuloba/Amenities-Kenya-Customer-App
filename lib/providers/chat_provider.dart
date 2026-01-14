// amenities_kenya/providers/chat_provider.dart
import 'package:amenities_kenya/constants.dart';
import 'package:amenities_kenya/services/mock_chat_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amenities_kenya/models/chat_session.dart';
import 'package:amenities_kenya/models/message.dart';
import 'package:amenities_kenya/models/order.dart';

/// Provider for the actual MockChatService.
final chatServiceProvider = Provider<MockChatService>((ref) {
  return MockChatService(ApiClient());
});

/// StateNotifierProvider for a specific chat session, tied to an order.
/// Takes an Order object as an argument.
final chatSessionProvider = StateNotifierProvider.family<ChatSessionNotifier, AsyncValue<ChatSession?>, Order>((ref, order) {
  final chatService = ref.read(chatServiceProvider);
  return ChatSessionNotifier(chatService, order);
});

class ChatSessionNotifier extends StateNotifier<AsyncValue<ChatSession?>> {
  final MockChatService _chatService;
  final Order _order;

  ChatSessionNotifier(this._chatService, this._order) : super(const AsyncValue.loading()) {
    fetchChatSession();
  }

  /// Fetches the current chat session data from the API.
  /// If no chat_id exists for the order, it attempts to create one.
  /// If a chat_id exists but the chat is not found, it also attempts to create one.
  Future<void> fetchChatSession() async {
    // state = const AsyncValue.loading();
    try {
      ChatSession? chatSession;
      bool chatFound = false;

      // Always attempt to get all chats for the deliverer first.
      // This is necessary because the order.chatId might be null
      // or point to a chat not yet visible in the deliverer's list for some reason.
      final allChats = await _chatService.geUserChatSessions();
      
      // 1. Try to find the chat using _order.chatId if available
      if (_order.chatId != null && _order.chatId!.isNotEmpty) {
        try {
          chatSession = allChats.firstWhere(
            (chat) => chat.chatId == _order.chatId,
          );
          chatFound = true;
          print('Found existing chat using order.chatId: ${chatSession.chatId}');
        } catch (e) {
          // If firstWhere throws (chat not found in the list), log and proceed to next step
          print('Chat with ID ${_order.chatId} not found among deliverer chats. Error: $e');
        }
      }

      // 2. If chat was still not found by _order.chatId, try finding it by order_id and deliverer_id
      // This is a fallback in case order.chatId was missing/incorrect, but a chat for the order exists
      if (!chatFound) {
        try {
          // Add a null check for _order.assignedDelivererId
          if (_order.assignedDelivererId != null) {
            chatSession = allChats.firstWhere(
                (chat) => chat.orderId == _order.orderId && chat.delivererId == _order.assignedDelivererId!,
            );
            chatFound = true;
            print('Found existing chat by orderId and delivererId: ${chatSession.chatId}');
          } else {
            print('Cannot search by delivererId: _order.assignedDelivererId is null.');
          }
        } catch (e) {
            print('Chat for order ${_order.orderId} not found by orderId/delivererId. Error: $e');
        }
      }

      // Sort messages chronologically before setting the state
      if (chatSession != null) {
        chatSession.messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      }

      state = AsyncValue.data(chatSession);
    } catch (e, stack) {
      print('Error in fetchChatSession: $e, $stack');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Sends a message and then re-fetches the chat session to update the UI.
  Future<void> sendMessage(String senderId, String content) async {
    if (state.value == null || state.value?.chatId == null) {
      print('Chat session not available to send message. Cannot send message.');
      state = AsyncValue.error('Chat session not initialized.', StackTrace.current);
      return;
    }

    try {
      // Optimistic update: Temporarily add the message before API confirmation
      final currentChatSession = state.value!;
      final tempMessage = Message(
        chatId: currentChatSession.chatId,
        senderId: senderId,
        senderType: 'user',
        content: content,
        timestamp: DateTime.now(),
        isDeleted: false,
      );

      final updatedMessages = List<Message>.from(currentChatSession.messages)..add(tempMessage);
      // Sort the messages after adding the new one
      updatedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      state = AsyncValue.data(currentChatSession.copyWith(
        messages: updatedMessages,
        lastUpdatedAt: DateTime.now(),
      ));

      await _chatService.sendMessage(
        chatId: currentChatSession.chatId,
        content: content,
      );

      // After successful sending, re-fetch the chat session to get the official
      // message data (e.g., server-assigned timestamp, message ID).
      await fetchChatSession();
    } catch (e, stack) {
      print('Error sending message: $e, $stack');
      state = AsyncValue.error(e, stack);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}