import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:path/path.dart'as p;
import 'package:audioplayers/audioplayers.dart';

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
  bool isRecording=false;
  List<dynamic> messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isAtBottom = true;
  String? recordingpath;

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

  final AudioRecorder audioRecorder = AudioRecorder();
  final player=AudioPlayer();

  Future<void> playAudioformalUrl(String url) async{
    await player.play(UrlSource(url));
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
    if (_messageController.text.isEmpty && _image == null && recordingpath == null) return;

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

    request.fields['sender_id'] = widget.userEmail;
    request.fields['receiver_id'] = widget.otherUserId;
    request.fields['message'] = newMessage['message'] ?? '';

    // If there is an image, add it to the request
    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _image!.path));
    }

    // If there is an audio file, add it to the request
    if (recordingpath != null) {
      request.files.add(await http.MultipartFile.fromPath('audio', recordingpath!));
    }

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 201) {
      print("Failed to send message: ${response.statusCode} - ${response.reasonPhrase}");
    } else {
      setState(() {
        _image = null;
        recordingpath = null; // Clear the recorded audio path
      });
    }

    _fetchMessages();
  }


  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        double offset = _scrollController.position.maxScrollExtent;

        if (messages.isNotEmpty && messages.last['img_id'] != null) {
          offset += 300;
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
    String language = _isArabic(text) ? 'ar-SA' : 'en-US';
    await _flutterTts.setLanguage(language);
    await _flutterTts.speak(text);
  }

  bool _isArabic(String text) {
    RegExp arabicRegExp = RegExp(r'[\u0600-\u06FF]');
    return arabicRegExp.hasMatch(text);
  }
  int? currentlyPlayingIndex;
  Duration currentPlaybackPosition = Duration.zero;
  bool isAudioPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          widget.userEmail,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
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
                  bool hasAudio = message['message']?.endsWith('.wav') ?? false;
                  String? messagePhotoUrl = message['img_id'] != null
                      ? 'http://10.0.2.2:3001/' + message['path'].replaceAll('\\', '/')
                      : null;

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
                        SizedBox(height: hasImage || hasAudio ? 8 : 1),
                        Row(
                          mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [

                            if (hasAudio)
                              GestureDetector(
                                onTap: () async {
                                  if (currentlyPlayingIndex == index) {
                                    // If this audio is already playing, pause it and save the current position
                                    currentPlaybackPosition = await player.getCurrentPosition() ?? Duration.zero;
                                    await player.pause(); // Pause instead of stopping
                                    setState(() {
                                      currentlyPlayingIndex = null; // Reset playing index
                                    });
                                  } else {
                                    // Stop any currently playing audio
                                    if (player.state == PlayerState.playing) {
                                      await player.pause(); // Pause if it's already playing
                                    }

                                    // Start playing the selected audio
                                    setState(() {
                                      currentlyPlayingIndex = index; // Set playing index
                                    });

                                    // Check if there's a saved position to resume from
                                    if (currentPlaybackPosition > Duration.zero) {
                                      await player.seek(currentPlaybackPosition); // Seek to the saved position
                                    } else {
                                      currentPlaybackPosition = Duration.zero; // Start from the beginning if no saved position
                                    }

                                    // Play the audio
                                    await playAudioformalUrl('http://10.0.2.2:3001/' + message['message']);

                                    // Listen for when playback completes
                                    player.onPlayerComplete.listen((_) {
                                      setState(() {
                                        currentPlaybackPosition = Duration.zero; // Reset position when playback completes (start from the beginning next time)
                                        currentlyPlayingIndex = null; // Reset index
                                      });
                                    });
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSentByMe ? Colors.teal[200] : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        currentlyPlayingIndex == index ? Icons.stop : Icons.play_arrow,
                                        color: isSentByMe ? Colors.white : Colors.black,
                                      ),
                                      SizedBox(width: 8),
                                      Container(
                                        width: 120,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              currentlyPlayingIndex == index ? "Playing..." : "Audio",
                                              style: TextStyle(fontSize: 12, color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),


                            if (!hasImage && !hasAudio && isSentByMe)
                              IconButton(
                                icon: Icon(Icons.volume_up, color: Colors.teal),
                                onPressed: () => _speak(message['message'] ?? ''),
                              ),
                            if (!hasImage && !hasAudio)
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSentByMe ? Colors.teal : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    message['message'] ?? 'No text',
                                    style: TextStyle(color: isSentByMe ? Colors.white : Colors.black),
                                  ),
                                ),
                              ),
                            if (!hasImage && !hasAudio && !isSentByMe)
                              IconButton(
                                icon: Icon(Icons.volume_up, color: Colors.teal),
                                onPressed: () => _speak(message['message'] ?? ''),
                              ),
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
                }



            ),
          ),
          if (_image != null)
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
                        _image = null;
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
                IconButton(
                  icon: Icon(Icons.camera_alt, color: Colors.teal),
                  onPressed: pickFile,
                ),
                if (_image == null)
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                IconButton(
                  icon: Icon( isRecording? Icons.stop:Icons.mic, color: Colors.teal),
                  onPressed: ()async {
                    try {
                      if (isRecording) {
                        final filepath = await audioRecorder.stop();
                        if (filepath != null) {
                          setState(() {
                            isRecording = false;
                            recordingpath = filepath;
                          });
                          _sendMessage();
                        }
                      } else if (await audioRecorder.hasPermission()) {
                        final Directory appDocDir = await getApplicationDocumentsDirectory();
                        final String filepath = p.join(appDocDir.path, "recording.wav");
                        await audioRecorder.start(const RecordConfig(), path: filepath);
                        setState(() {
                          isRecording = true;
                          recordingpath = null;
                        });
                      }
                    } catch (e) {
                      print("Error with audio recording: $e");
                    }

                  },
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.teal),
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
    final dateTime = DateTime.parse(dateTimeString);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  }
}

class FullScreenImage extends StatelessWidget {
  final String photoUrl;

  const FullScreenImage({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.network(photoUrl),
      ),
    );
  }
}
