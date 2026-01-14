// amenities_kenya/services/mock_chat_service.dart
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amenities_kenya/models/chat_session.dart';
import 'package:amenities_kenya/models/message.dart';
import 'package:amenities_kenya/constants.dart';
import 'package:amenities_kenya/models/user.dart';

/// A service to interact with chat functionalities via API.
/// This service requires a user type to determine which authentication token to use.
class MockChatService {
  final ApiClient _apiClient;

  MockChatService(this._apiClient);

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Fetches a specific chat session's history using the API.
  /// This method is deprecated as getDelivererChatSessions will fetch all chats
  /// and the UI/provider will filter. A direct by-ID fetch would require a backend
  /// change to return a single chat for a specific ID.
  @Deprecated('Use getDelivererChatSessions and filter, or a specific getChatSessionById if backend supports.')
  Future<ChatSession?> getChatSession({String? chatId}) async {
    throw UnimplementedError('This method is deprecated. Use getDelivererChatSessions or createChatSession.');
  }

  /// Fetches all chat sessions for the authenticated deliverer.
  Future<List<ChatSession>> geUserChatSessions() async {
    final headers = await _getAuthHeaders();
    final response = await _apiClient.post(
      '/users/chats', // This endpoint returns a list of chats
      headers: headers,
      {},
    );

    if (response['result_code'] == 1) {
      if (response['chats'] is List) {
        return (response['chats'] as List)
            .map((chatJson) => ChatSession.fromJson(chatJson as Map<String, dynamic>))
            .toList();
      } else {
        // If result_code is 1 but 'chats' is not a list, it's an unexpected format.
        // A more robust backend would always return a list (even empty).
        print('Warning: Backend returned result_code 1 but "chats" was not a list for /deliverers/chats.');
        return []; // Return an empty list to avoid throwing
      }
    } else {
      throw Exception(response['message'] ?? 'Failed to fetch deliverer chat sessions.');
    }
  }

  /// Creates a new chat session for a given order and user.
  /// Returns the newly created ChatSession object, or null if chat_session is not returned
  /// despite result_code being 1. Throws an exception if result_code is 0.
  /// 
/// Sends a new message to a chat session using the API.
  Future<void> sendMessage({
    required String chatId,
    required String content,
  }) async {
    final headers = await _getAuthHeaders();
    final response = await _apiClient.post(
      '/users/send-message',
      headers: headers,
      {
        'chat_id': chatId,
        'content': content,
      },
    );

    if (response['result_code'] != 1) {
      throw Exception(response['message'] ?? 'Failed to send message.');
    }
  }

  // The following methods are not directly supported by the provided Postman collection APIs for chat.
  // The API focuses on fetching history for a specific chat ID and sending messages within it.
  // Listing all chat sessions for a user/deliverer or explicitly creating new ones
  // are assumed to be handled implicitly by other parts of the backend
  // (e.g., chat sessions are created when an order is placed and linked to it).

  /// Not implemented: There is no direct API to list all chat sessions for a given user.
  /// Chat sessions are typically linked to specific orders or interactions.
  Future<List<ChatSession>> getChatSessionsForUser(String userId) async {
    throw UnimplementedError('getChatSessionsForUser is not supported by current API definition.');
  }

  /// Not implemented: There is no direct API to list all chat sessions for a given deliverer.
  /// Chat sessions are typically linked to specific orders or interactions.
  Future<List<ChatSession>> getChatSessionsForDeliverer(String delivererId) async {
    throw UnimplementedError('getChatSessionsForDeliverer is not supported by current API definition.');
  }
}