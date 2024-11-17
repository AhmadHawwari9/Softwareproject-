import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
  String? photoUrl;
  File? _image;

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
      _isAtBottom = _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100;
    });
  }

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _image = File(result.files.single.path!);
      });
    }
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
      for (var message in newMessages) {
        if (message['img_id'] != null) {
          String relativeImagePath = message['path'];
          photoUrl = 'http://10.0.2.2:3001/' + relativeImagePath.replaceAll('\\', '/');
        } else {
          setState(() {
            photoUrl = null;
          });
        }
      }
      setState(() {
        messages = newMessages;
      });
      _scrollToBottom();
    } else {
      print("Failed to load messages: ${response.statusCode} - ${response.body}");
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty && _image == null) return; // Do not send empty messages

    final newMessage = {
      'sender_email': 'You',
      'receiver_id': widget.otherUserId,
      'message': _messageController.text,
      'timestamp': DateTime.now().toString(),
    };

    setState(() {
      messages.add(newMessage);
    });

    _messageController.clear();
    _scrollToBottom();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:3001/chat/send'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer ${widget.jwtToken}',
    });

    // Add text message
    request.fields['sender_id'] = widget.userEmail;
    request.fields['receiver_id'] = widget.otherUserId;
    request.fields['message'] = newMessage['message'] ?? '';

    // Add photo if available
    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _image!.path));
    }

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 201) {
      print("Failed to send message: ${response.statusCode} - ${response.reasonPhrase}");
    } else {
      // Optionally clear the image after sending
      setState(() {
        _image = null;
      });
    }

    _fetchMessages();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        double offset = _scrollController.position.maxScrollExtent;

        // Check if the last message has an image
        if (messages.isNotEmpty && messages.last['img_id'] != null) {
          offset += 300; // Add the image height (e.g., 300) to the scroll offset
        }

        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _speak(String text) async {
    // Check if the text contains Arabic characters
    String language = _isArabic(text) ? 'ar-SA' : 'en-US';  // 'ar-SA' is the Arabic language code
    await _flutterTts.setLanguage(language);
    await _flutterTts.speak(text);
  }

  bool _isArabic(String text) {
    // Regex to check if the string contains Arabic characters
    RegExp arabicRegExp = RegExp(r'[\u0600-\u06FF]');
    return arabicRegExp.hasMatch(text);
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

                bool hasImage = message['img_id'] != null;
                String? messagePhotoUrl = message['img_id'] != null ? 'http://10.0.2.2:3001/' + message['path'].replaceAll('\\', '/') : null;

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
                      SizedBox(height: hasImage ? 8 : 1),
                      Row(
                        mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (!hasImage && isSentByMe)
                            IconButton(
                              icon: Icon(Icons.volume_up, color: Colors.blue),
                              onPressed: () => _speak(message['message'] ?? ''),
                            ),
                          if (!hasImage)
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
                          if (!hasImage && !isSentByMe)
                            IconButton(
                              icon: Icon(Icons.volume_up, color: Colors.blue),
                              onPressed: () => _speak(message['message'] ?? ''),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      if (hasImage && messagePhotoUrl != null)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImage(photoUrl: messagePhotoUrl!),
                              ),
                            );
                          },
                          child: Align(
                            alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Image.network(
                              messagePhotoUrl!,
                              width: 200,
                              height: 200,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text('Error loading image');
                              },
                            ),
                          ),
                        ),
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
          if (_image != null) // Show image preview if an image is selected
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Image.file(
                    _image!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _image = null; // Remove the selected image
                      });
                    },
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                if (_image == null) // Show text field only if no image is selected
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
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: pickFile,
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
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class FullScreenImage extends StatelessWidget {
  final String photoUrl;

  FullScreenImage({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.network(
          photoUrl,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
