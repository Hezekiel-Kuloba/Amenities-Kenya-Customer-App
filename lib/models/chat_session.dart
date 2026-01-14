import 'package:amenities_kenya/models/message.dart'; // Import the Message model
import 'package:uuid/uuid.dart';

/// Represents a chat session between a user and a deliverer for a specific order.
class ChatSession {
  final String chatId;
  final String orderId;
  final String userId;
  final String delivererId;
  final List<Message> messages;
  final DateTime createdAt;
  DateTime lastUpdatedAt;

  ChatSession({
    String? chatId,
    required this.orderId,
    required this.userId,
    required this.delivererId,
    List<Message>? messages,
    required this.createdAt,
    DateTime? lastUpdatedAt,
  })  : chatId = chatId ?? const Uuid().v4(),
        messages = messages ?? [],
        lastUpdatedAt = lastUpdatedAt ?? createdAt;

  /// Factory constructor to create a ChatSession from a JSON map.
  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      chatId: json['chat_id'],
      orderId: json['order_id'],
      userId: json['user_id'],
      delivererId: json['deliverer_id'],
      messages: (json['messages'] as List<dynamic>?)
              ?.map((msgJson) => Message.fromJson(msgJson as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at']),
      lastUpdatedAt: DateTime.parse(json['last_updated_at']),
    );
  }

  /// Converts the ChatSession object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'order_id': orderId,
      'user_id': userId,
      'deliverer_id': delivererId,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'last_updated_at': lastUpdatedAt.toIso8601String(),
    };
  }

  /// Creates a new ChatSession instance with updated values.
  ChatSession copyWith({
    String? chatId,
    String? orderId,
    String? userId,
    String? delivererId,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
  }) {
    return ChatSession(
      chatId: chatId ?? this.chatId,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      delivererId: delivererId ?? this.delivererId,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}
