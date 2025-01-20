import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for kIsWeb

class Emergencybuttonsettings extends StatefulWidget {
  final String savedToken;
  Emergencybuttonsettings(this.savedToken);

  @override
  _CareGiversScreenState createState() => _CareGiversScreenState();
}

class _CareGiversScreenState extends State<Emergencybuttonsettings> {
  List<dynamic> careRecipients = [];
  Map<int, bool> selectedUsers = {}; // Map to track selected users
  bool isLoading = true;
  List<String> doctorsEmails = []; // List to store fetched doctors' emails

  @override
  void initState() {
    super.initState();
    fetchCareRecipients();
    fetchDoctorsEmails(); // Fetch doctors' emails when the screen loads
  }

  Future<void> fetchCareRecipients() async {
    final baseUrl = kIsWeb
        ? 'http://localhost:3001'
        : 'http://10.0.2.2:3001';

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/caregivers'),
        headers: {
          'Authorization': 'Bearer ${widget.savedToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          careRecipients = data['careRecipients'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load caregivers');
      }
    } catch (e) {
      print('Error fetching caregivers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to fetch doctors' emails from the API
  Future<void> fetchDoctorsEmails() async {
    final baseUrl = kIsWeb
        ? 'http://localhost:3001'
        : 'http://10.0.2.2:3001';

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getDoctorsEmails'),
        headers: {
          'Authorization': 'Bearer ${widget.savedToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          doctorsEmails = List<String>.from(data['doctors_emails'] ?? []);
        });
      } else {
        throw Exception('Failed to fetch doctors emails');
      }
    } catch (e) {
      print('Error fetching doctors emails: $e');
      setState(() {
        doctorsEmails = []; // Set to empty list in case of error
      });
    }
  }

  // Function to send selected doctors to the API
  Future<void> addPatientDoctors(List<int> selectedDoctorsIds) async {
    final baseUrl = kIsWeb
        ? 'http://localhost:3001'
        : 'http://10.0.2.2:3001';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addPatientDoctors'),
        headers: {
          'Authorization': 'Bearer ${widget.savedToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'doctors_ids': selectedDoctorsIds,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Doctors added successfully: ${data['message']}');
        // Fetch updated doctors' emails after adding doctors
        await fetchDoctorsEmails();
      } else {
        throw Exception('Failed to add doctors');
      }
    } catch (e) {
      print('Error adding doctors: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Emergency button settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        elevation: 10, // Add shadow to the app bar
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
        ),
      )
          : Column(
        children: [
          // Display the fetched doctors' emails at the top
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal[50]!, Colors.teal[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Doctors\' Emails:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[900],
                  ),
                ),
                SizedBox(height: 10),
                if (doctorsEmails.isEmpty)
                  Text(
                    'There are no selected emails.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ...doctorsEmails.map((email) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.email, color: Colors.teal, size: 20),
                        SizedBox(width: 8),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // Add the instruction text below the selected emails
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select the Doctors you want to send them notification if you click on Emergency Button',
              style: TextStyle(
                fontSize: 16,
                color: Colors.teal[800],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Display the list of doctors
          Expanded(
            child: careRecipients.isEmpty
                ? Center(
              child: Text(
                'There are no doctors in the list.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            )
                : ListView.builder(
              itemCount: careRecipients.length,
              itemBuilder: (context, index) {
                final caregiver = careRecipients[index];
                final isSelected = selectedUsers[index] ?? false; // Track if the card is selected

                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.teal[50] : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedUsers[index] = !(selectedUsers[index] ?? false); // Toggle selection
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        leading: ClipOval(
                          child: Image.network(
                            kIsWeb
                                ? 'http://localhost:3001/${caregiver['image_path']}'
                                : 'http://10.0.2.2:3001/${caregiver['image_path']}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          '${caregiver['First_name']} ${caregiver['Last_name']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        subtitle: Text(
                          caregiver['Email'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              selectedUsers[index] = value ?? false;
                            });
                          },
                          activeColor: Colors.teal, // Change checkbox color when selected
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: SizedBox(
          width: 80,
          height: 80,
          child: FloatingActionButton(
            onPressed: () async {
              final selectedDoctorsIds = careRecipients
                  .asMap()
                  .entries
                  .where((entry) => selectedUsers[entry.key] == true)
                  .map((entry) => int.tryParse(entry.value['User_id'].toString()) ?? 0) // Ensure it's an int
                  .toList();
              await addPatientDoctors(selectedDoctorsIds); // Add selected doctors (empty list if none selected)
              setState(() {
                // Clear the selections after submission
                selectedUsers.clear();
              });
            },
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 36,
            ),
            backgroundColor: Colors.teal,
            elevation: 10, // Add shadow to the floating action button
          ),
        ),
      ),
    );
  }
}