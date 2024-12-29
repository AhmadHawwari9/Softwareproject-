import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softwaregraduateproject/userprofilepageforhospital.dart';
import 'AdminHomepage.dart';
import 'CareGiverHomepage.dart';
import 'CareRecipientHomepage.dart';
import 'Conversations.dart';
import 'Login.dart';
import 'Myfiles.dart';
import 'Noti.dart';
import 'Notificationpage.dart';
import 'Searchcaregievrpage.dart';
import 'Settingspage.dart';
import 'UserProfilePage.dart';

File? _image;
class HospitalUserForm extends StatefulWidget {
  final String email;
  final String password;
  final String token;
  final bool isGoogleSignInEnabled;
  HospitalUserForm(this.email, this.password, this.token, this.isGoogleSignInEnabled);

  @override
  _HospitalUserFormState createState() => _HospitalUserFormState();
}

class _HospitalUserFormState extends State<HospitalUserForm> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String? name;
  String? imageId;
  String? location;
  String? description;
  String? clinics;
  String? workingHours;
  String? doctors;
  String? contact;

  String? photoUrl;

  File? photoFile;

  Future<void> pickPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        photoFile = File(pickedFile.path);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      var uri = Uri.parse('http://10.0.2.2:3001/updateHospital');
      var request = http.MultipartRequest('POST', uri);

      request.fields['name'] = name ?? '';
      request.fields['location'] = location ?? '';
      request.fields['description'] = description ?? '';
      request.fields['clinics'] = clinics ?? '';
      request.fields['workingHours'] = workingHours ?? '';
      request.fields['doctors'] = doctors ?? '';
      request.fields['contact'] = contact ?? '';

      if (photoFile != null) {
        request.files.add(await http.MultipartFile.fromPath('photo', photoFile!.path));
      }

      request.headers['Authorization'] = 'Bearer ${widget.token}';

      try {
        var response = await request.send();
        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var decodedData = jsonDecode(responseData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hospital information updated successfully!')),
          );
          await fetchHomepageAndNavigate(context, widget.email, widget.password, widget.token, false);
          // Clear photo file after successful submission
          setState(() {
            _image = null; // Reset photo file state
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update hospital information.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while submitting the form.')),
        );
      }
    }
  }



  @override
  void initState() {
    super.initState();
    fetchHomepageData();
    fetchHospitalData();
  }

  Future<void> fetchHomepageAndNavigate(
      BuildContext context, String email, String password, String token, bool isGoogleSignInEnabled) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3001/api/homepage'),
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
        } else if(userType == 'Care giver') {
          homepage = CareGiverHomepage(email, password, token, isGoogleSignInEnabled);
        }else{
          homepage=HospitalUserForm(email, password, token, isGoogleSignInEnabled);
        }

        // If mounted, navigate to the homepage
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => homepage),
          );
        }
      } else {
        _showErrorDialog('Failed to load homepage data');
      }
    } catch (e) {
      _showErrorDialog('An error occurred: $e');
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
  String? apiResponse;

  Future<void> fetchHomepageData() async {
    final homepageUrl = Uri.parse('http://10.0.2.2:3001/api/homepage');
    final imageUrl = Uri.parse('http://10.0.2.2:3001/user/image/${widget.email}');

    try {
      final homepageResponse = await http.get(
        homepageUrl,
        headers: {
          'Content-Type': 'application/json',
          'token': widget.token ?? ''
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
          'token': widget.token ?? ''
        },
      );

      if (imageResponse.statusCode == 200) {
        final imageData = jsonDecode(imageResponse.body);
        String relativeImagePath = imageData['imagePath'];
        setState(() {
          photoUrl = 'http://10.0.2.2:3001/' + relativeImagePath.replaceAll('\\', '/');
        });
        print("Photo URL: $photoUrl");  // Add a print statement to confirm the URL
      } else {
        setState(() {
          photoUrl = null;  // In case of error, clear the photo URL
        });
      }

    } catch (error) {
      setState(() {
        apiResponse = 'Error: $error';
        photoUrl = null;
      });
    }
  }

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _image = File(result.files.single.path!);
      });
    }
  }

  int notificationCount = 0;

  Future<void> fetchNotificationCount() async {
    final url = 'http://10.0.2.2:3001/notification-count';
    final headers = {
      'Authorization': 'Bearer ${widget.token}',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          notificationCount = data['notificationCount']; // Update the notification count
          if(notificationCount>0){
            sendMessage("SafeAging");
            Noti.showBigTextNotification(title: "SafeAging",body: "You Have New $notificationCount Notifications",fln:flutterLocalNotificationsPlugin );
          }
        });
      } else {
        print('Failed to fetch notification count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notification count: $e');
    }
  }

  int unreadMessageCount = 0;

  Future<void> fetchUnreadMessagesCount() async {
    final url = Uri.parse('http://10.0.2.2:3001/unread-message-count');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}', // Send the token in the header
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data');  // Debug: print the response body

        // Ensure 'unreadMessageCount' exists and is a valid integer
        if (data.containsKey('unreadMessageCount') && data['unreadMessageCount'] is int) {
          setState(() {
            unreadMessageCount = data['unreadMessageCount'];
            if(unreadMessageCount>0){
              sendMessage("SafeAging");
              Noti.showBigTextNotification(title: "SafeAging",body: "You Have New $unreadMessageCount Messages",fln:flutterLocalNotificationsPlugin );
            }
          });
        } else {
          print('Unread message count is missing or not an integer.');
          setState(() {
            unreadMessageCount = 0;
          });
        }
      } else {
        print('Failed to load unread message count. Status code: ${response.statusCode}');
        setState(() {
          unreadMessageCount = 0; // Default to 0 if the request fails
        });
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        unreadMessageCount = 0; // Default to 0 in case of error
      });
    }
  }

  int _selectedIndex = 0;


  Future<void> _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        await fetchHomepageAndNavigate(context, widget.email, widget.password, widget.token, false);
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ConversationsPage(widget.email,widget.password,widget.token,false)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SearchPageCaregiver(widget.email,widget.password,widget.token,false)),
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

  Map<String, dynamic>? hospitalData;  // To store hospital data

  Future<void> fetchHospitalData() async {
    const String apiUrl = 'http://10.0.2.2:3001/hospitalbyidfromauthnitication';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          hospitalData = json.decode(response.body)['data'];  // Store the fetched data
        });
      } else {
        throw Exception('Failed to load hospital data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        hospitalData = null;  // Handle the error by setting the hospital data to null
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.teal,
        elevation: 10,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu,color: Colors.white,),
              onPressed: () {
                // Open the Drawer when the menu icon is pressed
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 30.0,
                ),
                onPressed: () async {
                  setState(() {
                    notificationCount = 0; // Reset notification count to zero
                  });

                  // Navigate to the Notifications Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsPage(widget.token, false),
                    ),
                  );
                },
              ),
              if (notificationCount > 0) // Show badge if there are unread notifications
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$notificationCount', // Unread notifications count
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Drawer header with a more polished design
            UserAccountsDrawerHeader(
              accountName: null,
              accountEmail: Padding(
                padding: EdgeInsets.only(bottom: 20),  // Adjusted padding
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserProfilePageforhospital(jwtToken: widget.token, email: widget.email)),
                    );
                  },
                  child: Text(
                    widget.email ?? "No email provided",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18, // Slightly larger and bolder for better visibility
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserProfilePageforhospital(jwtToken: widget.token, email: widget.email)),
                  );
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
                  child: photoUrl == null
                      ? Icon(Icons.person, size: 50, color: Colors.teal)
                      : null,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            // Drawer menu items with custom font styles and padding
            ListTile(
              leading: Icon(Icons.home, color: Colors.teal),
              title: Text("Home", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w500)),
              onTap: () async {
                await fetchHomepageAndNavigate(context, widget.email, widget.password, widget.token, false);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.teal),
              title: Text("Settings", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage(widget.email, widget.password, widget.token, widget.isGoogleSignInEnabled)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.teal),
              title: Text("Logout", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w500)),
              onTap: () {
                _logout();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (hospitalData != null) ...[
                _buildTextSection('Name', hospitalData?['name'], Icons.account_circle),
                _buildTextSection('Location', hospitalData?['location'], Icons.location_on),
                _buildTextSection('Description', hospitalData?['description'], Icons.description),
                _buildTextSection('Clinics', hospitalData?['clinics'], Icons.local_hospital),
                _buildTextSection('Working Hours', hospitalData?['workingHours'], Icons.access_time),
                _buildTextSection('Doctors', hospitalData?['doctors'], Icons.medical_services),
                _buildTextSection('Contact', hospitalData?['contact'], Icons.phone),
                _buildTextSection('Email', hospitalData?['user_email'], Icons.email),
                SizedBox(height: 20),
              ],
              Divider(color: Colors.teal, thickness: 3),  // Horizontal line

              SizedBox(height: 20),
              Text('Add/Update Hospital Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              SizedBox(height: 20),
              _buildTextFormField('Name', 'Please enter the hospital name', (value) => name = value),
              SizedBox(height: 20),
              _buildTextFormField('Location', null, (value) => location = value),
              SizedBox(height: 20),
              _buildTextFormField('Description', null, (value) => description = value, maxLines: 3),
              SizedBox(height: 20),
              _buildTextFormField('Clinics', null, (value) => clinics = value, maxLines: 3),
              SizedBox(height: 20),
              _buildTextFormField('Working Hours', null, (value) => workingHours = value),
              SizedBox(height: 20),
              _buildTextFormField('Doctors', null, (value) => doctors = value, maxLines: 3),
              SizedBox(height: 20),
              _buildTextFormField('Contact', 'Please enter the contact information', (value) => contact = value),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),

            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.teal),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,  // To allow the badge to overlap the icon
              children: [
                const Icon(Icons.chat, color: Colors.teal), // Icon can remain constant
                if (unreadMessageCount > 0)
                  Positioned(
                    top: -4, // Adjust the vertical position of the badge
                    right: -4, // Adjust the horizontal position of the badge
                    child: CircleAvatar(
                      radius: 8, // Reduced radius for a smaller badge
                      backgroundColor: Colors.red,
                      child: Text(
                        unreadMessageCount.toString(), // Dynamically fetch the count
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10, // Reduced font size for the number
                        ),
                      ),
                    ),
                  ),

              ],
            ),
            label: 'Chat',
          ),


          const BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.teal),
            label: 'Search',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu, color: Colors.teal),
            label: 'Browse',
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField(String label, String? validatorText, Function(String?) onSaved, {int maxLines = 1}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.teal, fontWeight: FontWeight.w500),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
        border: OutlineInputBorder(),
      ),
      validator: (value) => value == null || value.isEmpty ? validatorText : null,
      onSaved: (value) => onSaved(value),
      maxLines: maxLines,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: EdgeInsets.only(right: 60),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, color: Colors.teal, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextSection(String label, String? value, IconData icon) {
    if (value == null || value.isEmpty) {
      return SizedBox.shrink(); // Don't show if null or empty
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.teal, size: 24),  // Icon for each section
            SizedBox(width: 8),  // Space between icon and text
            Expanded(
              child: Text(
                '$label: $value',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.teal,  // Teal text color
                  fontWeight: FontWeight.w600, // Bold enough for readability
                  letterSpacing: 0.5,  // Slight letter spacing for better appearance
                ),
              ),
            ),
          ],
        ),
      );
    }
  }



  Widget _buildImageUpload() {
    return GestureDetector(
      onTap: pickFile,
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.teal, width: 2),
          image: _image != null ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover) : null,
        ),
        child: _image == null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload, color: Colors.teal, size: 40),
            SizedBox(height: 8),
            Text(
              "Upload Photo",
              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
            ),
          ],
        )
            : null,
      ),
    );
  }

}

Future<void> sendMessage(String title) async {
  const accessToken =
      'Bearer ya29.c.c0ASRK0GZ228tBpIJVFKGFDU5BRXqbr05UzUocSNhtm6ZtYL3O_iynrS2egT1ILTplhpsgjb2cS6Ya6aWVDPqLRIlGdH2SbqcjUX737pknkHJ-_4j3VlKZLl9pZvhBSY7vryLyjdpEMrH2LZ4FAsRPCBPYNyj1LnOlBov_hqzksJntOxBOlHfPK7aZEniN_P1RUDJFEz2h6u3L6ou6WfHMJ7AnLMIZLctmgSuZ8V10TbdLg86gAvy_0JfrCaVQwrsQO0EDgNGmRNS8g_Qs19ITxNeBkZM4mt8xM5PNnbctCl5coeO8nvbE8czB2V3Jk7pPxg2ZZvwOPTxIlblfZFxvckWiTtJDJ0hRBahlLhIIf697EHXHg98qlokKWAN387KwOu4F0MMuIne505t6oznxnOa87IkR6VfIFwFi3m-2qxuX6xr63rQ70qs98vw9aMx5helWjWri4QS4w1VtQWtmwyvZxY-3oX0XOhnqb9n7x3fn8rfBv3OkJohJl7yW4abj7V9OqxtMmO74av5iQ0jz1SvoeI4M-1v2d9Z4rgmuqMdsnu6pro8iQB8VbWZlRB4RhufvruSX68ej_4Mj8O0I17ddcY8uaZfRQ68VstY3Qpws5_vSca4oaJXqtjQa0MZu8tYnu7do7w0ufvVo68UcY9lOZsF3qtFr4FUbUf1VfR1O0711nBYaOaW7i3vy-6xfhwBBwiVl7c1mejWxs7cFicqval4IFbQx0cmgYOW3JhlRnQFu5msqknlSrvdeprqIcf35uozgJaVWg9tOSR366r6iv-l05ixeen7JbtZbjORkty-3Mw1xQroXmvbxqsheIdmXmzyyz3qpfo2Woc4pw7BlsSr7w5cjhmkVo_uyekZ2uU2mzWtkww8JQUamOaf4z3hukrcm6o9lm60RomfsaVJevrnjWMocOuUkeV_78jz2kIBIjjkqYm4sJo0ZZjcaox403Yo86lgBbXU-fjZ0XU9bW-J02fs_Ra4p8wjb';

  const fcmEndpoint =
      'https://fcm.googleapis.com/v1/projects/softwareproject-e838c/messages:send';
  const receiverToken =
      'crJ1lj5kR-O_ylFMbzC07q:APA91bERmz7BnHAGchWSP_7XKxoR3BjBuzPFEBnSTLovqA5fJezf9jq0ZwrgHNo_fYUIZjrLoNFpsqG7FnF5wtzy--QEsRuKBCHKEI7hGVRL9jFG93ssSKQ';

  var body = json.encode({
    "message": {
      "token": receiverToken,
      "notification": {
        "title": title,
        "body": "You Have New Message",
      },
      "data": {
        "key1": "value1", // Example custom data
        "key2": "value2",
      },
      "android": {
        "priority": "high", // Set priority to "high" for background delivery
        "notification": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK", // Handles notification click
        }
      },
      "apns": {
        "headers": {
          "apns-priority": "10", // High priority for iOS
        },
        "payload": {
          "aps": {
            "alert": {
              "title": title,
              "body": "You Have New Message",
            },
            "content-available": 1, // Ensures background delivery
          }
        }
      }
    }
  });

  try {
    var headers = {
      'Authorization': 'Bearer $accessToken',
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