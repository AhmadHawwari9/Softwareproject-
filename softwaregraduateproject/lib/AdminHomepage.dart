import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softwaregraduateproject/UserProfilePage.dart';
import 'Conversations.dart';
import 'Login.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart'; // Added Firebase import

import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';

import 'Myfiles.dart';
import 'PdfReader.dart';

class AdminHomepage extends StatefulWidget {
  final String savedEmail;
  final String savedPassword;
  final String savedToken;
  final bool isGoogleSignInEnabled; // Flag for Google sign-in

  AdminHomepage(this.savedEmail, this.savedPassword, this.savedToken, this.isGoogleSignInEnabled); // Update constructor

  @override
  State<AdminHomepage> createState() => _HomepageState();
}

class _HomepageState extends State<AdminHomepage> {
  String? email;
  String? password;
  String? token;
  String? apiResponse;
  String? photoUrl;
  String accessToken = '';

  List<dynamic> conversations = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, String?> userImages = {};
  Set<String> unreadConversations = {}; // Track unread conversations

  @override
  void initState() {
    super.initState();
    _loadCredentials();
    _fetchConversations();
    getAccessToken();
    getToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("new message");
        print(message.notification!.title);
        print(message.notification!.body);
      }
    });
  }

  Future<void> _fetchConversations() async {
    if (widget.savedToken.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "JWT token is missing.";
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3001/chat/conversations'),
        headers: {
          'Authorization': 'Bearer ${widget.savedToken}',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> fetchedConversations = json.decode(response.body);
        setState(() {
          conversations = fetchedConversations;
          _isLoading = false;
        });

        // Fetch user images for each conversation and track unread ones
        for (var conversation in fetchedConversations) {
          String userEmail = conversation['user_email'] ?? '';
          if (conversation['hasUnreadMessages'] == true) {
            unreadConversations.add(conversation['user_id'].toString());
            print(userEmail);
            await sendMessage(userEmail);
          }
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load conversations: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error occurred while fetching conversations.";
      });
      print("Error fetching conversations: $e");
    }
  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Initialize Firebase (required for handling background messages)
    await Firebase.initializeApp();

    // Handle the message
    print("Handling a background message: ${message.messageId}");
    if (message.notification != null) {
      print("Title: ${message.notification!.title}");
      print("Body: ${message.notification!.body}");
    }
  }

  Future<void> _loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
      password = prefs.getString('password');
      token = prefs.getString('token');
    });
    if (token != null) {
      fetchHomepageData();
    }
  }

  Future<void> getToken() async {
    String? mytoken = await FirebaseMessaging.instance.getToken();
    print("================");
    print(mytoken);
  }

  Future<void> getAccessToken() async {
    try {
      final serviceAccountJson = await rootBundle.loadString(
          'assets/softwareproject-e838c-firebase-adminsdk-qd2od-f42b6120cb.json');

      final accountCredentials = ServiceAccountCredentials.fromJson(
        json.decode(serviceAccountJson),
      );

      const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      final client = http.Client();
      try {
        final accessCredentials = await obtainAccessCredentialsViaServiceAccount(
          accountCredentials,
          scopes,
          client,
        );

        setState(() {
          accessToken = accessCredentials.accessToken.data;
        });

        print('Access Token: $accessToken');
      } catch (e) {
        print('Error obtaining access token: $e');
      } finally {
        client.close();
      }
    } catch (e) {
      print('Error loading service account JSON: $e');
    }
  }

  Future<void> fetchHomepageData() async {
    final homepageUrl = Uri.parse('http://10.0.2.2:3001/api/homepage');
    final imageUrl = Uri.parse('http://10.0.2.2:3001/user/image/${widget.savedEmail}');

    try {
      final homepageResponse = await http.get(
        homepageUrl,
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? ''
        },
      );

      if (homepageResponse.statusCode == 200) {
        var responseBody = jsonDecode(homepageResponse.body);

        setState(() {
          apiResponse = 'Success: ${responseBody['message']}';
        });
      } else {
        setState(() {
          apiResponse = 'Failed: ${jsonDecode(homepageResponse.body)['error']}';
        });
      }

      final imageResponse = await http.get(
        imageUrl,
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? ''
        },
      );

      if (imageResponse.statusCode == 200) {
        final imageData = jsonDecode(imageResponse.body);
        String relativeImagePath = imageData['imagePath'];
        photoUrl = 'http://10.0.2.2:3001/' + relativeImagePath.replaceAll('\\', '/');
      } else {
        setState(() {
          photoUrl = null;
        });
      }
    } catch (error) {
      setState(() {
        apiResponse = 'Error: $error';
        photoUrl = null;
      });
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.disconnect();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Loginpage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Homepage"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Admin"),
            Text(
              'Email: ${email ?? 'No email provided'}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),

            // Conditionally show password only if Google Sign-In is NOT enabled
            if (!widget.isGoogleSignInEnabled)
              Text(
                'Password: ${password ?? 'No password provided'}',
                style: const TextStyle(fontSize: 24),
              ),
            const SizedBox(height: 20),

            apiResponse != null
                ? Text(
              apiResponse!,
              style: const TextStyle(fontSize: 24, color: Colors.green),
            )
                : const CircularProgressIndicator(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: const Text(
                'Log Out',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            photoUrl != null
                ? Image.network(
              photoUrl!,
              width: 100,
              height: 100,
              errorBuilder: (context, error, stackTrace) {
                return const Text('Error loading image');
              },
            )
                : const Text('No photo available'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ConversationsPage(jwtToken: token!)),
                );
              },
              child: const Text(
                'Go to Messages',
                style: TextStyle(fontSize: 20),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PdfFilesPage( jwtToken :token!)),
                );
              },
              child: const Text(
                'Go to myreports',
                style: TextStyle(fontSize: 20),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PDFReaderScreen(jwtToken: token!)),
                );
              },
              child: const Text(
                'Go to add pdf report to test',
                style: TextStyle(fontSize: 20),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfilePage(jwtToken: token!, email: email!,)),
                );
              },
              child: const Text(
                'Your profile',
                style: TextStyle(fontSize: 20),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future<void> sendMessage(String title) async {
  // Access token from Firebase (ensure it's valid and updated)
  const accessToken =
      'Bearer  ya29.c.c0ASRK0GahME2cwxzVwmwVbRKhyDcELfan36VuEBNo9_WLdb_s4_C6yJNBjhHZ71YGi9cEyRUODRFJVcOqrsuQ1GNuSa96CgfJwhJIywYm5QsS5RinnozEA_VqIcRTQLP-_IANQpNWTQ_Ua7EyAHq4PfU864SJNiixTGDmoO1cd7amnVfHqdgWBrvX7l8Q-mJ1Q5bIgGGViUNAGyimm0nMD_83P6bNELvVJyCaYrbCJaz4Z1EI-pgte_eB8no_oYXk54iQP7iv9LLD4xlUf4DGVtq7Hm0oGS3d7s4uLwRLq2FeoQW0fjS3UXBca6bQ_EYtXc66wnNsvxHovabToFPlpXLuGmHHlK1sO5-KMRQMIAgh3upcLwpDnt2WE385PQgmM4OF-JiV7opl7XBBatI8Jfj9uc9is3yxFIhXcWSMheXcwY_Rm_U14Vcmk1VXiXm_Fmm5-YIFkr90lb2fJZ4e9_zgh1IauqQlM3bF8uIdznY3k-lpwaIM84XotFJaBSpdIQv8zIxVVQnlSB3gXbjiqF-iqk3f_jeFfqRvOUc4oJedhRnWXjZ7iv408nezYBku485BY-i20f1WpYWw8JW3UQQz5OrSUecpmMeIu8zuVQth2qqVOUXOupyfg4B8WOrzr0b-YFwIY7RQw8Q2FjgthhVx7fgVQvVZrJXSv86aRQUFfdRer61-Jcqb1ngZetvrV7ebyJ6jf_4ikuqzUiRoh8S2lRwOfvxvU3Xp3igQR9h6unmsX25eBc8jdpxtxItXcrqFq3X-YgayB4i5BxVkM8ZrZxctOicmh-q7xsmXvz--j2aU1j5fgi3c33Ra5rywMnm8ZcmYcas8aoe8Yl_d08JpeoWpmfBXgsgxihZvq8vnQUel7i1Rpa7kz7FWswgivsJrw2dZY92kq7qqIUVpIko_sRZM6JRsQfcebJQ-i8nQiVwUItp9eVjvJrllSpWhB-MY-s6FhdsFUkBeSJFQlB63-akY6o9jmyiwdyne';

  // Replace with your actual FCM API endpoint and receiver token
  const fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/softwareproject-e838c/messages:send';
  const receiverToken = 'crJ1lj5kR-O_ylFMbzC07q:APA91bERmz7BnHAGchWSP_7XKxoR3BjBuzPFEBnSTLovqA5fJezf9jq0ZwrgHNo_fYUIZjrLoNFpsqG7FnF5wtzy--QEsRuKBCHKEI7hGVRL9jFG93ssSKQ';

  var body = json.encode({
    "message": {
      "token": receiverToken,
      "notification": {
        "title": title,
        "body": "You Have New Message",
      },   "android":{
        "priority":"normal"
      }
    },
  });

  try {
    var headers = {
      'Authorization': accessToken,
      'Content-Type': 'application/json',
    };

    var response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully!');
    } else {
      print('Failed to send notification. Status: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (error) {
    print('Error sending message: $error');
  }
}

