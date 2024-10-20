import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON
import 'package:shared_preferences/shared_preferences.dart'; // For handling preferences
import 'Login.dart'; // Ensure your login page is imported here

class Homepage extends StatefulWidget {
  final String savedEmail;
  final String savedPassword;
  final String savedToken;
  Homepage(this.savedEmail,this.savedPassword,this.savedToken);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String? email; // Email retrieved from SharedPreferences
  String? password; // Password retrieved from SharedPreferences
  String? token; // Token retrieved from SharedPreferences
  String? apiResponse; // To store the API response

  // Function to fetch homepage data with token authentication
  Future<void> fetchHomepageData() async {
    final url = Uri.parse('http://10.0.2.2:3001/api/homepage'); // Update with the correct URL
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '' // Passing the token in the headers for authentication
        },
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        setState(() {
          apiResponse = 'Success: ${jsonDecode(response.body)['message']}';
        });
      } else {
        setState(() {
          apiResponse = 'Failed: ${jsonDecode(response.body)['error']}';
        });
      }
    } catch (error) {
      setState(() {
        apiResponse = 'Error: $error';
      });
    }
  }

  // Function to load email, password, and token from SharedPreferences
  Future<void> _loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email'); // Retrieve email
      password = prefs.getString('password'); // Retrieve password
      token = prefs.getString('token'); // Retrieve token
    });
    if (token != null) {
      fetchHomepageData(); // Fetch data if token exists
    }
  }

  // Function to log out the user by clearing saved credentials and navigating to the login page
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear saved credentials

    GoogleSignIn googleSignIn=GoogleSignIn();
    googleSignIn.disconnect();
    // Navigate back to the login page after logging out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  Loginpage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCredentials(); // Load saved credentials when the page is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homepage"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout, // Log out when the button is pressed
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display Email
            Text(
              'Email: ${email ?? 'No email provided'}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20), // Space between email and password
            // Display Password
            Text(
              'Password: ${password ?? 'No password provided'}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            // Display API Response
            apiResponse != null
                ? Text(
              apiResponse!,
              style: const TextStyle(fontSize: 24, color: Colors.green),
            )
                : const CircularProgressIndicator(), // Show loading indicator while waiting for the response
            const SizedBox(height: 20),
            // Logout Button
            ElevatedButton(
              onPressed: _logout, // Call the logout function
              child: const Text(
                'Log Out',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
