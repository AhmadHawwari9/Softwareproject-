import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:universal_html/html.dart' as html;
import 'package:http_parser/http_parser.dart';

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
  bool isRecording = false;
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

    // Add listener for audio playback completion (for mobile)
    player.onPlayerComplete.listen((event) {
      setState(() {
        currentlyPlayingIndex = null; // Reset the currently playing index
      });
    });
  }

  Uint8List? photoBytes; // Add this field to handle web-specific file bytes

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      if (kIsWeb) {
        // For web, use the picked file's bytes
        Uint8List? fileBytes = result.files.single.bytes;
        String fileName = result.files.single.name;

        setState(() {
          _image = null; // Clear mobile-specific image
          photoUrl = null; // Clear previous web-specific image
          photoBytes = fileBytes; // Set the new file bytes for web
        });

        print('Picked file: $fileName');
      } else {
        // For mobile, use the file path
        setState(() {
          _image = File(result.files.single.path!);
          photoBytes = null; // Clear web-specific file bytes
        });
      }
    }
  }

  final AudioRecorder audioRecorder = AudioRecorder();
  AudioPlayer player = AudioPlayer();

  Future<void> playAudioformalUrl(String url) async {
    try {
      if (kIsWeb) {
        final audio = html.AudioElement();
        audio.src = url; // Set the URL of the audio file
        audio.controls = true; // Show playback controls
        audio.autoplay = true; // Autoplay the audio when it's ready

        // Log audio load and error events for debugging
        audio.onLoad.listen((_) {
          print("Audio loaded and ready to play.");
        });

        audio.onCanPlay.listen((_) {
          print("Audio is ready to play.");
          audio.play().catchError((error) {
            print("Web playback error: $error");
          });
        });

        audio.onError.listen((event) {
          print("Error during playback: ${audio.error?.code}");
          print("Error details: ${audio.error?.message}");
        });

        // Listen for the 'ended' event to detect when audio finishes
        audio.onEnded.listen((event) {
          print("Audio playback finished.");
          setState(() {
            currentlyPlayingIndex = null; // Reset the playing index
          });
        });

        // Append the audio element to the body to ensure it works
        // html.document.body?.append(audio);
      } else {
        final audioSource = UrlSource(url, mimeType: 'audio/x-wav'); // Set the correct MIME type
        await player.play(audioSource);
      }
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  Future<void> _fetchMessages() async {
    final apiUrl = kIsWeb
        ? 'http://localhost:3001/chat/receive/${widget.otherUserId}' // Web environment
        : 'http://10.0.2.2:3001/chat/receive/${widget.otherUserId}'; // Mobile environment

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}', // Pass the JWT token in headers
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> newMessages = json.decode(response.body);
        String? updatedPhotoUrl;

        for (var message in newMessages) {
          if (message['img_id'] != null) {
            String relativeImagePath = message['path'];
            updatedPhotoUrl = (kIsWeb
                ? 'http://localhost:3001/'
                : 'http://10.0.2.2:3001/') +
                relativeImagePath.replaceAll('\\', '/');
          } else {
            updatedPhotoUrl = null;
          }
        }

        setState(() {
          messages = newMessages;
          photoUrl = updatedPhotoUrl; // Update photoUrl outside the loop
        });

        _scrollToBottom();
      } else {
        print("Failed to load messages: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }


  Future<void> sendNotification({
    required String title,
    required String message,
    required String userId, // Pass the userId as a parameter
  }) async {
    // Check if the app is running in the web or mobile environment
    String base = (kIsWeb)
        ? 'http://localhost:3001' // For web
        : 'http://10.0.2.2:3001'; // For Android Emulator

    final url = Uri.parse('$base/api/Sendnotifications');

    print("user id:====$userId");

    // Prepare the data from the parameters
    final data = {
      "title": title,
      "message": message,
      "externalIds": [userId] // Pass userId as a list
    };

    // Send the POST request
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      // Check the response
      if (response.statusCode == 200) {
        // Successfully sent notification
        print("Notification sent successfully!");
      } else {
        // Error in sending notification
        print("Failed to send notification. Status code: ${response.statusCode}");
      }
    } catch (e) {
      // Handle network errors
      print("Error sending notification: $e");
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty && _image == null && photoBytes == null && recordingpath == null) {
      return; // Exit early if there's nothing to send
    }

    final newMessage = {
      'sender_email': 'You',
      'receiver_id': widget.otherUserId,
      'message': _messageController.text,
      'timestamp': DateTime.now().toString(),
    };

    // Update UI with the new message locally
    setState(() {
      messages.add(newMessage);
    });

    // Clear the message input field and scroll to the bottom
    _messageController.clear();
    _scrollToBottom();

    final apiUrl = kIsWeb
        ? 'http://localhost:3001/chat/send' // Web environment
        : 'http://10.0.2.2:3001/chat/send'; // Mobile environment

    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.headers.addAll({
        'Authorization': 'Bearer ${widget.jwtToken}',
      });

      request.fields['sender_id'] = widget.userEmail;
      request.fields['receiver_id'] = widget.otherUserId;
      request.fields['message'] = newMessage['message'] ?? '';

      // Add image for mobile
      if (_image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', _image!.path),
        );
      }

      // Add photoBytes for web
      if (photoBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'photo',
            photoBytes!,
            filename: 'image.jpg', // Adjust filename as needed
          ),
        );
      }

      // Add audio file if available
      if (recordingpath != null) {
        if (kIsWeb) {
          // Web-specific audio sending
          final audioBytes = await File(recordingpath!).readAsBytes();
          sendWebAudio(audioBytes);
        } else {
          // Mobile-specific audio sending
          final audioBytes = await File(recordingpath!).readAsBytes(); // Read audio file as bytes
          request.files.add(
            http.MultipartFile.fromBytes(
              'audio',
              audioBytes, // Add audio bytes
              filename: 'recording.wav', // Adjust filename as needed
              contentType: MediaType('audio', 'wav'), // Set content type as audio/wav
            ),
          );
        }
      }

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _image = null;
          photoBytes = null; // Clear web-specific photoBytes
          recordingpath = null;
        });

        sendNotification(
          title: "SafeAging",
          message: "You Have New Message",
          userId: widget.otherUserId,  // Pass the userId variable here
        );
      } else {
        print("Failed to send message: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error sending message: $e");
    } finally {
      _fetchMessages();
    }
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

  html.MediaRecorder? mediaRecorder; // Web-specific MediaRecorder
  List<html.Blob> audioChunks = []; // To store recorded audio chunks

  void startWebRecording() {
    html.window.navigator.mediaDevices
        ?.getUserMedia({'audio': true}).then((stream) {
      mediaRecorder = html.MediaRecorder(stream);
      mediaRecorder!.start();

      mediaRecorder!.addEventListener('dataavailable', (event) {
        if (event is html.BlobEvent && event.data != null) {
          audioChunks.add(event.data!); // Use `!` to assert that it's non-null
        }
      });

      mediaRecorder!.addEventListener('stop', (_) {
        print("Web recording stopped.");
      });

      print("Web recording started.");
    }).catchError((error) {
      print("Error accessing microphone on web: $error");
    });
  }

  Future<void> sendAudioFromApp(String filePath) async {
    final apiUrl = 'http://10.0.2.2:3001/chat/send'; // Adjust for your web environment

    try {
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();
      final fileName = p.basename(filePath); // Get the file name from the path

      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.headers.addAll({
        'Authorization': 'Bearer ${widget.jwtToken}', // Include JWT token for authorization
      });

      request.fields['sender_id'] = widget.userEmail;
      request.fields['receiver_id'] = widget.otherUserId;
      request.fields['message'] = ''; // Optional message text

      // Add audio file
      request.files.add(
        http.MultipartFile.fromBytes(
          'audio',
          fileBytes,
          filename: fileName,
          contentType: MediaType('audio', 'wav'), // Adjust content type based on your audio format
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Audio message sent successfully!");
        // Optionally clear any states or data here, such as resetting the recording state
      } else {
        print("Failed to send audio message: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error sending audio message: $e");
    }
  }

  void sendWebAudio(Uint8List audioBytes) async {
    final apiUrl = 'http://localhost:3001/chat/send'; // Adjust for your web environment

    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.headers.addAll({
        'Authorization': 'Bearer ${widget.jwtToken}',
      });

      request.fields['sender_id'] = widget.userEmail;
      request.fields['receiver_id'] = widget.otherUserId;
      request.fields['message'] = ''; // Optional message text

      // Add audio file
      request.files.add(
        http.MultipartFile.fromBytes(
          'audio',
          audioBytes,
          filename: 'recording.wav',
          contentType: MediaType('audio', 'wav'),
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          isRecording = false;
          audioChunks.clear(); // Clear recorded audio chunks
        });
        print("Audio message sent successfully!");
        _fetchMessages();
      } else {
        print("Failed to send audio message: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error sending audio message: $e");
    }
  }

  void stopWebRecording() {
    if (mediaRecorder != null) {
      mediaRecorder!.stop();
      mediaRecorder!.addEventListener('stop', (_) async {
        if (audioChunks.isNotEmpty) {
          final blob = html.Blob(audioChunks, 'audio/wav');
          final reader = html.FileReader();

          reader.readAsArrayBuffer(blob);
          reader.onLoadEnd.listen((event) {
            final audioBytes = reader.result as Uint8List;
            sendWebAudio(audioBytes); // Send the audio bytes to the server
          });
        }
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
                    ? (kIsWeb
                    ? 'http://localhost:3001/' // Web environment
                    : 'http://10.0.2.2:3001/') // Mobile environment
                    + message['path'].replaceAll('\\', '/')
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
                                  // If this audio is already playing, pause it
                                  if (kIsWeb) {
                                    final audioElements = html.document.getElementsByTagName('audio');
                                    if (audioElements.isNotEmpty) {
                                      (audioElements[0] as html.AudioElement).pause();
                                    }
                                  } else {
                                    await player.pause();
                                  }
                                  setState(() {
                                    currentlyPlayingIndex = null; // Reset playing index
                                  });
                                } else {
                                  // Stop any currently playing audio
                                  if (kIsWeb) {
                                    final audioElements = html.document.getElementsByTagName('audio');
                                    if (audioElements.isNotEmpty) {
                                      (audioElements[0] as html.AudioElement).pause();
                                    }
                                  } else {
                                    if (player.state == PlayerState.playing) {
                                      await player.pause();
                                    }
                                  }

                                  // Start playing the selected audio
                                  setState(() {
                                    currentlyPlayingIndex = index; // Set playing index
                                  });

                                  await playAudioformalUrl(
                                      (kIsWeb
                                          ? 'http://localhost:3001/' // Web environment
                                          : 'http://10.0.2.2:3001/') // Mobile environment
                                          + message['message']
                                  );
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
              },
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
                  icon: Icon(isRecording ? Icons.stop : Icons.mic, color: Colors.teal),
                  onPressed: () async {
                    try {
                      if (isRecording) {
                        if (kIsWeb) {
                          // Stop recording on web
                          stopWebRecording();
                          setState(() {
                            isRecording = false;
                          });
                        } else {
                          // Stop recording on mobile
                          final filepath = await audioRecorder.stop();
                          if (filepath != null) {
                            setState(() {
                              isRecording = false;
                              recordingpath = filepath;
                            });
                            _sendMessage();
                          }
                        }
                      } else if (await audioRecorder.hasPermission()) {
                        if (kIsWeb) {
                          // Start recording on web
                          startWebRecording();
                          setState(() {
                            isRecording = true;
                            recordingpath = null;
                          });
                        } else {
                          // Start recording on mobile
                          final Directory appDocDir = await getApplicationDocumentsDirectory();
                          final String filepath = p.join(appDocDir.path, "recording.wav");

                          await audioRecorder.start(const RecordConfig(), path: filepath);
                          setState(() {
                            isRecording = true;
                            recordingpath = null;
                          });
                        }
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