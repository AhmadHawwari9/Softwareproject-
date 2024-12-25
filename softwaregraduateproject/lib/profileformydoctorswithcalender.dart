import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'chatwithspecificperson.dart';

class UserDetailsPagewithcalender extends StatefulWidget {
  final String id;
  final String savedToken;

  const UserDetailsPagewithcalender({Key? key, required this.id, required this.savedToken}) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPagewithcalender> {
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
    fetchSchedule();
    fetchAvailability();
    checkUnfollowRequest();
    fetchMedications();
    checkNotifications(); // Check if this user has been followed/requested
  }

  List<Map<String, String>> medications = [];

  Future<void> fetchMedications() async {
    final url = Uri.parse('http://10.0.2.2:3001/getMedications/${widget.id}');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${widget.savedToken}', // Add your token here
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Process the data to match the required format
        setState(() {
          medications = data.map((med) {
            return {
              'medicine_name': med['medicine_name']?.toString() ?? '', // Ensure it's a string
              'dosage': med['dosage']?.toString() ?? '', // Ensure it's a string
              'timings': med['timesPerDay']?.toString() ?? '', // Ensure it's a string
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load medications');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
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
  List<dynamic> scheduleData = [];

  List<String> _getEventsForDay(DateTime day) {
    // Normalize the input day to local midnight
    final localDay = DateTime(day.year, day.month, day.day);

    return scheduleData.where((schedule) {
      DateTime scheduleDate;
      try {
        // Parse the 'Date' string as a local date
        scheduleDate = DateTime.parse(schedule['Date']);

        // Add one day to adjust for the time zone shift
        scheduleDate = scheduleDate.add(const Duration(days: 1));

        // Normalize to local midnight
        scheduleDate = DateTime(scheduleDate.year, scheduleDate.month, scheduleDate.day);
      } catch (e) {
        print('Error parsing date: ${schedule['Date']}');
        return false; // Skip invalid dates
      }

      // Compare only the date part
      return scheduleDate == localDay;
    }).map<String>((schedule) {
      return schedule['Name']?.toString() ?? 'No Name';
    }).toList();
  }

  List<Map<String, dynamic>> selectedSchedules = [];

  Future<void> _fetchScheduleForSelectedDate(String userId, DateTime selectedDay) async {
    try {
      // Format the selected date
      final formattedDate = "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";

      // Fetch the schedule data based on the selected date and userId
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3001/getScheduleByDateForUser/$userId/$formattedDate'), // Adjusted endpoint
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
    _fetchScheduleForSelectedDate(widget.id,selectedDate); // Refresh schedules for the current selected date
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
                _editSchedule(int.parse(widget.id), scheduleId, name, formattedSelectedDate, time);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }




  void _editSchedule(
      int userId,
      int scheduleId,
      String name,
      String date,
      String time,
      ) {
    // Format the selected date
    final selectedDateFormatted =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    print('Editing Schedule: $scheduleId');
    print('User ID: $userId');
    print('Updated Name: $name');
    print('Updated Date: $date');
    print('Updated Time: $time');
    print('Selected Calendar Date: $selectedDateFormatted'); // Include the selected date

    // API call to update the schedule on the server
    final url = Uri.parse(
        'http://10.0.2.2:3001/modifySchedule/$userId/$scheduleId'); // Adjusted endpoint

    Map<String, dynamic> data = {
      'name': name,
      'date': selectedDateFormatted, // Send the selected calendar date
      'time': time,
    };

    http
        .put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.savedToken}',
      },
      body: json.encode(data),
    )
        .then((response) {
      if (response.statusCode == 200) {
        print('Schedule updated successfully!');

        // Update local data list
        setState(() {
          int index = scheduleData.indexWhere(
                  (schedule) => schedule['scedual_id'] == scheduleId);
          if (index != -1) {
            scheduleData[index] = {
              'scedual_id': scheduleId,
              'Name': name,
              'Date': selectedDateFormatted,
              'Time': time,
            };
          }
        });

        // Refresh schedule for the selected date
        _fetchScheduleForSelectedDate(widget.id, selectedDate);
      } else {
        print('Failed to update schedule. Response code: ${response.statusCode}');
      }
    }).catchError((e) {
      print('Error: $e');
    });
  }






  Future<bool> _deleteSchedule(int userId, int scheduleId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3001/removeSchedule/$userId/$scheduleId'),
        headers: {
          'Authorization': 'Bearer ${widget.savedToken}', // Replace with actual token
        },
      );

      if (response.statusCode == 200) {
        print('Schedule removed successfully!');
        return true;
      } else {
        print('Failed to remove schedule. Status Code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error removing schedule: $e');
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
                      Uri.parse('http://10.0.2.2:3001/schedulefromthecarerecipant/${widget.id}'), // For Android emulator
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
                      _fetchScheduleForSelectedDate(widget.id,selectedDate!);
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

  Future<void> fetchSchedule() async {
    final url = Uri.parse('http://10.0.2.2:3001/caregiverSchedule/${widget.id}'); // API URL with userId as a parameter
    try {
      final response = await http.get(url); // Removed Authorization header

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
  String availabilityText = "";
  Future<void> fetchAvailability() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3001/availability/${widget.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.savedToken}',  // Pass the token in the header
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        // Construct a string with the availability information
        setState(() {
          availabilityText = "Available on: ${data[0]['days']}\n"
              "From: ${data[0]['start_time']} to ${data[0]['end_time']}";
        });
      } else {
        setState(() {
          availabilityText = "No availability set.";
        });
      }
    } else {
      setState(() {
        availabilityText = "No availability Added";
      });
    }
  }

  Widget buildAvailabilityDisplay() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.teal[50],
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: availabilityText.isEmpty
            ? Center(
          child: Text(
            "Loading availability...",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
        )
            : availabilityText == "No availability set."
            ? Center(
          child: Text(
            "No availability set yet.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Availability for this Doctor:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            SizedBox(height: 10),
            Text(
              availabilityText,
              style: TextStyle(fontSize: 16, color: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }

  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',style: TextStyle(color: Colors.white),),
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
        height: double.infinity,
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
                      color: Colors.teal,
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
                          ? Colors.teal
                          : isRequested
                          ? Colors.teal
                          : isFollowing
                          ? Colors.teal
                          : Colors.teal,
                      onPressed: _toggleFollowRequest,
                    ),



                  ],
                ),

                SizedBox(height: 16),
                _buildInfoCard(
                  context,
                  title: 'User Type',
                  content: userData['Type_oftheuser'] ?? 'Not available',
                  icon: Icons.group,
                ),


                buildAvailabilityDisplay(),


                SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Vertical scroll for the entire body
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
                              final events = _getEventsForDay(day);
                              print('Events for $day (UTC): $events');
                              print('Events for ${day.toLocal()} (Local): $events');
                              return events;
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
                                _fetchScheduleForSelectedDate(widget.id, selectedDay); // Fetch data for selected date
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: _showAddScheduleDialog,
                            child: Text('Book an appointment'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
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
                                ],
                                rows: selectedSchedules.map<DataRow>((schedule) {
                                  return DataRow(cells: [
                                    DataCell(Text(schedule['Name'] ?? 'No name')),
                                    DataCell(Text(schedule['Time'] ?? 'No time')),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),


                        const Text(
                          "Prescribed Medications:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                        const SizedBox(height: 10),
                        DataTable(
                          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.teal[100]!),
                          dataRowColor: MaterialStateColor.resolveWith((states) => Colors.teal[50]!),
                          headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                          dataTextStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.teal,
                          ),
                          columns: const [
                            DataColumn(label: Text("Medicine")),
                            DataColumn(label: Text("Dosage")),
                            DataColumn(label: Text("Timing")),
                          ],
                          rows: medications.map<DataRow>((med) {
                            return DataRow(cells: [
                              DataCell(Text(med['medicine_name'] ?? '')),
                              DataCell(Text(med['dosage'] ?? '')),
                              DataCell(Text(med['timings'] ?? '')),
                            ]);
                          }).toList(),
                        ),


                        const SizedBox(height: 30),


                      ],
                    ),
                  ),
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
