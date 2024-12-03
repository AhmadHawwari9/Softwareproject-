import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserDetailsPage extends StatefulWidget {
  final String id;

  const UserDetailsPage({Key? key, required this.id}) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  late Map<String, dynamic> userData;
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

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
        title: Text('Profile'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isError
          ? Center(child: Text('Error loading user data'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section with Blue Background
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent, // Blue background
                    shape: BoxShape.circle, // Make it circular
                  ),
                  padding: EdgeInsets.all(5), // Padding around the image
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
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
              ),
              SizedBox(height: 20),

              // Name Section
              Text(
                '${userData['First_name']} ${userData['Last_name']}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 8),

              // Email Section
              Text(
                userData['Email'] ?? 'No email available',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 20),

              // Bio Section
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bio:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        userData['Bio'] ?? 'No bio available',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // User Type Section
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        'User Type:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        userData['Type_oftheuser'] ?? 'Not available',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
