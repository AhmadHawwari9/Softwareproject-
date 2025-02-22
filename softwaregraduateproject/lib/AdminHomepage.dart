import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softwaregraduateproject/Addarticalfortheadmin.dart';
import 'package:softwaregraduateproject/settingspagefortheadmin.dart';
import 'AdminHomepage.dart';
import 'CareGiverHomepage.dart';
import 'CareRecipientHomepage.dart';
import 'Conversations.dart';
import 'Historypage.dart';
import 'Hospitaluser.dart';
import 'Login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'Myfiles.dart';
import 'Noti.dart';
import 'Notificationpage.dart';
import 'PdfReader.dart';
import 'Reportsshowtocaregiver.dart';
import 'Searchcaregievrpage.dart';
import 'Searchpage.dart';
import 'Settingspage.dart';
import 'UserProfilePage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdfx/pdfx.dart'; // Web-compatible PDF rendering package
import 'dart:io' show File, Directory;


import 'dart:io'; // Import for File handling on mobile platforms
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:universal_html/html.dart' as html;


bool mayarticaldeleted=false;

class AdminHomepage extends StatefulWidget {
  final String savedEmail;
  final String savedPassword;
  final String savedToken;
  final bool isGoogleSignInEnabled;

  AdminHomepage(this.savedEmail, this.savedPassword, this.savedToken, this.isGoogleSignInEnabled);

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

  // Carousel card variables
  int currentCardIndex = 0;
  bool movingForward = true;
  final ScrollController _scrollController = ScrollController();


  List<dynamic> scheduleData = []; // Holds the data from the database
  bool isLoading = false;

  List<Map<String, dynamic>> careRecipients = [];
  List<dynamic> users = [];
  Timer? timer;


  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _loadCredentials();  // Load credentials
      await _fetchConversations();  // Fetch conversations if needed
      await getAccessToken();  // Get access token
      await fetchUsers();  // Fetch users after getting the access token
      fetchArticles();
      fetchHospitalsData();
      fetchAndStoreUserId();
      fetchUnreadMessagesCount();
      setState(() {
        filteredUsers = users;  // Initialize filteredUsers with all users
      });
      fetchNotificationCount();
      await getToken();  // Get token if needed
      await fetchCaregiversData();
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          print("New message: ${message.notification!.title}");
          print(message.notification!.body);
        }
      });
      startScrolling();
    } catch (e) {
      print('Error during initialization: $e');
    }
  }


  int articleCount = 0;  // To store the count of articles
  List<Map<String, dynamic>> articles = [];  // To store the list of articles

  @override
  void dispose() {
    _scrollController.dispose();
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchArticles() async {
    try {
      // Determine the API URL based on platform (web or mobile)
      final apiUrl = kIsWeb
          ? 'http://localhost:3001/articles' // Web environment (localhost or public URL)
          : 'http://10.0.2.2:3001/articles'; // Mobile emulator

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);  // Decode the response body

        setState(() {
          articleCount = data['count'];  // Set the count
          // Cast the 'articles' key to a List<Map<String, dynamic>>
          articles = List<Map<String, dynamic>>.from(data['articles']);
        });
      } else {
        throw Exception('Failed to load articles. Status code: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No Internet connection or server unreachable');
    } catch (e) {
      throw Exception('Unexpected error occurred: $e');
    }
  }



  void startScrolling() {
    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      // Check if the widget is still mounted before calling setState
      if (!mounted) {
        timer.cancel(); // Cancel the timer if the widget is disposed
        return;
      }

      setState(() {
        if (movingForward) {
          currentCardIndex = (currentCardIndex + 1) % articleCount;
        } else {
          currentCardIndex = (currentCardIndex - 1 + articleCount) % articleCount;
        }
      });

      _scrollController.animateTo(
        currentCardIndex * 280.0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      // Ensure scrolling goes to the last card
      if (currentCardIndex == articleCount - 1) {
        movingForward = false;  // Start moving backward after reaching the last card
      } else if (currentCardIndex == 0) {
        movingForward = true;  // Start moving forward after reaching the first card
      }
    });
  }



  Future<void> fetchSchedule() async {
    // Determine the API URL based on platform (web or mobile)
    final apiUrl = kIsWeb
        ? 'http://localhost:3001/ScheduleforCaregiver' // Web environment (localhost or public URL)
        : 'http://10.0.2.2:3001/ScheduleforCaregiver'; // Mobile emulator

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
        throw Exception('Failed to load schedule. Status code: ${response.statusCode}');
      }
    } on SocketException {
      setState(() {
        isLoading = false;
      });
      print('Error: No Internet connection or server unreachable');
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

    // Determine the API URL based on platform (web or mobile)
    final apiUrl = kIsWeb
        ? 'http://localhost:3001/chat/conversations' // Web environment (localhost or public URL)
        : 'http://10.0.2.2:3001/chat/conversations'; // Mobile emulator

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${widget.savedToken}', // Send the token in the Authorization header
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
            //await sendMessage(userEmail);
          }
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load conversations: ${response.statusCode}";
        });
      }
    } on SocketException {
      setState(() {
        _isLoading = false;
        _errorMessage = "No Internet connection or server unreachable.";
      });
      print("Error: No internet connection or server unreachable");
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


  Future<void> fetchUsers() async {
    if (widget.savedToken == null || widget.savedToken.isEmpty) {
      print('No token available');
      return;
    }

    // Determine the API URL based on platform (web or mobile)
    final apiUrl = kIsWeb
        ? 'http://localhost:3001/usersoperationsforadmin' // Web environment (localhost or public URL)
        : 'http://10.0.2.2:3001/usersoperationsforadmin'; // Mobile emulator

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer ${widget.savedToken}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedUsers = json.decode(response.body);

        setState(() {
          users = fetchedUsers;
        });

        print('Users fetched successfully: $users');
      } else {
        print('Failed to fetch users with status: ${response.statusCode}');
      }
    } on SocketException {
      print('Error: No internet connection or server unreachable');
    } catch (e) {
      print('Error fetching users: $e');
    }
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
          MaterialPageRoute(builder: (context) => SearchPageCaregiver(email!,password!,token!,false)),
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


  Future<void> fetchMedicalReports(String careRecipientId) async {
    // Determine the base URL based on platform (web or mobile)
    final baseUrl = kIsWeb
        ? 'http://localhost:3001' // Web environment (localhost or public URL)
        : 'http://10.0.2.2:3001'; // Mobile emulator

    final medicalReportsUrl = Uri.parse('$baseUrl/user/files/$careRecipientId');

    try {
      final response = await http.get(
        medicalReportsUrl,
      );

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


  List<Map<String, dynamic>> careRecipients1 = [];

  // Fetch care recipients with token
  Future<void> fetchCareRecipients() async {
    // Determine the base URL based on platform (web or mobile)
    final baseUrl = kIsWeb
        ? 'http://localhost:3001' // Web environment (localhost or public URL)
        : 'http://10.0.2.2:3001'; // Mobile emulator

    final url = Uri.parse('$baseUrl/getCareRecipients'); // Complete URL for mobile/web

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.savedToken}', // Include token in the headers
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Extract the 'data' field from the response
        setState(() {
          careRecipients = List<Map<String, dynamic>>.from(responseData['data']);
        });
      } else {
        throw Exception('Failed to fetch care recipients');
      }
    } catch (error) {
      print('Error: $error');
      throw Exception('Error: $error');
    }
  }


  Future<void> deleteUser(int userId) async {
    // Determine the base URL based on platform (web or mobile)
    final baseUrl = kIsWeb
        ? 'http://localhost:3001' // Web environment (localhost or public URL)
        : 'http://10.0.2.2:3001'; // Mobile emulator

    final url = Uri.parse('$baseUrl/deleteUser/$userId'); // Complete URL for mobile/web

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.savedToken}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          users.removeWhere((user) => user['User_id'] == userId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      print('Error deleting user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user')),
      );
    }
  }


  void showDeleteConfirmationDialog(int userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User'),
        content: Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              deleteUser(userId); // Call the delete function
            },
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }






  Future<void> moveCaregiverToUser(String requestId) async {
    // Determine the base URL based on platform (web or mobile)
    final baseUrl = kIsWeb
        ? 'http://localhost:3001' // Web environment (localhost or public URL)
        : 'http://10.0.2.2:3001'; // Mobile emulator

    final url = Uri.parse('$baseUrl/movecaregivertouserstable/$requestId'); // Complete URL for mobile/web

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        await fetchUsers();
        fetchCaregiversData();

        print('Caregiver moved to users table successfully');
      } else {
        // Failure: Handle error (maybe show an error message)
        print('Failed to move caregiver to users table');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error occurred: $error');
    }
  }


  Future<void> deletecaregiverfrompending(String requestId) async {
    // Determine the base URL based on platform (web or mobile)
    final baseUrl = kIsWeb
        ? 'http://localhost:3001' // Web environment (localhost or public URL)
        : 'http://10.0.2.2:3001'; // Mobile emulator

    final url = Uri.parse('$baseUrl/deletecaregiver/$requestId'); // Complete URL for mobile/web

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        fetchCaregiversData();
      } else {
        print('Failed to delete the caregiver from pending');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  List<Map<String, dynamic>> hospitals1= [];


  Future<void> fetchCaregiversData() async {
    // Determine the base URL based on platform (web or mobile)
    final baseUrl = kIsWeb
        ? 'http://localhost:3001' // Web environment (localhost or public URL)
        : 'http://10.0.2.2:3001'; // Mobile emulator

    final url = Uri.parse('$baseUrl/caregiverRequestToTheAdminDisplay'); // Complete URL for mobile/web

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parse the response JSON
        List<dynamic> data = json.decode(response.body);
        setState(() {
          // Map the data into a format suitable for the DataTable
          hospitals1 = data.map((item) {
            return {
              'Request_id': item['Request_id'],
              'Email': item['Email'],
              'cv_id': item['cv_id'],
              // Assuming the 'file_path' is added as a part of the response
              'File': item['cv_path'] ?? 'No file available', // If file path is returned as 'cv_file_path'
            };
          }).toList();
        });
      } else {
        print('Failed to load hospitals');
        // Handle error if necessary
      }
    } catch (error) {
      print('Error fetching hospitals data: $error');
    }
  }



  List<Map<String, dynamic>> hospitals = [];

  Future<void> fetchHospitalsData() async {
    // Determine the base URL based on platform (web or mobile)
    final baseUrl = kIsWeb
        ? 'http://localhost:3001' // Web environment (localhost or public URL)
        : 'http://10.0.2.2:3001'; // Mobile emulator

    final url = Uri.parse('$baseUrl/hospitalRequestToTheAdminDisplay'); // Complete URL for mobile/web

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parse the response JSON
        List<dynamic> data = json.decode(response.body);
        setState(() {
          // Map the data into a format suitable for the DataTable
          hospitals = data.map((item) {
            return {
              'Request_id': item['Request_id'],
              'Email': item['Email'],
              'cv_id': item['cv_id'],
              'Type_oftheuser':item['Type_oftheuser'],
              // Assuming the 'file_path' is added as a part of the response
              'File': item['cv_path'] ?? 'No file available', // If file path is returned as 'cv_file_path'
            };
          }).toList();
        });
      } else {
        print('Failed to load hospitals');
        // Handle error if necessary
      }
    } catch (error) {
      print('Error fetching hospitals data: $error');
    }
  }


  Future<void> moveHospitalsToUser(String requestId) async {
    // Determine the base URL based on platform (web or mobile)
    final baseUrl = kIsWeb
        ? 'http://localhost:3001' // Web environment (localhost or public URL)
        : 'http://10.0.2.2:3001'; // Mobile emulator

    final url = Uri.parse('$baseUrl/movecaregivertouserstable/$requestId'); // Complete URL for mobile/web

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        await fetchUsers();
        fetchHospitalsData();

        print('Hospital moved to users table successfully');
      } else {
        // Failure: Handle error (maybe show an error message)
        print('Failed to move hospital to users table');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error occurred: $error');
    }
  }


  Future<void> deletehospitalfrompending(String requestId) async {
    // Determine the base URL based on platform (web or mobile)
    final baseUrl = kIsWeb
        ? 'http://localhost:3001' // Web environment (localhost or public URL)
        : 'http://10.0.2.2:3001'; // Mobile emulator

    final url = Uri.parse('$baseUrl/deletecaregiver/$requestId'); // Complete URL for mobile/web

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        fetchHospitalsData();
      } else {
        print('Failed to delete the caregiver from pending');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }



  Future<String> downloadPdf(String pdfPath) async {
    try {
      if (pdfPath.isEmpty) throw Exception('Invalid file path');

      // Determine the base URL based on platform (web or mobile)
      final baseUrl = kIsWeb
          ? 'http://localhost:3001' // Web environment (localhost)
          : 'http://10.0.2.2:3001'; // Mobile emulator

      final url = Uri.parse('$baseUrl/$pdfPath'); // Complete URL for mobile/web

      if (kIsWeb) {
        // Web-specific code
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          final base64Data = base64Encode(bytes);

          // Create an anchor element to trigger the file download on web
          final anchor = html.AnchorElement(href: "data:application/octet-stream;base64,$base64Data")
            ..download = pdfPath.split('/').last
            ..target = 'blank'
            ..click(); // Trigger the download by simulating a click

          return 'File downloaded successfully in the browser';
        } else {
          throw Exception('Failed to download PDF');
        }
      } else {
        // Mobile-specific code (Android/iOS)
        final permissionStatus = await Permission.storage.request();
        if (permissionStatus.isGranted) {
          final response = await http.get(url);
          if (response.statusCode == 200) {
            final appDocDir = await getExternalStorageDirectory();
            if (appDocDir != null) {
              final file = File('${appDocDir.path}/${pdfPath.split('/').last}');
              await file.writeAsBytes(response.bodyBytes); // Save the file

              return file.path; // Return the local path of the file
            } else {
              throw Exception('Failed to get storage directory');
            }
          } else {
            throw Exception('Failed to download PDF');
          }
        } else {
          throw Exception('Storage permission denied');
        }
      }
    } catch (e) {
      print('Error downloading PDF: $e');
      throw e;
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
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredUsers = [];
  void _filterUsers(String query) {
    final filteredList = users.where((user) {
      final email = user['Email'].toLowerCase();
      final userType = user['Type_oftheuser'].toLowerCase();
      final searchQuery = query.toLowerCase();

      // Check if the email or user type contains the search query
      return email.contains(searchQuery) || userType.contains(searchQuery);
    }).toList();

    setState(() {
      filteredUsers = filteredList;
    });
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
                      builder: (context) => NotificationsPage(widget.savedToken, false),
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
              leading: Icon(Icons.settings),
              title: Text("New Artical"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddArticlePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPageforadmin(widget.savedEmail,widget.savedPassword,widget.savedToken,widget.isGoogleSignInEnabled)),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(articles.length, (index) {
                    var article = articles[index];

                    // Ensure 'image_path' is a String, provide a default empty string if null
                    String relativeImagePath = article['image_path'] ?? ''; // If null, use an empty string

                    // Determine the base URL based on platform (web or mobile)
                    final baseUrl = kIsWeb
                        ? 'http://localhost:3001' // Web environment (localhost)
                        : 'http://10.0.2.2:3001'; // Mobile emulator

                    // If the 'image_path' is not empty, construct the photo URL
                    String photoUrl = '';
                    if (relativeImagePath.isNotEmpty) {
                      photoUrl = '$baseUrl/' + relativeImagePath.replaceAll('\\', '/');
                    }

                    // Fetch articles only when necessary (avoid continuous fetching)
                    if (mayarticaldeleted) {
                      fetchArticles(); // Trigger article fetching when the condition is met
                    }

                    return buildCard(
                      index,
                      article['title'], // Dynamic title
                      photoUrl.isNotEmpty ? photoUrl : 'http://example.com/default-image.jpg', // Dynamic image URL or fallback image
                      CardPage(article), // Dynamic page for each article
                    );
                  }),
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'All Users',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: searchController,
                onChanged: (query) {
                  setState(() {
                    filteredUsers = users.where((user) {
                      final email = '${user['Email']} '.toLowerCase();
                      return email.contains(query.toLowerCase());
                    }).toList();
                  });
                },
                style: TextStyle(color: Colors.teal, fontSize: 16),  // Text style for the input
                decoration: InputDecoration(
                  labelText: 'Search User',
                  labelStyle: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,  // Bold label
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),  // Padding for content
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),  // Rounded corners for focused state
                    borderSide: BorderSide(color: Colors.teal, width: 2), // Teal focused border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),  // Rounded corners for enabled state
                    borderSide: BorderSide(color: Colors.teal, width: 1.5), // Thinner border
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.teal),  // Prefix icon color
                  filled: true,  // Fill the background of the TextField
                  fillColor: Colors.teal.withOpacity(0.1),  // Light teal background color
                  focusColor: Colors.teal,  // Focused color
                ),
              ),
            ),


            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Card(
                elevation: 4,
                child: Container(
                  height: 300,  // Increase container height to accommodate larger rows
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.teal),
                      dataRowHeight: 80,  // Increased row height
                      headingRowHeight: 60,  // Increased heading row height
                      columns: [
                        DataColumn(
                          label: Container(
                            width: 80,  // Reduced width for the column
                            child: Text(
                              'Email',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            width: 80,  // Reduced width for the column
                            child: Text(
                              'User Type',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            width: 80,  // Reduced width for the column
                            child: Text(
                              'Actions',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                      rows: filteredUsers.isNotEmpty
                          ? filteredUsers.map<DataRow>((user) {
                        return DataRow(cells: [
                          DataCell(
                            Container(
                              width: 80,  // Reduced width for the cell
                              child: Text(
                                user['Email'],
                                style: TextStyle(fontSize: 12),
                                overflow: TextOverflow.visible,
                                softWrap: true,  // Allow text to wrap to the next line
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: 80,  // Reduced width for the cell
                              child: Text(
                                user['Type_oftheuser'],
                                style: TextStyle(fontSize: 12),
                                overflow: TextOverflow.visible,
                                softWrap: true,  // Allow text to wrap to the next line
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,  // Keep actions compact
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red, size: 18),
                                  onPressed: () {
                                    showDeleteConfirmationDialog(user['User_id']);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList()
                          : [],
                    ),
                  ),
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Pending Hospitals/Doctors',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
            ),

            Card(
              elevation: 4,
              child: Container(
                height: 250,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    headingRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.teal,
                    ),
                    dataRowHeight: 100, // Increased row height.
                    columns: [
                      DataColumn(
                        label: Container(
                          width: 70, // Set a smaller width for the column
                          child: Text(
                            'Email & Type',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          width: 70, // Set a smaller width for the column
                          child: Text(
                            'CV',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          width: 70, // Set a smaller width for the column
                          child: Text(
                            'Actions',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                    rows: hospitals.isNotEmpty
                        ? hospitals.map((caregiver) {
                      String filePath = caregiver['File'];
                      String fileName = filePath.replaceFirst('Uploade/', ''); // Remove 'Upload/' prefix
                      String emailWithType = '${caregiver['Email']} / ${caregiver['Type_oftheuser']}'; // Email and Type
                      return DataRow(cells: [
                        DataCell(
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: 80, // Set the maximum width
                            ),
                            child: Text.rich(
                              TextSpan(
                                text: '${caregiver['Email']} / ', // Regular email part
                                style: TextStyle(fontWeight: FontWeight.normal), // Normal style for email
                                children: [
                                  TextSpan(
                                    text: '${caregiver['Type_oftheuser']}', // Bold type part
                                    style: TextStyle(fontWeight: FontWeight.bold), // Bold style for type
                                  ),
                                ],
                              ),
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        DataCell(
                          GestureDetector(
                            onTap: () async {
                              // Download and open PDF
                              String pdfPath = await downloadPdf(filePath);

                              if(!kIsWeb)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PdfViewerPage(pdfPath: pdfPath),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.red,
                                    size: 20, // Smaller icon size
                                  ),
                                  SizedBox(width: 4), // Reduced space between icon and text
                                  Container(
                                    constraints: BoxConstraints(maxWidth: 60),
                                    child: Text(
                                      fileName, // Display the file name without the 'Upload/' prefix
                                      style: TextStyle(color: Colors.black, fontSize: 10),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          FittedBox(
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check, color: Colors.green),
                                  onPressed: () {
                                    moveHospitalsToUser(caregiver['Request_id'].toString());
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    deletehospitalfrompending(caregiver['Request_id'].toString());
                                    fetchHospitalsData();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]);
                    }).toList()
                        : [
                      DataRow(cells: [
                        DataCell(Text('', style: TextStyle(fontSize: 12))),
                        DataCell(Text('')),
                        DataCell(Text('')),
                      ])
                    ],
                  ),
                ),
              ),
            )

          ],
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
              color: Colors.blue.withOpacity(0.7),
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
                child: Image.network(
                  assetPath, // Dynamic image source
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



class PdfViewerPage extends StatelessWidget {
  final String pdfPath;

  PdfViewerPage({required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal, // Keep consistent theme
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),

      ),
      body: Center(
        child: PDFView(
          filePath: pdfPath, // Pass the local path to the PDF file
        ),
      ),
    );
  }
}


class CardPage extends StatelessWidget {
  final dynamic article;

  CardPage(this.article);

  // Function to delete the article (This will need to call an API)
  Future<void> deleteArticleFromApi(String articleId) async {
    // Determine the base URL based on platform (web or mobile)
    final baseUrl = kIsWeb
        ? 'http://localhost:3001' // Web environment (localhost)
        : 'http://10.0.2.2:3001'; // Mobile emulator

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/articles/$articleId'),
      );

      if (response.statusCode == 200) {
        print('Article deleted successfully');
        mayarticaldeleted = true;
      } else {
        print('Failed to delete article');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> deleteArticle(BuildContext context) async {
    // Display confirmation dialog before deleting
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this article?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);  // Close dialog and return false
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);  // Close dialog and return true
              },
            ),
          ],
        );
      },
    );

    // If confirmed, proceed to delete (here you would call your API)
    if (confirmDelete == true) {
      // Ensure the id is a string
      String articleId = article['id'].toString();  // Convert to string

      // Call the API to delete the article
      await deleteArticleFromApi(articleId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Article deleted successfully'),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    String relativeImagePath = article['image_path'];

// Construct the full image URL using the relative image path
    String photoUrl = '';
    if (relativeImagePath.isNotEmpty) {
      // Determine the base URL based on platform (web or mobile)
      final baseUrl = kIsWeb
          ? 'http://localhost:3001' // Web environment (localhost)
          : 'http://10.0.2.2:3001'; // Mobile emulator

      // Construct the full URL for the image
      photoUrl = '$baseUrl/' + relativeImagePath.replaceAll('\\', '/');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(article['title'],style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
        actions: [
          // Enhanced delete button with tooltip
          Tooltip(
            message: 'Delete Article',
            child: IconButton(
              icon: Icon(
                Icons.delete_forever, // A more visually striking delete icon
                color: Colors.redAccent,
                size: 45, // Slightly larger size for better visibility
              ),
              onPressed: () => deleteArticle(context),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the image dynamically using the constructed photo URL
            Center(
              child: Image.network(
                photoUrl.isNotEmpty ? photoUrl : 'http://example.com/default-image.jpg', // Use constructed URL or fallback image
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            // Title for the article
            Text(
              article['title'],
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),

            // Article content dynamically
            Text(
              article['content'],  // Dynamic content
            ),
          ],
        ),
      ),
    );
  }
}