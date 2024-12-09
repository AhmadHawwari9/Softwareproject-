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
import 'Login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'Myfiles.dart';
import 'PdfReader.dart';
import 'Reportsshowtocaregiver.dart';
import 'Searchpage.dart';
import 'Settingspage.dart';
import 'UserProfilePage.dart';



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
    final response = await http.get(Uri.parse('http://10.0.2.2:3001/articles'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);  // Decode the response body

      setState(() {
        articleCount = data['count'];  // Set the count
        // Cast the 'articles' key to a List<Map<String, dynamic>>
        articles = List<Map<String, dynamic>>.from(data['articles']);
      });
    } else {
      throw Exception('Failed to load articles');
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
    final url = Uri.parse('http://10.0.2.2:3001/ScheduleforCaregiver'); // Replace with your API URL
    try {

      final response = await http.get(
        url,
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


  Future<void> fetchUsers() async {
    if (widget.savedToken == null || widget.savedToken.isEmpty) {
      print('No token available');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3001/usersoperationsforadmin'),
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
        } else {
          homepage = CareGiverHomepage(email, password, token, isGoogleSignInEnabled);
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


  Future<void> fetchMedicalReports(String careRecipientId) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3001/user/files/$careRecipientId'),
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
    const String url = 'http://10.0.2.2:3001/getCareRecipients'; // Adjust URL if needed

    try {
      final response = await http.get(
        Uri.parse(url),
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
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3001/deleteUser/$userId'),
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
  List<Map<String, dynamic>> caregivers = [];

  Future<void> fetchCaregiversData() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3001/caregiverRequestToTheAdminDisplay'));

    if (response.statusCode == 200) {
      // Parse the response JSON
      List<dynamic> data = json.decode(response.body);
      setState(() {
        // Map the data into a format suitable for the DataTable
        caregivers = data.map((item) {
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
      // Handle error if necessary
      throw Exception('Failed to load caregivers');
    }
  }

  Future<void> moveCaregiverToUser(String requestId) async {
    final url = 'http://10.0.2.2:3001/movecaregivertouserstable/$requestId'; // Replace with actual URL

    try {
      final response = await http.delete(Uri.parse(url));

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
    final url = 'http://10.0.2.2:3001/deletecaregiver/$requestId'; // Replace with actual URL

    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        fetchCaregiversData();
      } else {
        print('Failed to delete the caregiver from pending ');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }


  Future<String> downloadPdf(String pdfPath) async {
    try {
      if (pdfPath.isEmpty) throw Exception('Invalid file path');
      final permissionStatus = await Permission.storage.request();

      if (permissionStatus.isGranted) {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:3001/$pdfPath'),
        );

        if (response.statusCode == 200) {
          // Get the path for the Downloads folder
          final downloadsDirectory =
          Directory('/storage/emulated/0/Download'); // Path to Downloads

          if (!await downloadsDirectory.exists()) {
            await downloadsDirectory.create(recursive: true); // Create the folder
          }

          // Create the file path
          final file = File(
              '${downloadsDirectory.path}/${pdfPath.split('/').last}');
          await file.writeAsBytes(response.bodyBytes); // Save the file

          return file.path; // Return the local path of the file
        } else {
          throw Exception('Failed to download PDF');
        }
      } else {
        throw Exception('Storage permission denied');
      }
    } catch (e) {
      print('Error downloading PDF: $e');
      throw e;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Colors.indigoAccent,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                // Open the Drawer when the menu icon is pressed
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),

        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: Colors.white, // White color for the icon
              size: 30.0, // Increase the size of the icon
            ),
            onPressed: () {
              // Handle notification button press
              print('Notifications pressed');
            },
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
                padding: EdgeInsets.only(bottom: 35), // Adjust padding as needed
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
                        color: Colors.blue,
                      ) // Fallback icon if no image URL
                          : null,
                    ),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue, // Set the background color of the header to blue
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
              leading: Icon(Icons.local_hospital),
              title: Text('My Doctor'),
              onTap: () {},
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

                    // If the 'image_path' is not empty, construct the photo URL
                    String photoUrl = '';
                    if (relativeImagePath.isNotEmpty) {
                      photoUrl = 'http://10.0.2.2:3001/' + relativeImagePath.replaceAll('\\', '/');
                    }

                    if(mayarticaldeleted){
                      fetchArticles();
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blueAccent),
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
                      rows: users.isNotEmpty
                          ? users.map<DataRow>((user) {
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
                'Pending Doctors',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                          (states) => Colors.blueAccent,
                    ),
                    dataRowHeight: 100,  // Increased row height
                    columns: [
                      DataColumn(
                        label: Container(
                          width: 70,  // Set a smaller width for the column
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
                          width: 70,  // Set a smaller width for the column
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
                          width: 70,  // Set a smaller width for the column
                          child: Text(
                            'Actions',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                    rows: caregivers.map((caregiver) {
                      String filePath = caregiver['File'];
                      String fileName = filePath.replaceFirst('Uploade/', ''); // Remove 'Upload/' prefix
                      return DataRow(cells: [
                        DataCell(
                          Container(
                            constraints: BoxConstraints(maxWidth: 120), // Add constraints to control width
                            child: Text(
                              caregiver['Email'],
                              style: TextStyle(fontSize: 10),
                              overflow: TextOverflow.ellipsis, // Truncate text if needed
                              softWrap: true,  // Allow text to wrap
                            ),
                          ),
                        ),
                        DataCell(
                          GestureDetector(
                            onTap: () async {
                              // Download and open PDF
                              String pdfPath = await downloadPdf(filePath);
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
                              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),  // Reduced padding for smaller button
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.red,
                                    size: 20,  // Smaller icon size
                                  ),
                                  SizedBox(width: 4),  // Reduced space between icon and text
                                  // Allow the text (PDF name) to wrap inside the button
                                  Container(
                                    constraints: BoxConstraints(maxWidth: 60),  // Set a smaller max width for the container
                                    child: Text(
                                      fileName,  // Display the file name without the 'Upload/' prefix
                                      style: TextStyle(color: Colors.black, fontSize: 10),  // Reduced font size for smaller text
                                      softWrap: true,  // Allow text to wrap to a new line
                                      overflow: TextOverflow.visible, // Allow text to go to new line
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  // Call the API to move caregiver to users table
                                  moveCaregiverToUser(caregiver['Request_id'].toString());
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  deletecaregiverfrompending(caregiver['Request_id'].toString());
                                },
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.blue),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Colors.blue),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.blue),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu, color: Colors.blue),
            label: 'Browse',
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
        title: Text('PDF Viewer'),
        backgroundColor: Colors.blueAccent, // Keep consistent theme

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
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:3001/articles/$articleId'),
    );

    if (response.statusCode == 200) {
      print('Article deleted successfully');
      mayarticaldeleted=true;

    } else {
      print('Failed to delete article');
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
    // Extract the relative image path from the article data
    String relativeImagePath = article['image_path'];

    // Construct the full image URL using the relative image path
    String photoUrl = '';
    if (relativeImagePath.isNotEmpty) {
      photoUrl = 'http://10.0.2.2:3001/' + relativeImagePath.replaceAll('\\', '/');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(article['title']),
        backgroundColor: Colors.indigoAccent,
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