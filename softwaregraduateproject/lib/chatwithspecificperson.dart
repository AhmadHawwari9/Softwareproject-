import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

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
  final FlutterTts _flutterTts = FlutterTts();
  bool _isAtBottom = true;


  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _scrollController.addListener(() {
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
      List<dynamic> newMessages = json.decode(response.body);
      setState(() {
        messages = newMessages;
      });
      _scrollToBottom();
    } else {
      print("Failed to load messages: ${response.statusCode} - ${response.body}");
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final newMessage = {
      'sender_email': 'You',
      'receiver_id': widget.otherUserId,
      'message': _messageController.text,
      'timestamp': DateTime.now().toString(),
    };

    setState(() {
      messages.add(newMessage);
    });

    if (_isAtBottom) _scrollToBottom();

    _messageController.clear();

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
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
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
                String formattedDateTime = _formatDateTime(
                  message['timestamp'] ?? DateTime.now().toString(),
                );

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
                      Row(
                        mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (isSentByMe)
                            IconButton(
                              icon: Icon(Icons.volume_up, color: Colors.blue),
                              onPressed: () => _speak(message['message'] ?? ''),
                            ),
                          Flexible(
                            child: Container(
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
                          ),
                          if (!isSentByMe)
                            IconButton(
                              icon: Icon(Icons.volume_up, color: Colors.blue),
                              onPressed: () => _speak(message['message'] ?? ''),
                            ),
                        ],
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

  String _formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}



