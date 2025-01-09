import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationsPage extends StatefulWidget {
  final String savedToken;
  final bool iscareRecipant;
  NotificationsPage(this.savedToken, this.iscareRecipant);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List> followNotifications;
  late Future<List> unfollowNotifications;
  List unfollowNotificationsList = [];

  @override
  void initState() {
    super.initState();
    // Initialize both follow and unfollow notifications with the API fetch methods
    followNotifications = fetchFollowNotifications();
    unfollowNotifications = fetchUnfollowNotifications();
  }

  final baseUrl = kIsWeb
      ? 'http://localhost:3001' // Web environment (localhost)
      : 'http://10.0.2.2:3001'; // Mobile emulator

  Future<List> fetchFollowNotifications() async {
    final url = '$baseUrl/notifications';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.savedToken}', // Send token in the header
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Ensure the 'notifications' field is extracted correctly
      if (data['notifications'] != null) {
        return data['notifications'];
      } else {
        throw Exception('No notifications found');
      }
    } else {
      throw Exception('Failed to load follow notifications');
    }
  }

  Future<List> fetchUnfollowNotifications() async {
    final url = '$baseUrl/getUnfollowNotifications';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.savedToken}', // Send token in the header
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Ensure the 'notifications' field is extracted correctly
      if (data['notifications'] != null) {
        setState(() {
          unfollowNotificationsList = data['notifications'];  // Store the notifications locally
        });
        return data['notifications'];
      } else {
        throw Exception('No notifications found');
      }
    } else {
      throw Exception('Failed to load unfollow notifications');
    }
  }

  Future<String> fetchSenderImage(String senderEmail) async {
    final url = '$baseUrl/user/image/$senderEmail';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['imagePath']; // assuming the API returns the relative path to the image
    } else {
      throw Exception('Failed to load sender image');
    }
  }

  Future<void> approveFollowRequest(String senderId) async {
    final url = '$baseUrl/approveFollowRequest';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.savedToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'sender_id': senderId}),
    );

    if (response.statusCode == 200) {
      print('Follow request approved for sender ID $senderId');
      setState(() {
        followNotifications = fetchFollowNotifications();
        unfollowNotifications = fetchUnfollowNotifications();
      });
    } else {
      print('Failed to approve follow request');
    }
  }

  Future<void> rejectFollowRequest(String senderId) async {
    final url = '$baseUrl/deleteFollowRequest';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.savedToken}', // Include token in headers
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sender_id': senderId, // Send sender_id instead of notificationId
      }),
    );

    if (response.statusCode == 200) {
      // Handle successful rejection
      print('Follow request rejected for sender ID $senderId');
      // Refresh the notifications after rejection
      setState(() {
        followNotifications = fetchFollowNotifications();
        unfollowNotifications = fetchUnfollowNotifications();
      });
    } else {
      // Handle error
      print('Failed to reject follow request');
    }
  }

  Future<void> rejectUnfollowRequest(String senderId) async {
    final url = '$baseUrl/deleteNotificationunfollowrequest/$senderId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.savedToken}'
      },
    );

    if (response.statusCode == 200) {
      print('Unfollow request rejected for sender ID $senderId');
      setState(() {
        followNotifications = fetchFollowNotifications();
        unfollowNotifications = fetchUnfollowNotifications();
      });
    } else {
      print('Failed to reject unfollow request');
    }
  }

  Future<void> acceptUnfollowRequest(String senderId) async {
    final url = '$baseUrl/deleteNotificationAndUnfollowAccept/$senderId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.savedToken}'
      },
    );

    if (response.statusCode == 200) {
      print('Unfollow request accepted for sender ID $senderId');
      setState(() {
        followNotifications = fetchFollowNotifications();
        unfollowNotifications = fetchUnfollowNotifications();
      });
    } else {
      print('Failed to accept unfollow request');
    }
  }

  Future<void> acceptUnfollowRequestforcareRecipant(String senderId) async {
    final url = '$baseUrl/deleteNotificationAndUnfollowAcceptforcarerecipant/$senderId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.savedToken}',
        'Content-Type': 'application/json',
      },
    );

    print('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('Unfollow request accepted for sender ID $senderId');
      setState(() {
        // Refresh notifications after accepting the request
        followNotifications = fetchFollowNotifications();
        unfollowNotifications = fetchUnfollowNotifications();
      });
    } else {
      print('Failed to accept unfollow request: ${response.body}');
    }
  }

  Future<void> markNotificationsAsRead() async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/mark-notifications-read'),
        headers: {
          'Authorization': 'Bearer ${widget.savedToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Notifications marked as read successfully');
      } else {
        print('Failed to mark notifications as read: ${response.body}');
      }
    } catch (e) {
      print('Error marking notifications as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
      ),
      body: FutureBuilder<List>(
        future: Future.wait([followNotifications, unfollowNotifications]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load notifications'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty ||
              (snapshot.data![0].isEmpty && snapshot.data![1].isEmpty)) {
            return Center(child: Text('No Notifications available'));
          }
          markNotificationsAsRead();

          final followNotificationsList = snapshot.data![0];
          final unfollowNotificationsList = snapshot.data![1];

          return ListView.builder(
            itemCount: followNotificationsList.length + unfollowNotificationsList.length,
            itemBuilder: (context, index) {
              var notification;
              bool isFollow = true;

              if (index < followNotificationsList.length) {
                notification = followNotificationsList[index];
              } else {
                notification = unfollowNotificationsList[index - followNotificationsList.length];
                isFollow = false;
              }

              bool isUnread = notification['is_read'] == 0;
              String senderEmail = notification['sender_email'] ?? 'No Email';
              String notificationType = notification['typeofnotifications'];

              return FutureBuilder<String>(
                future: fetchSenderImage(senderEmail),
                builder: (context, imageSnapshot) {
                  if (imageSnapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.teal,
                            child: CircularProgressIndicator(),
                          ),
                          title: Text(notificationType == 'follow'
                              ? 'You have a new follow request'
                              : 'You have a new unfollow request'),
                        ),
                      ),
                    );
                  } else if (imageSnapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.teal,
                            child: Icon(Icons.error, color: Colors.white),
                          ),
                          title: Text(notificationType == 'follow'
                              ? 'You have a new follow request'
                              : 'You have a new unfollow request'),
                        ),
                      ),
                    );
                  } else {
                    String relativeImagePath = imageSnapshot.data ?? '';
                    String photoUrl = '';

                    final baseUrl = kIsWeb
                        ? 'http://localhost:3001' // Web environment (localhost)
                        : 'http://10.0.2.2:3001'; // Mobile emulator

                    if (relativeImagePath.isNotEmpty) {
                      photoUrl = '$baseUrl/${relativeImagePath.replaceAll('\\', '/')}';
                    }


                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.teal,
                            backgroundImage: photoUrl.isNotEmpty
                                ? NetworkImage(photoUrl)
                                : null,
                            child: photoUrl.isEmpty
                                ? Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          title: Text(
                            senderEmail,
                            style: TextStyle(
                              fontSize: 16,
                              color: isUnread ? Colors.black : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notificationType == 'follow'
                                    ? 'You have a new follow request '
                                    : notificationType == 'unfollow'
                                    ? 'You have a new unfollow request '
                                    : notificationType == 'approve_follow_request'
                                    ? 'Follow request approved'
                                    : notificationType == 'approve_unfollow_request'
                                    ? 'Unfollow request approved'
                                    : notificationType, // Print typeofnotifications if it does not match any of the above
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isUnread ? Colors.black : Colors.grey,
                                ),
                              ),
                              // Optionally, you can include the type of notification only if it's not one of the predefined ones
                              notificationType != 'follow' && notificationType != 'unfollow' && notificationType != 'approve_follow_request' && notificationType != 'approve_unfollow_request'
                                  ? Text('', // Print typeofnotifications here if it's not one of the predefined types
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ))
                                  : Container(), // Empty container if it's one of the predefined types
                            ],
                          ),

                          trailing: notificationType == 'approve_follow_request' ||
                              notificationType == 'approve_unfollow_request'
                              ? null // No buttons for approved requests
                              : notificationType != 'follow' && notificationType != 'unfollow'
                              ? null // Skip buttons for unrecognized types
                              : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          IconButton(
                          icon: Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () {
                            String senderId = notification['Sender_id'].toString();
                            String notificationType = notification['typeofnotifications'];

                            print('senderId: $senderId, notificationType: $notificationType'); // Log for debugging

                            if (notificationType == 'follow') {
                              approveFollowRequest(senderId);
                            } else {
                              if (widget.iscareRecipant) {
                                acceptUnfollowRequestforcareRecipant(senderId);
                              } else {
                                acceptUnfollowRequest(senderId);
                              }
                            }
                          },
                        ),

                        IconButton(
                                icon: Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  String senderId = notification['Sender_id'].toString();
                                  if (notificationType == 'follow') {
                                    rejectFollowRequest(senderId);
                                  } else {
                                    if (widget.iscareRecipant) {
                                      rejectUnfollowRequest(senderId);
                                    } else {
                                      rejectFollowRequest(senderId);
                                    }
                                  }
                                },
                              ),
                            ],
                          ),

                          tileColor: isUnread ? Colors.teal[50] : Colors.white,
                          onTap: () {
                            print('Notification tapped: ${notification['Notifications_id']}');
                          },
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

}
