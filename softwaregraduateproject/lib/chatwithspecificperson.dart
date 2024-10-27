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

  @override
  void initState() {
    super.initState();
    print("Other User ID: ${widget.otherUserId}");
    _fetchMessages();
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
      setState(() {
        messages = json.decode(response.body);
        messages.forEach((message) {
          print("Message: ${message['id']}, Sender: ${message['sender_id']}, Receiver: ${message['receiver_id']}, Text: ${message['message']}");
        });
      });
    } else {
      print("Failed to load messages: ${response.statusCode} - ${response.body}");
    }
  }

  String _formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _sendMessage() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3001/chat/send'),
      headers: {
        'Authorization': 'Bearer ${widget.jwtToken}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'receiver_id': widget.otherUserId,
        'text': _messageController.text,
      }),
    );

    if (response.statusCode == 200) {
      _messageController.clear();
      _fetchMessages();
    } else {
      print("Failed to send message: ${response.statusCode} - ${response.body}");
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
                          message['message'] ?? 'No text', // Correct key access here
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
