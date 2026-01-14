import 'package:uuid/uuid.dart';

/// Represents a single chat message in a conversation.
class Message {
  final String messageId;
  final String chatId; // Added: Present in sample JSON
  final String senderId; // Can be user ID or deliverer ID
  final String senderType; // Added: Present in sample JSON (e.g., 'deliverer', 'user')
  final String content;
  final DateTime timestamp;
  final bool isDeleted; // Added: Present in sample JSON

  Message({
    String? messageId,
    required this.chatId, // Now required in constructor
    required this.senderId,
    required this.senderType, // Now required in constructor
    required this.content,
    required this.timestamp,
    this.isDeleted = false, // Added with default value
  }) : messageId = messageId ?? const Uuid().v4();

  /// Factory constructor to create a Message from a JSON map.
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['message_id'] as String,
      chatId: json['chat_id'] as String, // Parsing chatId
      senderId: json['sender_id'] as String,
      senderType: json['sender_type'] as String, // Parsing senderType
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false, // Parsing isDeleted with null-safety
    );
  }

  /// Converts the Message object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'chat_id': chatId, // Include chatId in JSON
      'sender_id': senderId,
      'sender_type': senderType, // Include senderType in JSON
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'is_deleted': isDeleted, // Include isDeleted in JSON
    };
  }
}
