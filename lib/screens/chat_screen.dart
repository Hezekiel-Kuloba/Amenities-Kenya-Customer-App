// amenities_kenya/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amenities_kenya/providers/chat_provider.dart';
import 'package:amenities_kenya/models/message.dart';
import 'package:amenities_kenya/models/order.dart'; // Import Order model
import 'package:amenities_kenya/providers/auth_provider.dart'; // To get current deliverer ID
import 'package:url_launcher/url_launcher.dart'; // For making calls

class ChatScreen extends ConsumerStatefulWidget {
  final Order order; // Now directly pass the Order object
  final String? otherParticipantPhoneNumber; // To allow calling the other participant

  const ChatScreen({
    super.key,
    required this.order,
    this.otherParticipantPhoneNumber,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late String _currentUserId; // Will be initialized in initState
  late String _otherParticipantId; // The user's ID from the order
  late String _chatTitle; // Derived from the order

  @override
  void initState() {
    super.initState();
    // Retrieve the current deliverer's ID from the auth provider
    final currentUser = ref.read(userProvider);
    if (currentUser == null || currentUser.userId!.isEmpty) {
      // Handle cases where deliverer ID is not available (e.g., not logged in)
      _currentUserId = ''; // Set to empty to prevent operations
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deliverer ID not found. Cannot open chat.')),
        );
        Navigator.of(context).pop(); // Go back if essential info is missing
      });
    } else {
      _currentUserId = currentUser.userId!;
    }

    _otherParticipantId = widget.order.assignedDelivererId!; // The user is the other participant
    // Assuming 'userName' is available in your Order model for display
    // If you have a user's name in Order model (e.g., widget.order.userName), use that for a better title
    _chatTitle = 'Chat with ${widget.order.assignedDelivererId}'; // Using userId for now

    // Scroll to the bottom after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty && _currentUserId.isNotEmpty) {
      // Call sendMessage on the provider, passing only senderId and content
      // The receiverId parameter has been removed from chat_provider's sendMessage
      ref.read(chatSessionProvider(widget.order).notifier).sendMessage(
            _currentUserId, // Sender: current deliverer
            text, // Content of the message
          );
      _messageController.clear();
      _scrollToBottom();
    } else if (_currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot send message: User ID is missing.')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch call to $phoneNumber')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the chat session provider using the Order object
    final chatSessionAsyncValue = ref.watch(chatSessionProvider(widget.order));

    return Scaffold(
      appBar: AppBar(
        title: Text(_chatTitle),
        actions: [
          // Show call button only if phone number is provided and not empty
          if (widget.otherParticipantPhoneNumber != null && widget.otherParticipantPhoneNumber!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.call),
              onPressed: () => _makePhoneCall(widget.otherParticipantPhoneNumber!),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatSessionAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
              data: (chatSession) {
                if (chatSession == null) {
                  return const Center(child: Text('No chat session found.'));
                }
                if (chatSession.messages.isEmpty) {
                  return const Center(child: Text('Start a conversation!'));
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: chatSession.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatSession.messages[index];
                    // Determine if the message was sent by the current deliverer
                    final isMe = message.senderId == _currentUserId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Theme.of(context).primaryColor : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12.0),
                            topRight: const Radius.circular(12.0),
                            // Apply rounded corner to the bottom-left if it's "me", else bottom-right
                            bottomLeft: isMe ? const Radius.circular(12.0) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(12.0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.content,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: isMe ? Colors.white70 : Colors.black54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}