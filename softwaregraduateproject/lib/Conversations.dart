import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';

import 'AdminHomepage.dart';
import 'CareGiverHomepage.dart';
import 'CareRecipientHomepage.dart';
import 'Hospitaluser.dart';
import 'Searchpage.dart';
import 'chatwithspecificperson.dart'; // Ensure you have this import for DateFormat
import 'package:flutter/foundation.dart'; // For kIsWeb


String accessToken = '';
String? mytoken;
class ConversationsPage extends StatefulWidget {
  final String jwtToken;
  final String savedEmail;
  final String savedPassword;
  final bool isGoogleSignInEnabled;
  ConversationsPage(this.savedEmail, this.savedPassword, this.jwtToken, this.isGoogleSignInEnabled);
  @override
  _ConversationsPageState createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  List<dynamic> conversations = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, String?> userImages = {};
  Set<String> unreadConversations = {}; // Track unread conversations


  getToken() async{
    mytoken =await FirebaseMessaging.instance.getToken();
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
        final accessCredentials =
        await obtainAccessCredentialsViaServiceAccount(
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



  @override
  void initState() {
    getAccessToken();
    getToken();
    super.initState();
    _fetchConversations();
    FirebaseMessaging.onMessage.listen((RemoteMessage message){
      if(message.notification!=null){
        print("new message");
        print(message.notification!.title);
        print(message.notification!.body);
      }
    });

  }

  Future<void> _fetchConversations() async {
    if (widget.jwtToken.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "JWT token is missing.";
      });
      return;
    }

    final String apiUrl = kIsWeb
        ? 'http://localhost:3001/chat/conversations' // Web environment
        : 'http://10.0.2.2:3001/chat/conversations'; // Mobile environment

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}',
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
          _fetchUserImage(userEmail);
          if (conversation['hasUnreadMessages'] == true) {
            unreadConversations.add(conversation['user_id'].toString());
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


  Future<void> _fetchUserImage(String email) async {
    final String baseUrl = kIsWeb
        ? 'http://localhost:3001' // Web environment
        : 'http://10.0.2.2:3001'; // Mobile environment

    try {
      final imageResponse = await http.get(
        Uri.parse('$baseUrl/user/image/$email'),
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}',
        },
      );

      if (imageResponse.statusCode == 200) {
        final imageData = json.decode(imageResponse.body);
        String relativeImagePath = imageData['imagePath'];
        setState(() {
          userImages[email] = '$baseUrl/' + relativeImagePath.replaceAll('\\', '/');
        });
      } else {
        setState(() {
          userImages[email] = null;
        });
      }
    } catch (e) {
      print('Error fetching user image for $email: $e');
      setState(() {
        userImages[email] = null;
      });
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } catch (e) {
      print("Error parsing date: $e");
      return dateTimeStr;
    }
  }
  Future<http.Response> fetchHomepageAndNavigate(
      BuildContext context, String email, String password, String token, bool isGoogleSignInEnabled) async {
    try {
      final apiUrl = kIsWeb
          ? 'http://localhost:3001/api/homepage' // Web environment (localhost or public URL)
          : 'http://10.0.2.2:3001/api/homepage'; // Mobile emulator

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userType = data['userType'];

        Widget homepage;
        if (userType == 'Care recipient') {
          homepage = CareRecipientHomepage(email, password, token, isGoogleSignInEnabled);
        } else if (userType == 'Admin') {
          homepage = AdminHomepage(email, password, token, isGoogleSignInEnabled);
        } else if (userType == 'Care giver') {
          homepage = CareGiverHomepage(email, password, token, isGoogleSignInEnabled);
        } else {
          homepage = HospitalUserForm(email, password, token, isGoogleSignInEnabled);
        }

        // If mounted, navigate to the homepage
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => homepage),
          );
        }
        return response; // Return the response on success
      } else {
        throw Exception('Failed to load homepage data. Status code: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No Internet connection or server unreachable');
    } catch (e) {
      throw Exception('Unexpected error occurred: $e');
    }
  }
  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  int _selectedIndex = 0;

  Future<void> _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        await fetchHomepageAndNavigate(context, widget.savedEmail, widget.savedPassword, widget.jwtToken, false);
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ConversationsPage( widget.savedEmail, widget.savedPassword, widget.jwtToken, false)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SearchPage(widget.savedEmail, widget.savedPassword, widget.jwtToken, false)),
        );
        break;
      case 3:
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => BrowsePage()),
      // );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Chats',style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          final userEmail = conversation['user_email'] ?? 'Unknown';
          final imageUrl = userImages[userEmail];
          final userImage = imageUrl != null
              ? CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(imageUrl),
          )
              : CircleAvatar(
            radius: 30,
            child: Icon(Icons.person, size: 30),
          );

          final isUnread = unreadConversations.contains(conversation['user_id'].toString());

          return ListTile(
            leading: userImage,
            title: Text(
              userEmail,
              style: TextStyle(
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Last message time: ${_formatDateTime(conversation['last_message_time'] ?? '')}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14),
            ),
            onTap: () async {
              String otherUserId = conversation['user_id']?.toString() ?? "null";

              // Mark as read when clicked
              setState(() {
                unreadConversations.remove(conversation['user_id'].toString());
              });

              // Send a request to mark messages as read
              try {
                final String baseUrl = kIsWeb
                    ? 'http://localhost:3001' // Web environment
                    : 'http://10.0.2.2:3001'; // Mobile environment

                final response = await http.post(
                  Uri.parse('$baseUrl/chat/conversations/$otherUserId'),
                  headers: {
                    'Authorization': 'Bearer ${widget.jwtToken}',
                  },
                );


                if (response.statusCode == 200) {
                  print("Messages marked as read successfully.");
                } else {
                  print("Failed to mark messages as read: ${response.statusCode}");
                }
              } catch (e) {
                print("Error marking messages as read: $e");
              }

              // Navigate to the chat screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    jwtToken: widget.jwtToken,
                    otherUserId: otherUserId,
                    userEmail: userEmail,
                  ),
                ),
              );
            },

          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.teal),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Colors.teal),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.teal),
            label: 'Search',
          ),

        ],
      ),
    );
  }
}




Future<void> sendMessage(String title) async {
  // Access token from Firebase (ensure it's valid and updated)
   accessToken =
      'Bearer  ya29.c.c0ASRK0Gbaz8XYJgAUHolvuSYpPD8A7IYu2jBZVf7hdLLoe4Obksl1SgxDNOTM4pvLoc9B1YDIubYsD2Zyfhjm5jMvOR7ZVL5rZhLutdefa3tG6ja68R0bN1cGPm6VgcUOfoEjJwdAcQM_bpcuUkQewFW_sbGXe5mNd4dHe3of8VJ1pzKHke5X8rYttw3a_gSMnqD_b9mqpw228PRHbmGgfMPZFkAAJc7px7s2Z9BnfIY0YFh3JGvKVWdGOrWOgzToyRl46qsvE9iBZBpu_Rl7P-qyXgK7tJGQCNm4Q-J03m0L5OyS3tr93jo2N7xAHfeG0Jnob7uLCea7ofEym222LFoJrLtW9sDOqPxCURoNBppdsAiul95qCz82G385K4QzzbVfaOtJu9kQIOlI3Ra81da5hlutiSlfQdVYMkYwxpBSO5RFr644fSee2OwSmtuM-4nymZOk8mWIrlvIY6O8dlpZu66QcQ2Qjj-IfUjnfbIi1idW1087Siiyzk2Q4hYmiky-ubXSsw38yBXS0U0s-drwRl4p-4oxMFFiSgW1ktxROhxixp3xZ1SocfxUIf5x3nntn2ogw6YU7SotuWBJ9r77RWII87y2mp49fbu6cvM2OF-lh0SWjsn7y1ORuuxw9t2yOMtSMXJQ_cwZYdi98xr8ednineXykxXcQ0Fc02jyu1gbn8Ij_43fO2lIarIYFU6JhMhvs246z6ww11W9b68oiO5zlWzfl8gFebgvWv4k_e-B1WejSytdi6pFkV7ZzoamiztmyxfF9hl2pxpixQO-Ze2jQaVziuRzcV-r4uqFo9eVk2QIo9O1Z998YdJIIhzB-bkzvOXfRM28ruzFajFlwjf2tv4uqz_t49dfk-mXRVgs2nuRBjX5S0FrccpV-zozpwIJYsiI_1o8B34I62_15q_zr3mOy8dXFj0_eF44y5g46Fr4ZYgIotuyfFyw2OffBdfy6inpyVkMZUXwg9Ynp30ln0edIy8Yxt4J';

  var receiverToken = mytoken;

  // Replace with your actual project and receiver token
  const projectId = 'softwareproject-e838c';

  try {
    var headers = {
      'Authorization': accessToken,
      'Content-Type': 'application/json',
    };

    var body = json.encode({
      "message": {
        "token": receiverToken,
        "notification": {
          "title": title,
          "body": "You Have New Message",
        },   "android":{
          "priority":"high"
        }
      },
    });

    var url =
    Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print("Message sent successfully: ${response.body}");
    } else {
      print(
          "Failed to send message: ${response.statusCode}, ${response.reasonPhrase}");
    }
  } catch (e) {
    print("Error sending message: $e");
  }
}



