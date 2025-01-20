import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'AdminHomepage.dart';
import 'CareGiverHomepage.dart';
import 'CareRecipientHomepage.dart';
import 'Conversations.dart';
import 'DoctorPage.dart';
import 'Emergencybuttonsettings.dart';
import 'Historypage.dart';
import 'HospitalPage.dart';
import 'Hospitaluser.dart';
import 'Login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'MyDoctors.dart';
import 'Myfiles.dart';
import 'Noti.dart';
import 'Notificationpage.dart';
import 'PdfReader.dart';
import 'PharmaceuticalPage.dart';
import 'Reportsshowtocaregiver.dart';
import 'Searchpage.dart';
import 'Settingspage.dart';
import 'UserProfilePage.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb


class CareRecipientHomepage extends StatefulWidget {
  final String savedEmail;
  final String savedPassword;
  final String savedToken;
  final bool isGoogleSignInEnabled;

  CareRecipientHomepage(this.savedEmail, this.savedPassword, this.savedToken, this.isGoogleSignInEnabled);

  @override
  State<CareRecipientHomepage> createState() => _HomepageState();
}

class _HomepageState extends State<CareRecipientHomepage> {
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

  // Carousel card variables
  int currentCardIndex = 0;
  bool movingForward = true;
  final ScrollController _scrollController = ScrollController();

  List<dynamic> scheduleData = []; // Holds the data from the database
  bool isLoading = false;

  List<Map<String, dynamic>> careRecipients = [
  ];

  @override
  void initState() {
    super.initState();
    _loadCredentials();
    _fetchConversations();
    fetchAndStoreUserId();
    fetchNotificationCount();
    getAccessToken();
    fetchUnreadMessagesCount();
    getToken();
    fetchMedicationReminders();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("new message");
        print(message.notification!.title);
        print(message.notification!.body);
      }
    });


  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<String>> fetchMedicationReminders() async {
    final apiUrl = kIsWeb
        ? 'http://localhost:3001/medication-reminder'  // Web environment
        : 'http://10.0.2.2:3001/medication-reminder'; // Emulator/Device environment

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer ${widget.savedToken}', // Include the token in the headers
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['reminders'] ?? []);
    } else {
      throw Exception('Failed to fetch medication reminders');
    }
  }


  final TextEditingController _pulseController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();
  final TextEditingController _bloodPressureController = TextEditingController();
  Future<void> fetchSchedule() async {
    final apiUrl = kIsWeb
        ? 'http://localhost:3001/ScheduleforCaregiver'  // Web environment
        : 'http://10.0.2.2:3001/ScheduleforCaregiver'; // Emulator/Device environment

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${widget.savedToken}', // Send the token in the Authorization header
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          scheduleData = jsonDecode(response.body); // Decode JSON response
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load schedule');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  Future<void> _fetchConversations() async {
    if (widget.savedToken.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "JWT token is missing.";
      });
      return;
    }

    final apiUrl = kIsWeb
        ? 'http://localhost:3001/chat/conversations'  // Web environment
        : 'http://10.0.2.2:3001/chat/conversations'; // Emulator/Device environment

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
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

        for (var conversation in fetchedConversations) {
          String userEmail = conversation['user_email'] ?? '';
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




  int? userId; // Class-level variable to store user ID as an integer

  Future<void> fetchAndStoreUserId() async {
    String base = (kIsWeb)
        ? 'http://localhost:3001' // For web
        : 'http://10.0.2.2:3001'; // For Android Emulator

    final url = Uri.parse('$base/getuseidbytoken');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.savedToken}', // Pass the token
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Parse the userId to int and store it
        userId = int.tryParse(responseData['userId'].toString());

        if (userId != null) {
          print("User ID fetched and stored: $userId");
        } else {
          print("Failed to parse user ID as an integer.");
        }
      } else {
        print("Failed to fetch user ID. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user ID: $e");
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
  Future<void> fetchHomepageData() async {
    // Determine the base URL based on platform (web or mobile)
    final baseUrl = kIsWeb
        ? 'http://localhost:3001' // Web environment (localhost or public URL)
        : 'http://10.0.2.2:3001'; // Mobile emulator

    final homepageUrl = Uri.parse('$baseUrl/api/homepage');
    final imageUrl = Uri.parse('$baseUrl/user/image/${widget.savedEmail}');

    try {
      // Fetch homepage data
      final homepageResponse = await http.get(
        homepageUrl,
        headers: {
          'Content-Type': 'application/json',
          'authorization': token ?? '',
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

      // Fetch image data
      final imageResponse = await http.get(
        imageUrl,
        headers: {
          'Content-Type': 'application/json',
          'authorization': token ?? '',
        },
      );

      if (imageResponse.statusCode == 200) {
        final imageData = jsonDecode(imageResponse.body);
        String relativeImagePath = imageData['imagePath'];
        setState(() {
          photoUrl = '$baseUrl/' + relativeImagePath.replaceAll('\\', '/');
        });
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


  int _selectedIndex = 0;


  Future<void> _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        await fetchHomepageAndNavigate(context, email!, password!, token!, false);
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ConversationsPage(email!,password!,token!,false)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SearchPage(email!,password!,token!,false)),
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

  double? _latitude; // Store latitude
  double? _longitude; // Store longitude

  Future<void> _getCurrentLocation() async {
    try {
      // Check and request location permissions
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("Location permission denied");
        return;
      }

      // Fetch the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update the state with the fetched coordinates
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      print("Latitude: $_latitude, Longitude: $_longitude");
    } catch (e) {
      print("Failed to get location: $e");
    }
  }

  Future<void> fetchMedicalReports(String careRecipientId) async {
    final apiUrl = kIsWeb
        ? 'http://localhost:3001/user/files/$careRecipientId' // Web environment
        : 'http://10.0.2.2:3001/user/files/$careRecipientId'; // Emulator/Device environment

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> files = data['files'] ?? []; // Handle null case for 'files'

        // Navigate to the new page and pass the files (even if empty)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicalReportsPage(files: files),
          ),
        );
      } else {
        // If the response is not successful, navigate with an empty list
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicalReportsPage(files: []),
          ),
        );
      }
    } catch (e) {
      print('Error fetching files: $e');
      // Navigate with an empty list if an error occurs
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicalReportsPage(files: []),
        ),
      );
    }
  }


// Function to show the medical reports in a dialog
  void showMedicalReportsDialog(List<dynamic> files) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Medical Reports'),
          content: Container(
            width: double.maxFinite,
            height: 200,
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return ListTile(
                  title: Text(file['name'] ?? 'Unnamed file'),
                  subtitle: Text(file['path'] ?? 'No path available'),
                  onTap: () {
                    // You can add navigation to the PDF viewer here
                    print('Tapped on ${file['name']}');
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _checkHealthStatus() {
    final String pulseText = _pulseController.text;
    final String sugarText = _sugarController.text;
    final String bloodPressureText = _bloodPressureController.text;

    if (pulseText.isNotEmpty && sugarText.isNotEmpty && bloodPressureText.isNotEmpty) {
      final int? pulse = int.tryParse(pulseText);
      final int? sugar = int.tryParse(sugarText);
      final List<String> bloodPressureParts = bloodPressureText.split('/');
      if (bloodPressureParts.length == 2) {
        final int? systolic = int.tryParse(bloodPressureParts[0]);
        final int? diastolic = int.tryParse(bloodPressureParts[1]);

        if (pulse != null &&
            sugar != null &&
            systolic != null &&
            diastolic != null &&
            pulse >= 60 &&
            pulse <= 90 &&
            sugar >= 80 &&
            sugar <= 100 &&
            systolic >= 110 &&
            systolic <= 125 &&
            diastolic >= 70 &&
            diastolic <= 80) {
          _showMessage(context, 'Good Condition', 'Your health status is good. Keep it up!');
        } else {
          _showMessage(context, 'Consult a Doctor', 'Your values are abnormal. Please consult your doctor.');
        }
      } else {
        _showMessage(context, 'Invalid Input', 'Please enter blood pressure in the format systolic/diastolic.');
      }
    } else {
      _showMessage(context, 'Missing Data', 'Please fill in all the fields.');
    }
  }

  void _showMessage(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> careRecipients1 = [];

  Future<void> fetchCareRecipients() async {
    final apiUrl = kIsWeb
        ? 'http://localhost:3001/getCareRecipients' // Web environment
        : 'http://10.0.2.2:3001/getCareRecipients'; // Emulator/Device environment

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${widget.savedToken}', // Include token in the headers
        },
      );

      // Log the status and response for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Log the response data
        print('Response Data: $responseData');

        // Extract the 'data' field from the response
        if (responseData.containsKey('data')) {
          setState(() {
            careRecipients = List<Map<String, dynamic>>.from(responseData['data']);
          });
        } else {
          throw Exception('Missing "data" in response');
        }
      } else {
        throw Exception('Failed to fetch care recipients. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  Widget _buildInputCard(BuildContext context, String label, String hint, IconData icon, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }


  Widget _buildFeatureButton(String label, IconData icon, String page) {
    return SizedBox(
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () => _navigateTo(page),
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  void _navigateTo(String page) {
    if (page == 'settings') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(widget.savedEmail,widget.savedPassword,widget.savedToken,widget.isGoogleSignInEnabled)));
    } else if (page == 'doctor') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => CareGiversScreen(widget.savedToken)));
    } else if (page == 'pharmaceutical') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => PharmaceuticalPage(widget.savedToken)));
    } else if (page == 'hospital') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => HospitalsPage(widget.savedToken)));
    }else if(page=='PDFReaderApp'){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFReaderApp(jwtToken:widget.savedToken),
        ),
      );
    }
  }
  int notificationCount = 0;
  Future<void> fetchNotificationCount() async {
    // Determine the base URL based on platform (web or mobile)
    final baseUrl = kIsWeb
        ? 'http://localhost:3001' // Web environment (localhost)
        : 'http://10.0.2.2:3001'; // Mobile emulator

    final url = Uri.parse('$baseUrl/notification-count');
    final headers = {
      'Authorization': 'Bearer ${widget.savedToken}',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          notificationCount = data['notificationCount']; // Update the notification count
          if (notificationCount > 0) {
            // Noti.showBigTextNotification(
            //   title: "SafeAging",
            //   body: "You Have New $notificationCount Notifications",
            //   fln: flutterLocalNotificationsPlugin,
            // );

            sendNotification(
              title: "SafeAging",
              message: "You Have New $notificationCount Notifications",
              userId: userId.toString(),  // Pass the userId variable here
            );
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
    // Determine the base URL based on platform (web or mobile)
    final baseUrl = kIsWeb
        ? 'http://localhost:3001' // Web environment (localhost)
        : 'http://10.0.2.2:3001'; // Mobile emulator

    final url = Uri.parse('$baseUrl/unread-message-count');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.savedToken}', // Send the token in the header
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data');  // Debug: print the response body

        // Ensure 'unreadMessageCount' exists and is a valid integer
        if (data.containsKey('unreadMessageCount') && data['unreadMessageCount'] is int) {
          setState(() {
            unreadMessageCount = data['unreadMessageCount'];
            if (unreadMessageCount > 0) {
              // Noti.showBigTextNotification(
              //   title: "SafeAging",
              //   body: "You Have New $unreadMessageCount Messages",
              //   fln: flutterLocalNotificationsPlugin,
              // );

              sendNotification(
                title: "SafeAging",
                message: "You Have New $unreadMessageCount Messages",
                userId: userId.toString(),  // Pass the userId variable here
              );
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


  Future<String> fetchUserhistory() async {
    // Your API URL for fetching reports
    final apiUrl = kIsWeb
        ? 'http://localhost:3001/user-history' // Web environment
        : 'http://10.0.2.2:3001/user-history'; // Emulator/Device environment

    try {
      // Get the token from the authentication system (e.g., shared preferences or any other method)
      print("Sending request to: $apiUrl");  // Debugging output

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token', // Ensure token is valid
        },
      );

      print("Response Status: ${response.statusCode}"); // Debugging response status

      if (response.statusCode == 200) {
        // Parse the response body
        final data = json.decode(response.body);
        String userId = data['user_id'].toString(); // Get the user_id from the response
        print("User ID: $userId"); // Print user ID
        print("Reports: ${data['reports']}"); // Print reports

        return userId; // Return the user_id
      } else {
        print("Failed to fetch reports: ${response.statusCode}");
        return ''; // Return an empty string if failed
      }
    } catch (e) {
      print("Error making request: $e");
      return ''; // Return an empty string on error
    }
  }


  Future<void> sendNotificationEmergencyAlert(double latitude, double longitude) async {
    final apiUrl = kIsWeb
        ? 'http://localhost:3001/sendNotifications' // Web environment
        : 'http://10.0.2.2:3001/sendNotifications'; // Emulator/Device environment

    try {
      print("Sending request to: $apiUrl"); // Debugging output
      print("Token: $token"); // Debugging token

      // Construct the request body
      final requestBody = {
        'latitude': latitude,
        'longitude': longitude,
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token', // Ensure token is valid
          'Content-Type': 'application/json', // Indicate JSON payload
        },
        body: jsonEncode(requestBody), // Convert the body to JSON
      );

      print("Response Status: ${response.statusCode}"); // Debugging response status

      if (response.statusCode == 200) {
        print("Notification sent successfully!");
      } else {
        print("Failed to send notification: ${response.body}");
      }
    } catch (e) {
      print("Error making request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
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
                      builder: (context) => NotificationsPage(widget.savedToken, true),
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
            // Drawer header (Profile picture and email only)
            UserAccountsDrawerHeader(
              accountName: null, // Remove the name field
              accountEmail: Padding(
                padding: EdgeInsets.only(bottom: 30), // Adjust padding as needed
                child: GestureDetector(
                  onTap: () {
                    // Navigate to another page when email is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserProfilePage(jwtToken: token!, email: email!)), // Replace 'AnotherPage' with your destination page
                    );
                  },
                  child: Text(
                    widget.savedEmail ?? "No email provided",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16, // Slightly larger text for better visibility
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ), // Display email only
              currentAccountPicture: GestureDetector(
                onTap: () {
                  // Navigate to another page when the profile picture is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserProfilePage(jwtToken: token!, email: email!)), // Replace 'AnotherPage' with your destination page
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end, // Align the image at the bottom
                  children: [
                    CircleAvatar(
                      radius: 35, // Make the avatar slightly larger
                      backgroundColor: Colors.white,
                      backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
                      child: photoUrl == null
                          ? Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.teal,
                      ) // Fallback icon if no image URL
                          : null,
                    ),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.teal, // Set the background color of the header to blue
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ), // Rounded corners for the header
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ], // Add shadow for a subtle 3D effect
              ),
            ),
            // Menu items in the drawer
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () async {
                await fetchHomepageAndNavigate(context, email!, password!, token!, false);  // Passing the context to the function
              },
            ),


            ListTile(
              leading: Icon(Icons.add_alert), // Replace with your preferred icon
              title: Text("Emergency button settings"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Emergencybuttonsettings(widget.savedToken)),
                );
              },
            ),


            ListTile(
              leading: Icon(Icons.picture_as_pdf_rounded,),
              title: Text("My Medical Reports"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PdfFilesPage( jwtToken: widget.savedToken,)),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.medical_information),
              title: Text("My Medical History"),
              onTap: () async {
                String userId = await fetchUserhistory(); // Fetch the user ID

                if (userId.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryPage(recipientId: userId), // Pass the user_id to HistoryPage
                    ),
                  );
                } else {
                  // Handle the case where the user_id could not be fetched (e.g., show an error)
                  print("Failed to fetch user ID");
                }
              },
            ),


            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage(widget.savedEmail,widget.savedPassword,widget.savedToken,widget.isGoogleSignInEnabled)),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Logout"),
              onTap: () {
                _logout();
              },
            ),
          ],
        ),
      ),




      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child:  Image.asset(
                      "imgs/project_logo.png",
                      width: MediaQuery.of(context).size.width, // Full width of the screen
                      height: MediaQuery.of(context).size.height * 0.40, // 40% of the screen height
                      fit: BoxFit.cover, // Ensures the image fills the space without distortion
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildInputCard(
                context,
                'Heart Rate (BPM)',
                'Enter your heart rate',
                Icons.monitor_heart_outlined,
                _pulseController,
              ),
              SizedBox(height: 10),
              _buildInputCard(
                context,
                'Blood Sugar (mg/dL)',
                'Enter your blood sugar level',
                Icons.water_drop_outlined,
                _sugarController,
              ),
              SizedBox(height: 10),
              _buildInputCard(
                context,
                'Blood Pressure (systolic/diastolic)',
                'Enter your blood pressure (e.g., 120/80)',
                Icons.bloodtype,
                _bloodPressureController,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkHealthStatus,
                child: Text(
                  'Check Health Status',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildFeatureButton('Hospitals', Icons.local_hospital, 'hospital'),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildFeatureButton('Medications', Icons.medication, 'pharmaceutical'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildFeatureButton('Reports', Icons.description, 'PDFReaderApp'),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildFeatureButton('Doctor', Icons.person, 'doctor'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 50),

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

        ],
      ),
      floatingActionButton: Container(
        width: 70, // Increased width for a larger button
        height: 70, // Increased height for a larger button
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.teal,
              Colors.tealAccent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            // Fetch the current location
            try {
              LocationPermission permission = await Geolocator.requestPermission();
              if (permission == LocationPermission.denied ||
                  permission == LocationPermission.deniedForever) {
                print("Location permission denied");
                return;
              }

              Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              );

              double latitude = position.latitude;
              double longitude = position.longitude;

              print("Latitude: $latitude, Longitude: $longitude");

              // Send the emergency alert with the fetched coordinates
              await sendNotificationEmergencyAlert(latitude, longitude);
            } catch (e) {
              print("Failed to get location: $e");
            }
          },
          backgroundColor: Colors.transparent, // Transparent to show gradient
          elevation: 0, // Remove default shadow
          shape: CircleBorder(),
          child: Text(
            "🚨",
            style: TextStyle(
              fontSize: 30, // Larger emoji size for visibility
              // Optionally, you can add a slight shadow to the emoji for better contrast
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2.0,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
        ),
      ),




    );
  }


  Widget buildCard(int index, String title, String assetPath, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: 315,
        height: 280,
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.7),
              blurRadius: 15,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  assetPath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    shadows: [
                      Shadow(
                        blurRadius: 5,
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> sendMessage(String title) async {
  // Access token from Firebase (ensure it's valid and updated)
  const accessToken =
      'Bearer  ya29.c.c0ASRK0Gbaz8XYJgAUHolvuSYpPD8A7IYu2jBZVf7hdLLoe4Obksl1SgxDNOTM4pvLoc9B1YDIubYsD2Zyfhjm5jMvOR7ZVL5rZhLutdefa3tG6ja68R0bN1cGPm6VgcUOfoEjJwdAcQM_bpcuUkQewFW_sbGXe5mNd4dHe3of8VJ1pzKHke5X8rYttw3a_gSMnqD_b9mqpw228PRHbmGgfMPZFkAAJc7px7s2Z9BnfIY0YFh3JGvKVWdGOrWOgzToyRl46qsvE9iBZBpu_Rl7P-qyXgK7tJGQCNm4Q-J03m0L5OyS3tr93jo2N7xAHfeG0Jnob7uLCea7ofEym222LFoJrLtW9sDOqPxCURoNBppdsAiul95qCz82G385K4QzzbVfaOtJu9kQIOlI3Ra81da5hlutiSlfQdVYMkYwxpBSO5RFr644fSee2OwSmtuM-4nymZOk8mWIrlvIY6O8dlpZu66QcQ2Qjj-IfUjnfbIi1idW1087Siiyzk2Q4hYmiky-ubXSsw38yBXS0U0s-drwRl4p-4oxMFFiSgW1ktxROhxixp3xZ1SocfxUIf5x3nntn2ogw6YU7SotuWBJ9r77RWII87y2mp49fbu6cvM2OF-lh0SWjsn7y1ORuuxw9t2yOMtSMXJQ_cwZYdi98xr8ednineXykxXcQ0Fc02jyu1gbn8Ij_43fO2lIarIYFU6JhMhvs246z6ww11W9b68oiO5zlWzfl8gFebgvWv4k_e-B1WejSytdi6pFkV7ZzoamiztmyxfF9hl2pxpixQO-Ze2jQaVziuRzcV-r4uqFo9eVk2QIo9O1Z998YdJIIhzB-bkzvOXfRM28ruzFajFlwjf2tv4uqz_t49dfk-mXRVgs2nuRBjX5S0FrccpV-zozpwIJYsiI_1o8B34I62_15q_zr3mOy8dXFj0_eF44y5g46Fr4ZYgIotuyfFyw2OffBdfy6inpyVkMZUXwg9Ynp30ln0edIy8Yxt4J';

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





