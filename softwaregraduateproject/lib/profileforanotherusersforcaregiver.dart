import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'chatwithspecificperson.dart';


class UserDetailsPageforcaregiver extends StatefulWidget {
  final String id;
  final String savedToken;

  const UserDetailsPageforcaregiver({Key? key, required this.id,required this.savedToken}) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPageforcaregiver> {
  late Map<String, dynamic> userData;
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',style: TextStyle(color: Colors.teal),),
        backgroundColor: Colors.teal,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isError
          ? Center(child: Text('Error loading user data'))
          : Container(
        // Full screen background
        height: double.infinity,  // Ensures it takes the full height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.teal],
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
                // Profile Image Section
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

                // Name Section
                Text(
                  '${userData['First_name']} ${userData['Last_name']}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),

                // Email Section
                Text(
                  userData['Email'] ?? 'No email available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 20),

                // Buttons Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                        context,
                        label: 'Message',
                        icon: FontAwesomeIcons.commentDots,
                        color: Colors.teal,
                        onPressed: () {
                          // Navigate to the ChatScreen
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
                        }
                    ),

                  ],
                ),
                SizedBox(height: 20),

                // Info Cards
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
            Icon(icon, size: 30, color: Colors.teal),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
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
