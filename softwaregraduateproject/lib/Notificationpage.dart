import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  final String savedToken;
  NotificationsPage(this.savedToken);

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

  Future<List> fetchFollowNotifications() async {
    final url = 'http://10.0.2.2:3001/notifications';
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
    final url = 'http://10.0.2.2:3001/getUnfollowNotifications';
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
    final url = 'http://10.0.2.2:3001/user/image/$senderEmail';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['imagePath']; // assuming the API returns the relative path to the image
    } else {
      throw Exception('Failed to load sender image');
    }
  }

  Future<void> approveFollowRequest(String senderId) async {
    final url = 'http://10.0.2.2:3001/approveFollowRequest';
    final response = await http.post(
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
      // Handle successful approval
      print('Follow request approved for sender ID $senderId');
      // Refresh the notifications after approval
      setState(() {
        followNotifications = fetchFollowNotifications();
      });
    } else {
      // Handle error
      print('Failed to approve follow request');
    }
  }

  Future<void> rejectFollowRequest(String senderId) async {
    final url = 'http://10.0.2.2:3001/deleteFollowRequest';
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
      });
    } else {
      // Handle error
      print('Failed to reject follow request');
    }
  }

  Future<void> rejectUnfollowRequest(String senderId) async {
    final url = 'http://10.0.2.2:3001/deleteNotificationunfollowrequest/$senderId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.savedToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('Unfollow request rejected and notification deleted for sender ID $senderId');

      // Refresh the list of unfollow notifications after deletion
      setState(() {
        unfollowNotificationsList.clear();  // Clear the list to force a reload
        unfollowNotifications = fetchUnfollowNotifications();  // Re-fetch the updated list
      });
    } else {
      print('Failed to reject and delete unfollow request');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.blue,
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
                            backgroundColor: Colors.blue,
                            child: CircularProgressIndicator(),
                          ),
                          title: Text(notificationType == 'follow'
                              ? 'You have a new follow request'
                              : 'You have a new unfollow request'),
                        ),
                      ),
                    );
                  }
                  else if (imageSnapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.blue,
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

                    if (relativeImagePath.isNotEmpty) {
                      photoUrl = 'http://10.0.2.2:3001/' + relativeImagePath.replaceAll('\\', '/');
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.blue,
                            backgroundImage: photoUrl.isNotEmpty
                                ? NetworkImage(photoUrl)
                                : null,
                            child: photoUrl.isEmpty
                                ? Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          title: Text(
                            notificationType == 'follow'
                                ? 'You have a new follow request From'
                                : 'You have a new unfollow request From',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isUnread ? Colors.black : Colors.grey,
                            ),
                          ),
                          subtitle: Text(
                            senderEmail,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: notificationType == 'follow'
                              ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  String senderId = notification['Sender_id'].toString();
                                  approveFollowRequest(senderId);
                                },
                              ),
                              SizedBox(width: 10),
                              IconButton(
                                icon: Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  String senderId = notification['Sender_id'].toString();
                                  rejectFollowRequest(senderId);
                                },
                              ),
                            ],
                          )
                              : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  // No action for unfollow request
                                },
                              ),
                              SizedBox(width: 10),
                              IconButton(
                                icon: Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  String senderId = notification['Sender_id'].toString();
                                  rejectUnfollowRequest(senderId); // Call the method to reject unfollow request
                                },
                              ),
                            ],
                          ),
                          tileColor: isUnread ? Colors.blue[50] : Colors.white,
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
