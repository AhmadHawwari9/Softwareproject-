import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'AdminHomepage.dart';
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
import 'Card1.dart';
import 'card2.dart';
import 'card3.dart';

class CareGiverHomepage extends StatefulWidget {
  final String savedEmail;
  final String savedPassword;
  final String savedToken;
  final bool isGoogleSignInEnabled;

  CareGiverHomepage(this.savedEmail, this.savedPassword, this.savedToken, this.isGoogleSignInEnabled);

  @override
  State<CareGiverHomepage> createState() => _HomepageState();
}

class _HomepageState extends State<CareGiverHomepage> {
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
  late Timer timer;
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
    fetchCareRecipients();
    fetchSchedule();
    getAccessToken();
    getToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("new message");
        print(message.notification!.title);
        print(message.notification!.body);
      }
    });

    // Start the timer for card carousel
    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        if (movingForward) {
          currentCardIndex = (currentCardIndex + 1) % 3;
        } else {
          currentCardIndex = (currentCardIndex - 1 + 3) % 3;
        }
      });

      _scrollController.animateTo(
        currentCardIndex * 280.0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      if (currentCardIndex == 2) movingForward = false;
      else if (currentCardIndex == 0) movingForward = true;
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _scrollController.dispose();
    super.dispose();
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


  Future<void> showHistory(int recipientId) async {
    final url = Uri.parse('http://your-server.com/fetch_history.php'); // Replace with your API URL

    try {
      final response = await http.post(url, body: {'id': recipientId.toString()});

      if (response.statusCode == 200) {
        final history = jsonDecode(response.body);

        // Show history in a dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('History for ID: $recipientId'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Visit Date: ${history['visit_date']}'),
                    Text('Symptoms: ${history['symptoms']}'),
                    Text('Treatment: ${history['treatment']}'),
                    Text('Outcome: ${history['outcome']}'),
                    // Add more fields as needed
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      print('Error: $e');
      showErrorDialog('Failed to fetch history');
    }
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



  void _showEditDialog(
      BuildContext context,
      int scheduleId,
      String name,
      String date,
      String time,
      ) {
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController dateController = TextEditingController(text: date);
    TextEditingController timeController = TextEditingController(text: time);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Schedule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display Schedule ID as non-editable (using a Text widget)
              Text('Schedule ID: $scheduleId', style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: dateController,
                decoration: InputDecoration(labelText: 'Date'),
              ),
              TextField(
                controller: timeController,
                decoration: InputDecoration(labelText: 'Time'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Call the edit schedule function on save
                _editSchedule(
                  scheduleId,
                  nameController.text,
                  dateController.text,
                  timeController.text,
                );
                Navigator.of(context).pop(); // Close the dialog after saving
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }


  void _editSchedule(
      int scheduleId,
      String name,
      String date,
      String time,
      ) {
    print('Editing Schedule: $scheduleId');
    print('Updated Name: $name');
    print('Updated Date: $date');
    print('Updated Time: $time');

    // API call to update the schedule on the server
    final url = Uri.parse('http://10.0.2.2:3001/updateSchedule/$scheduleId'); // Adjust URL for your local server

    // Create the data payload
    Map<String, dynamic> data = {
      'name': name,
      'date': date,
      'time': time,
      // Do not include 'schedule_id' as it is already in the URL
    };

    http.put(
      url,
      headers: {
        'Content-Type': 'application/json', // Ensure the correct content type
        'Authorization': 'Bearer ${widget.savedToken}', // Authorization token if required
      },
      body: json.encode(data), // Send data as JSON
    ).then((response) {
      if (response.statusCode == 200) {
        print('Schedule updated successfully!');

        // After successful update, update the local data list
        setState(() {
          // Find the schedule by ID and update it in the local data
          int index = scheduleData.indexWhere((schedule) => schedule['scedual_id'] == scheduleId);
          if (index != -1) {
            scheduleData[index] = {
              'scedual_id': scheduleId,
              'Name': name,
              'Date': date,
              'Time': time,
            };
          }
        });

        // Optionally, fetch the latest data from the backend to refresh
        // fetchSchedule();
      } else {
        print('Failed to update schedule. Response code: ${response.statusCode}');
      }
    }).catchError((e) {
      print('Error: $e');
    });
  }



  Future<bool> _deleteSchedule(int scedualId) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:3001/deleteSchedule/$scedualId'),
      headers: {
        'Authorization': 'Bearer ${widget.savedToken}', // Replace with actual token
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }


  void _showAddScheduleDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Schedule'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Care recipient Name'),
                ),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'Date '),
                ),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(labelText: 'Time'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Extract the values from the controllers
                String name = nameController.text.trim();
                String date = dateController.text.trim();
                String time = timeController.text.trim();

                // Debug: Print the values to make sure they are correctly captured
                print('Schedule Name: $name');
                print('Date: $date');
                print('Time: $time');

                if (name.isEmpty || date.isEmpty || time.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All fields are required!')),
                  );
                  return;
                }

                // Create new schedule data with the correct keys for backend
                Map<String, dynamic> newSchedule = {
                  'name': name, // Use lowercase keys for the backend
                  'date': date,
                  'time': time,
                };

                // Debug: Print the map before sending the request
                print('Sending the following schedule data: $newSchedule');

                // Make the POST request to your API
                final response = await http.post(
                  Uri.parse('http://10.0.2.2:3001/addSchedule'), // For Android emulator
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer ${widget.savedToken}', // Include token if necessary
                  },
                  body: jsonEncode(newSchedule),
                );


                // Debug: Check the response status code and body
                print('Response status: ${response.statusCode}');
                print('Response body: ${response.body}');

                if (response.statusCode == 200) {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('New Schedule Added')),
                  );

                  // Close the dialog without triggering a page refresh
                  Navigator.of(context).pop();// Close the dialog
                  fetchSchedule();
                }
                else {
                  // Show error message if the API request fails
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add schedule')),
                  );
                }
              },
              child: Text('Add'),
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
              title: Text("Settings"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage(widget.savedEmail,widget.savedPassword,widget.savedToken,widget.isGoogleSignInEnabled)),
                );              },
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Card Carousel
            Padding(
              padding: const EdgeInsets.all(5),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    buildCard(0, "Keep Your Heart Healthy", "imgs/istockphoto-1266230179-612x612.jpg", Card1Page()),
                    buildCard(1, "8 Tips for Healthy Eating", "imgs/healthy-food-restaurants-640b5d1e9e8fc.png", Card2Page()),
                    buildCard(2, "8 Brain Health Tips", "imgs/how-the-human-brain-decides-what-to-remember.jpg", Card3Page()),
                  ],
                ),
              ),
            ),
            SizedBox(height: 22),
            // Title Text above the table
            Text(
              'Task Schedule for Caregiver',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),


            SingleChildScrollView(
              scrollDirection: Axis.horizontal, // For horizontal scrolling
              child: Card(
                elevation: 4, // Card shadow effect
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _showAddScheduleDialog, // Trigger function to show dialog
                        child: Text('Add New Schedule'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Button color
                          foregroundColor: Colors.white, // Text color
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
                    ),
                    Container(
                      height: 200,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical, // Enable vertical scrolling for the table rows
                        child: DataTableTheme(
                          data: DataTableThemeData(
                            headingRowColor: MaterialStateProperty.all(Colors.blue), // Header background color
                            headingTextStyle: TextStyle(
                              color: Colors.white, // Header text color
                              fontWeight: FontWeight.bold,
                            ),
                            dataRowColor: MaterialStateProperty.all(Colors.lightBlue.shade50), // Row background color
                            dataTextStyle: TextStyle(
                              color: Colors.black87, // Row text color
                            ),
                          ),
                          child: DataTable(
                            headingRowHeight: 40, // Adjust header height
                            columns: [
                              DataColumn(label: Text('Schedule ID')),
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Time')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: isLoading
                                ? [] // Empty rows while loading
                                : scheduleData.isEmpty
                                ? [
                              DataRow(cells: [
                                DataCell(Text('No data available')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                              ])
                            ]
                                : scheduleData.map<DataRow>((schedule) {
                              return DataRow(cells: [
                                DataCell(Text(schedule['scedual_id']?.toString() ?? 'No ID')), // Safely display Schedule ID
                                DataCell(Text(schedule['Name'] ?? 'No name')), // Default if null
                                DataCell(Text(schedule['Date'] ?? 'No date')), // Default if null
                                DataCell(Text(schedule['Time'] ?? 'No time')), // Default if null
                                DataCell(
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          // Pass the context safely to avoid errors
                                          if (!mounted) return; // Check if widget is still mounted
                                          _showEditDialog(
                                            context,
                                            schedule['scedual_id'],
                                            schedule['Name'] ?? 'No name', // Use default value if null
                                            schedule['Date'] ?? 'No date', // Use default value if null
                                            schedule['Time'] ?? 'No time', // Use default value if null
                                          );
                                        },
                                        child: Text('Edit'),
                                      ),
                                      SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () async {
                                          bool success = await _deleteSchedule(schedule['scedual_id']);
                                          if (!mounted) return; // Ensure widget is still mounted
                                          if (success) {
                                            setState(() {
                                              scheduleData.removeWhere((item) =>
                                              item['scedual_id'] == schedule['scedual_id']);
                                            });
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Schedule deleted successfully')),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Failed to delete schedule')),
                                            );
                                          }
                                        },
                                        child: Text('Delete'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red, // Red button for delete action
                                          foregroundColor: Colors.white, // White text for delete button
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),







            SizedBox(height: 16),

            // Title Text above the table
            Text(
              'My Care Recipients',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16), // Space between title and table

            SingleChildScrollView(
              scrollDirection: Axis.horizontal, // For horizontal scrolling
              child: Card(
                elevation: 4, // Card shadow effect
                child: Column(
                  children: [
                    Container(
                      height: 186,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical, // Enable vertical scrolling for the table rows
                        child: DataTableTheme(
                          data: DataTableThemeData(
                            headingRowColor: MaterialStateProperty.all(Colors.blue), // Header background color
                            headingTextStyle: TextStyle(
                              color: Colors.white, // Header text color
                              fontWeight: FontWeight.bold,
                            ),
                            dataRowColor: MaterialStateProperty.all(Colors.lightBlue.shade50), // Row background color
                            dataTextStyle: TextStyle(
                              color: Colors.black87, // Row text color
                            ),
                          ),
                          child: DataTable(
                            headingRowHeight: 40, // Adjust header height
                            columns: [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Email')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows: careRecipients.isEmpty
                                ? [
                              DataRow(cells: [
                                DataCell(Text('No data available')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                              ])
                            ]
                                : careRecipients.map<DataRow>((recipient) {
                              return DataRow(cells: [
                                DataCell(Text(recipient['carerecipient_id'].toString())), // ID
                                DataCell(Text(recipient['Email'])), // Email
                                DataCell(Row(
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor: Colors.white, // Text color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5), // Rounded corners
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      ),
                                      onPressed: () {
                                        // Fetch medical reports when the button is pressed
                                        fetchMedicalReports(recipient['carerecipient_id'].toString());                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.picture_as_pdf, color: Colors.red), // Icon color
                                          SizedBox(width: 5),
                                          Text('Medical Reports', style: TextStyle(color: Colors.black)), // Text color
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 15), // Space between the two buttons
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.black, backgroundColor: Colors.white, // Text color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5), // Rounded corners
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => HistoryPage(recipientId: recipient['carerecipient_id'].toString()),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.access_time, color: Colors.black), // Icon color
                                          SizedBox(width: 5),
                                          Text('History', style: TextStyle(color: Colors.black)), // Text color
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),





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


