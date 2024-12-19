import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
import 'Noti.dart';
import 'Notificationpage.dart';
import 'PdfReader.dart';
import 'Reportsshowtocaregiver.dart';
import 'Searchcaregievrpage.dart';
import 'Searchpage.dart';
import 'Settingspage.dart';
import 'UserProfilePage.dart';

import 'package:table_calendar/table_calendar.dart';


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
   Timer? timer;
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
    fetchArticles();
    fetchCareRecipients();
    fetchSchedule();
    fetchCareRecipients().then((_) {
      setState(() {
        // Populate the filtered list with all recipients by default
        filteredRecipients = List.from(careRecipients);
      });
    }).catchError((error) {
      print('Error fetching care recipients: $error');
    });
    fetchUnreadMessagesCount();
    fetchNotificationCount();
    getAccessToken();
    getToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("new message");
        print(message.notification!.title);
        print(message.notification!.body);
      }
    });

    startScrolling();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    timer?.cancel();
    super.dispose();
  }

  int articleCount = 0;  // To store the count of articles
  List<Map<String, dynamic>> articles = [];  // To store the list of articles

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
    final url = Uri.parse('http://10.0.2.2:3001/ScheduleforCaregiver'); // Your API URL to get all schedule data
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.savedToken}', // Authorization token
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          scheduleData = List<Map<String, dynamic>>.from(jsonDecode(response.body)); // Explicitly cast to List<Map<String, dynamic>>
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


  _showEditDialog(
      BuildContext context,
      int scheduleId,
      String name,
      String date,
      String time,
      ) {
    final formattedSelectedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Schedule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
              ),
              TextFormField(
                initialValue: time,
                decoration: InputDecoration(labelText: 'Time'),
                onChanged: (value) => time = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _editSchedule(scheduleId, name, formattedSelectedDate, time);
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
    final selectedDateFormatted = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    print('Editing Schedule: $scheduleId');
    print('Updated Name: $name');
    print('Updated Date: $date');
    print('Updated Time: $time');
    print('Selected Calendar Date: $selectedDateFormatted'); // Include the selected date

    // API call to update the schedule on the server
    final url = Uri.parse('http://10.0.2.2:3001/updateSchedule/$scheduleId');

    Map<String, dynamic> data = {
      'name': name,
      'date': selectedDateFormatted, // Send the selected calendar date
      'time': time,
    };

    http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.savedToken}',
      },
      body: json.encode(data),
    ).then((response) {
      if (response.statusCode == 200) {
        print('Schedule updated successfully!');

        // Update local data list
        setState(() {
          int index = scheduleData.indexWhere((schedule) => schedule['scedual_id'] == scheduleId);
          if (index != -1) {
            scheduleData[index] = {
              'scedual_id': scheduleId,
              'Name': name,
              'Date': selectedDateFormatted,
              'Time': time,
            };
          }
        });

        _fetchScheduleForSelectedDate(selectedDate);
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
    final TextEditingController timeController = TextEditingController();
    DateTime? selectedDate; // To store the selected date

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New Schedule'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Care recipient Name'),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDate != null
                                ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
                                : 'No date selected',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                          child: Text('Select Date'),
                        ),
                      ],
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
                    String time = timeController.text.trim();

                    if (name.isEmpty || selectedDate == null || time.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('All fields are required!')),
                      );
                      return;
                    }

                    // Format the selected date
                    String formattedDate =
                        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

                    // Create new schedule data with the correct keys for backend
                    Map<String, dynamic> newSchedule = {
                      'name': name,
                      'date': formattedDate,
                      'time': time,
                    };

                    // Make the POST request to your API
                    final response = await http.post(
                      Uri.parse('http://10.0.2.2:3001/addSchedule'), // For Android emulator
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer ${widget.savedToken}',
                      },
                      body: jsonEncode(newSchedule),
                    );

                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('New Schedule Added')),
                      );
                      Navigator.of(context).pop(); // Close the dialog
                      _fetchScheduleForSelectedDate(selectedDate!);
                    } else {
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
      },
    );
  }


  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> selectedSchedules = [];

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




  Future<void> _fetchScheduleForSelectedDate(DateTime selectedDay) async {
    try {
      // Format the selected date
      final formattedDate = "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";

      // Fetch the schedule data based on the selected date
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3001/ScheduleForCaregiverByDate/$formattedDate'), // Adjust the endpoint
        headers: {
          'Authorization': 'Bearer ${widget.savedToken}', // Include token if required
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print("Fetched Schedules: $data"); // Debugging output

        setState(() {
          selectedSchedules = List<Map<String, dynamic>>.from(data); // Update the list of schedules for the selected date
        });
      } else {
        print("Failed to fetch schedules. Status Code: ${response.statusCode}");
        setState(() {
          selectedSchedules = []; // Clear schedules if request fails
        });
      }
    } catch (e) {
      print("Error fetching schedules: $e");
      setState(() {
        selectedSchedules = []; // Clear schedules on error
      });
    }
  }

// Call this method after editing a schedule
  void refreshSchedulesForSelectedDate() {
    _fetchScheduleForSelectedDate(selectedDate); // Refresh schedules for the current selected date
  }




  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final formattedDay = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

    // Normalize the schedule Date format to YYYY-MM-DD
    return List<Map<String, dynamic>>.from(scheduleData.where((schedule) {
      // Convert the Date field from DD/MM/YYYY to YYYY-MM-DD for comparison
      var scheduleDate = schedule['Date']; // Assuming 'Date' is in the format 'DD/MM/YYYY'
      var parts = scheduleDate.split('/');
      if (parts.length == 3) {
        // Reformat date to YYYY-MM-DD
        scheduleDate = '${parts[2]}-${parts[1]}-${parts[0]}';
      }

      return scheduleDate == formattedDay; // Compare the reformatted Date with formattedDay
    }).toList());
  }

  Future<List> fetchNotifications() async {
    final url = 'http://10.0.2.2:3001/notifications';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.savedToken} ',  // Add token to the request headers
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['notifications'];
    } else {
      throw Exception('Failed to load notifications');
    }
  }



  Future<void> sendUnfollowRequest(String token, String recipientId) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3001/unfollow'), // Replace with your actual API URL
        headers: {
          'Authorization': 'Bearer $token', // Add the token to the request header
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'reciver_id': recipientId, // Send the recipient's ID as part of the request body
        }),
      );

      if (response.statusCode == 200) {
        // Handle success
        print('Unfollow request successful');
      } else {
        // Handle failure
        print('Failed to unfollow: ${response.body}');
      }
    } catch (e) {
      print('Error sending unfollow request: $e');
    }
  }


  Future<void> deleteUnfollowRequest(String token, String recipientId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3001/DeleteUnfollowRequest/$recipientId'), // Replace with your actual API URL
        headers: {
          'Authorization': 'Bearer $token', // Add the token to the request header
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Handle success
        print('Unfollow request deleted');
      } else {
        // Handle failure
        print('Failed to delete unfollow request: ${response.body}');
      }
    } catch (e) {
      print('Error deleting unfollow request: $e');
    }
  }

  int notificationCount = 0;

  Future<void> fetchNotificationCount() async {
    final url = 'http://10.0.2.2:3001/notification-count';
    final headers = {
      'Authorization': 'Bearer ${widget.savedToken}',
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
  List<Map<String, dynamic>> filteredRecipients = [];


  void filterRecipients(String query) {
    setState(() {
      filteredRecipients = careRecipients.where((recipient) {
        final email = recipient['Email'].toLowerCase();
        return email.contains(query.toLowerCase());
      }).toList();
    });
  }


  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredUsers = [];

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
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
            Padding(
              padding: const EdgeInsets.all(5),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(articles.length, (index) {
                    var article = articles[index];

                    // Using 'image_path' directly from the response
                    String relativeImagePath = article['image_path'];

                    // If the 'image_path' is not null or empty, construct the photo URL
                    String photoUrl = '';
                    if (relativeImagePath.isNotEmpty) {
                      photoUrl = 'http://10.0.2.2:3001/' + relativeImagePath.replaceAll('\\', '/');
                    }

                    // Return the card with the photo URL
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




            SizedBox(height: 22),
            // Title Text above the table
            Text(
              'Task Schedule for Caregiver',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.vertical,  // Vertical scroll for the entire body
              child: Card(
                elevation: 4,
                child: Column(
                  children: [

                    // Calendar section
                    Container(
                      height: 400, // Fixed height for the calendar
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: DateTime.now(),
                        calendarFormat: CalendarFormat.month,
                        eventLoader: (day) {
                          return _getEventsForDay(day); // Return events for that day
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.teal,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.teal,
                            shape: BoxShape.circle,
                          ),
                          outsideDaysVisible: false,
                          markersMaxCount: 1, // Show only one marker per day
                          markerDecoration: BoxDecoration(
                            color: Colors.red, // Dot color for days with events
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        onDaySelected: (selectedDay, focusedDay) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              selectedDate = selectedDay;
                            });
                            _fetchScheduleForSelectedDate(selectedDay); // Fetch data for selected date
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _showAddScheduleDialog,
                        child: Text('Add New Schedule'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Schedules for ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    // Schedules DataTable section
                    Container(
                      height: 200, // Fixed height for displaying the schedule list (3 rows max)
                      child: selectedSchedules.isEmpty
                          ? Center(child: Text('No schedules for this date.'))
                          : SingleChildScrollView( // Added scroll for the DataTable rows
                        child: DataTableTheme(
                          data: DataTableThemeData(
                            headingRowColor: MaterialStateProperty.all(Colors.teal),
                            headingTextStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            dataRowColor: MaterialStateProperty.all(Colors.teal.shade50),
                            dataTextStyle: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                          child: DataTable(
                            headingRowHeight: 40,
                            columns: [
                              // Removed the Schedule ID and Date columns
                              DataColumn(
                                label: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 120), // Restrict column width
                                  child: Text('Name', style: TextStyle(fontSize: 10)),
                                ),
                                tooltip: 'Schedule Name',
                              ),
                              DataColumn(
                                label: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 100), // Restrict column width
                                  child: Text('Time', style: TextStyle(fontSize: 10)),
                                ),
                                tooltip: 'Schedule Time',
                              ),
                              DataColumn(
                                label: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 120), // Restrict column width
                                  child: Text('Actions', style: TextStyle(fontSize: 10)),
                                ),
                                tooltip: 'Actions (Edit/Delete)',
                              ),
                            ],
                            rows: selectedSchedules.map<DataRow>((schedule) {
                              return DataRow(cells: [
                                // Removed Schedule ID and Date columns from rows
                                DataCell(Text(schedule['Name'] ?? 'No name')),
                                DataCell(Text(schedule['Time'] ?? 'No time')),
                                DataCell(
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          String rawDate = schedule['Date'] ?? '';
                                          DateTime parsedDate = DateTime.parse(rawDate);
                                          String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);

                                          _showEditDialog(
                                            context,
                                            schedule['scedual_id'],
                                            schedule['Name'] ?? 'No name',
                                            formattedDate,
                                            schedule['Time'] ?? 'No time',
                                          );
                                        },
                                        child: Text('Edit'),
                                        style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 8)),
                                      ),


                              SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () async {
                                          bool success = await _deleteSchedule(schedule['scedual_id']);
                                          if (success) {
                                            setState(() {
                                              selectedSchedules.removeWhere((item) =>
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
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(horizontal: 8),
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


            SizedBox(height:25),

            // Title Text above the table
            Text(
              'My Care Recipients',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 16), // Space between title and table

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: searchController,
                onChanged: filterRecipients, // Use the filter function
                style: TextStyle(color: Colors.teal, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Search Care Recipients',
                  labelStyle: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.teal, width: 2),
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),

            SingleChildScrollView(
              child: Card(
                elevation: 8, // Enhanced shadow effect for better depth
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Softer rounded corners for the card
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Ensure the column size is constrained to its content
                  children: [
                    Container(
                      height: 300, // Height for the scrollable container
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade100, Colors.teal.shade300], // Gradient background
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.teal.shade700, width: 2), // Border with darker teal
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: filteredRecipients.isEmpty
                              ? [
                            Padding(
                              padding: const EdgeInsets.all(20.0), // Add padding for the "No data" message
                              child: Text(
                                'No care recipients available',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ]
                              : filteredRecipients.map<Widget>((recipient) {
                            return GestureDetector(
                              onTap: () {
                                // Navigate to the details page when card is clicked
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipientDetailsPage(
                                      recipientId: recipient['carerecipient_id'].toString(),
                                      recipientEmail: recipient['Email'],
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                elevation: 4, // Slight elevation for individual tiles
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10), // Rounded corners for each tile
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      'http://10.0.2.2:3001/${recipient['image_path']}',
                                    ),
                                    radius: 30, // Circular design
                                  ),
                                  title: Text(
                                    recipient['Email'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade800,
                                    ),
                                  ),
                                  subtitle: Text(
                                    recipient['Type_oftheuser'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios, // Add an arrow for better UX
                                    color: Colors.teal.shade700,
                                    size: 16,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
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
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu, color: Colors.teal),
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



class CardPage extends StatelessWidget {
  final dynamic article;

  CardPage(this.article);

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
        title: Text(article['title'],style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
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



class RecipientDetailsPage extends StatefulWidget {
  final String recipientId;
  final String recipientEmail; // Added email as a parameter

  // Constructor to accept recipientId and recipientEmail
  RecipientDetailsPage({required this.recipientId, required this.recipientEmail});

  @override
  _RecipientDetailsPageState createState() => _RecipientDetailsPageState();
}

class _RecipientDetailsPageState extends State<RecipientDetailsPage> {
  // Function to fetch medical reports
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientEmail,style: TextStyle(color: Colors.white),), // Display the recipient's email in the AppBar
        backgroundColor: Colors.teal,
        elevation: 4.0,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
      ),
      body: Container(
        color: Colors.grey[100], // Background color for the whole screen
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medical Report Button with enhanced design
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                minimumSize: Size(double.infinity, 50),
                shadowColor: Colors.black.withOpacity(0.3),
                elevation: 5,
              ),
              onPressed: () {
                // Fetch and display the medical report for this recipient
                fetchMedicalReports(widget.recipientId);
              },
              child: Text(
                "View Medical Report",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            // History Page Button with similar styling, but teal background
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal, // Set the background color to teal
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                minimumSize: Size(double.infinity, 50),
                shadowColor: Colors.black.withOpacity(0.3),
                elevation: 5,
              ),
              onPressed: () {
                // Navigate to the history page for this recipient
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(recipientId: widget.recipientId),
                  ),
                );
              },
              child: Text(
                "View History",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


