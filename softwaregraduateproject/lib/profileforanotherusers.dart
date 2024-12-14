import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'chatwithspecificperson.dart';

class UserDetailsPage extends StatefulWidget {
  final String id;
  final String savedToken;

  const UserDetailsPage({Key? key, required this.id, required this.savedToken}) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  late Map<String, dynamic> userData;
  bool isLoading = true;
  bool isError = false;
  bool isRequested = false; // Tracks if the user has already requested
  bool isFollowing = false; // Track if the user is already following


  @override
  void initState() {
    super.initState();
    fetchUserData();
    checkIfFollowing();
    checkUnfollowRequest();
    checkNotifications(); // Check if this user has been followed/requested
  }

  Future<void> checkIfFollowing() async {
    final url = Uri.parse('http://10.0.2.2:3001/caregivers');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${widget.savedToken}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Ensure 'careRecipients' is available and not null
        if (data['careRecipients'] != null) {
          // Loop through careRecipients and check if the user is following
          for (var recipient in data['careRecipients']) {
            if (recipient['Care_giverid'].toString() == widget.id) {
              setState(() {
                isFollowing = true; // Set to true if the user is following
              });
              break;
            }
          }
        } else {
          setState(() {
            isFollowing = false; // No caregivers data found
          });
        }
      } else {
        print('Error fetching caregivers data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking if following: $e');
    }
  }

  String globalEmail = '';

  Future<void> fetchUserData() async {
    final String url = 'http://10.0.2.2:3001/getUsersforsearch/${widget.id}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true) {
          setState(() {
            userData = data['data'];
            isLoading = false;
            isError = false;
            globalEmail = userData['Email']; // Storing email in global variable
          });
        } else {
          setState(() {
            isLoading = false;
            isError = true;
          });
          _showErrorDialog('User not found!');
        }
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });
        _showErrorDialog('Failed to load user details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
      _showErrorDialog('An error occurred: $e');
    }
  }

  Future<void> checkNotifications() async {
    // API call to check if a follow request exists for the current user
    final url = Uri.parse('http://10.0.2.2:3001/notificationssender');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${widget.savedToken}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if any notification exists where the receiver_id is the current user ID
        if (data['notifications'] != null) {
          for (var notification in data['notifications']) {
            if (notification['reciver_id'].toString() == widget.id && notification['typeofnotifications'] == 'follow') {
              setState(() {
                isRequested = true; // Set to true if already requested
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  Future<void> _sendFollowRequest() async {
    final url = Uri.parse('http://10.0.2.2:3001/follow'); // Replace with actual API URL

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.savedToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'reciver_id': widget.id}),
      );

      if (response.statusCode == 200) {
        setState(() {
          isRequested = true; // Change the button state to "Requested"
        });
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${errorData['error']}')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.')));
    }
  }

  void _showErrorDialog(String message) {
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
  Future<void> checkUnfollowRequest() async {
    final url = Uri.parse('http://10.0.2.2:3001/getUnfollowNotifications');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${widget.savedToken}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if the response contains unfollow notifications
        if (data['notifications'] != null) {
          for (var notification in data['notifications']) {
            if (notification['reciver_id'].toString() == widget.id &&
                notification['typeofnotifications'] == 'unfollow') {
              setState(() {
                hasUnfollowRequest = true; // Set to true if unfollow requested
              });
              break;
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching unfollow notifications: $e');
    }
  }
  bool hasUnfollowRequest = false;




  Future<void> _toggleFollowRequest() async {
    // Define the API endpoints
    final endpoints = {
      'getUnfollowNotifications': Uri.parse('http://10.0.2.2:3001/getUnfollowNotifications'), // GET
      'unfollow': Uri.parse('http://10.0.2.2:3001/unfollow'), // POST
      'deleteFollowRequest': Uri.parse('http://10.0.2.2:3001/Deletefollowrequest/${widget.id}'), // DELETE
      'deleteUnfollowRequest': Uri.parse('http://10.0.2.2:3001/DeleteUnfollowRequest/${widget.id}'), // DELETE
      'follow': Uri.parse('http://10.0.2.2:3001/follow'), // POST
    };

    try {
      http.Response response;

      // Determine the API to call and the HTTP method
      if (hasUnfollowRequest) {
        // Delete unfollow request
        response = await http.delete(
          endpoints['deleteUnfollowRequest']!,
          headers: {
            'Authorization': 'Bearer ${widget.savedToken}',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            hasUnfollowRequest = false;
            isFollowing = true; // Transition directly to "Following"
          });
          return;
        }
      } else if (isFollowing) {
        // Unfollow
        response = await http.post(
          endpoints['unfollow']!,
          headers: {
            'Authorization': 'Bearer ${widget.savedToken}',
            'Content-Type': 'application/json',
          },
          body: json.encode({'reciver_id': widget.id}),
        );

        if (response.statusCode == 200) {
          setState(() {
            isFollowing = false; // Unfollowed
            hasUnfollowRequest = true; // Transition to "Unfollow Requested"
          });
          return;
        }
      } else if (isRequested) {
        // Cancel follow request
        response = await http.delete(
          endpoints['deleteFollowRequest']!,
          headers: {
            'Authorization': 'Bearer ${widget.savedToken}',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            isRequested = false; // Follow request canceled
          });
          return;
        }
      } else {
        // Follow
        response = await http.post(
          endpoints['follow']!,
          headers: {
            'Authorization': 'Bearer ${widget.savedToken}',
            'Content-Type': 'application/json',
          },
          body: json.encode({'reciver_id': widget.id}),
        );

        if (response.statusCode == 200) {
          setState(() {
            isRequested = true; // Follow requested
            isFollowing = false; // Ensure it doesn't show "Following" yet
          });
          return;
        }
      }

      // Handle non-200 responses
      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${errorData['error']}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isError
          ? Center(child: Text('Error loading user data'))
          : Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: userData['image_path'] != null
                        ? Image.network(
                      'http://10.0.2.2:3001/${userData['image_path'].startsWith('/') ? userData['image_path'].substring(1) : userData['image_path']}',
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      'assets/default_profile.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '${userData['First_name']} ${userData['Last_name']}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  userData['Email'] ?? 'No email available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context,
                      label: 'Message',
                      icon: FontAwesomeIcons.commentDots,
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              otherUserId: widget.id,
                              userEmail: globalEmail,
                              jwtToken: widget.savedToken,
                            ),
                          ),
                        );
                      },
                    ),
          _buildActionButton(
            context,
            label: hasUnfollowRequest
                ? 'Unfollow Requested'
                : isRequested
                ? 'Requested'
                : isFollowing
                ? 'Following'
                : 'Follow',
            icon: hasUnfollowRequest
                ? Icons.check // Unfollow requested icon
                : isRequested
                ? Icons.check// Follow request icon
                : isFollowing
                ? Icons.check
                : Icons.person_add,
            color: hasUnfollowRequest
                ? Colors.blue
                : isRequested
                ? Colors.blue
                : isFollowing
                ? Colors.blue
                : Colors.blueAccent,
            onPressed: _toggleFollowRequest,
          ),



          ],
                ),
                SizedBox(height: 20),
                _buildInfoCard(
                  context,
                  title: 'Bio',
                  content: userData['Bio'] ?? 'No bio available',
                  icon: Icons.person,
                ),
                SizedBox(height: 16),
                _buildInfoCard(
                  context,
                  title: 'User Type',
                  content: userData['Type_oftheuser'] ?? 'Not available',
                  icon: Icons.group,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required String title, required String content, required IconData icon}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.blueAccent),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required String label,
        required IconData icon,
        required Color color,
        required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
