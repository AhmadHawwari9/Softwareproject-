import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'Conversations.dart';
import 'Login.dart';


class Homepage extends StatefulWidget {
  final String savedEmail;
  final String savedPassword;
  final String savedToken;
  Homepage(this.savedEmail, this.savedPassword, this.savedToken);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String? email;
  String? password;
  String? token;
  String? apiResponse;

  Future<void> fetchHomepageData() async {
    final url = Uri.parse('http://10.0.2.2:3001/api/homepage');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? ''
        },
      );

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

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Homepage"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Email: ${email ?? 'No email provided'}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              'Password: ${password ?? 'No password provided'}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            apiResponse != null
                ? Text(
              apiResponse!,
              style: const TextStyle(fontSize: 24, color: Colors.green),
            )
                : const CircularProgressIndicator(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: const Text(
                'Log Out',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            // Button to navigate to Messages page
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConversationsPage(jwtToken: token!)),
                );
              },
              child: const Text(
                'Go to Messages',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
