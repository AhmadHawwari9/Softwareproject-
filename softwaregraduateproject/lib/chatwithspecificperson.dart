import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String userEmail;
  final String jwtToken;

  ChatScreen({required this.otherUserId, required this.userEmail, required this.jwtToken});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = true; // Flag to check if user is at the bottom

  @override
  void initState() {
    super.initState();
    print("Other User ID: ${widget.otherUserId}");
    _fetchMessages();
    _scrollController.addListener(() {
      // Update the flag based on scroll position
      _isAtBottom = _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50;
    });
  }

  Future<void> _fetchMessages() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3001/chat/receive/${widget.otherUserId}'),
      headers: {
        'Authorization': 'Bearer ${widget.jwtToken}',
      },
    );

    if (response.statusCode == 200) {
      print("Messages fetched: ${response.body}");
      List<dynamic> newMessages = json.decode(response.body);
      setState(() {
        messages = newMessages;
      });
      // Scroll to bottom after fetching messages
      _scrollToBottom();
    } else {
      print("Failed to load messages: ${response.statusCode} - ${response.body}");
    }
  }

  String _formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) {
      print("Message cannot be empty.");
      return; // Prevent sending an empty message
    }

    // Create a new message object
    final newMessage = {
      'sender_email': 'You',
      'receiver_id': widget.otherUserId,
      'message': _messageController.text,
      'timestamp': DateTime.now().toString(),
    };

    // Add the new message to the local messages list immediately
    setState(() {
      messages.add(newMessage);
    });

    // Scroll to the bottom if the user is at the bottom
    if (_isAtBottom) {
      _scrollToBottom();
    }

    // Clear the message input
    _messageController.clear();

    // Send the message to the server
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3001/chat/send'),
      headers: {
        'Authorization': 'Bearer ${widget.jwtToken}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'sender_id': widget.userEmail,
        'receiver_id': widget.otherUserId,
        'message': newMessage['message'],
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      print("Failed to send message: ${response.statusCode} - ${response.body}");
    }
  }

  void _scrollToBottom() {
    // Check if the controller has any listeners
    if (_scrollController.hasClients) {
      // Use the SchedulerBinding to ensure scrolling occurs after the widget has built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent); // Scroll to the bottom
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(widget.userEmail),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                bool isSentByMe = message['sender_email'] == 'You';

                String senderEmail = isSentByMe ? 'You' : (message['sender_email'] ?? 'Unknown');
                String formattedDateTime = message['timestamp'] != null
                    ? _formatDateTime(message['timestamp'])
                    : _formatDateTime(DateTime.now().toString());

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        senderEmail,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSentByMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message['message'] ?? 'No text',
                          style: TextStyle(color: isSentByMe ? Colors.white : Colors.black),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        formattedDateTime,
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
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
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
