import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:softwaregraduateproject/profileforanotherusers.dart';
import 'dart:convert';

import 'package:softwaregraduateproject/profileformydoctorswithcalender.dart';
import 'package:flutter/foundation.dart';  // Import for kIsWeb

class CareGiversScreen extends StatefulWidget {
  final String savedToken;
  CareGiversScreen(this.savedToken);

  @override
  _CareGiversScreenState createState() => _CareGiversScreenState();
}

class _CareGiversScreenState extends State<CareGiversScreen> {
  List<dynamic> careRecipients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCareRecipients();
  }


  Future<void> fetchCareRecipients() async {
    // Set the base URL dynamically based on the platform
    final baseUrl = kIsWeb
        ? 'http://localhost:3001' // Web environment
        : 'http://10.0.2.2:3001'; // Mobile emulator

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/caregivers'),  // Use the dynamically set base URL
        headers: {
          'Authorization': 'Bearer ${widget.savedToken}', // Sending token for authorization
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          careRecipients = data['careRecipients']; // Populate the list
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Doctors',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading spinner
          : careRecipients.isEmpty
          ? Center(child: Text('No caregivers available')) // If no data
          : ListView.builder(
        itemCount: careRecipients.length,
        itemBuilder: (context, index) {
          final caregiver = careRecipients[index];
          return Card(
            margin: EdgeInsets.all(15),
            elevation: 5, // Adds shadow for a floating effect
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // Rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                leading: ClipOval(
                  child: Image.network(
                    kIsWeb
                        ? 'http://localhost:3001/${caregiver['image_path']}' // Web environment
                        : 'http://10.0.2.2:3001/${caregiver['image_path']}', // Mobile emulator
                    width: 50, // Set a fixed width for the avatar
                    height: 50, // Set a fixed height for the avatar
                    fit: BoxFit.cover, // Make the image cover the circle
                  )

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
                onTap: () {
                  // Navigate to UserDetailsPage when a caregiver card is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailsPagewithcalender(
                        id: caregiver['User_id'].toString(), // Convert to String
                        savedToken: widget.savedToken, // Pass the token
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
