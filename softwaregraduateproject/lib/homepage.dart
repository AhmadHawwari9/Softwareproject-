import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  final String? email;
  final String? password;

  // Constructor to accept email and password
  const Homepage(this.email, this.password, {super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homepage"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display Email
            Text(
              'Email: ${widget.email ?? 'No email provided'}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20), // Space between email and password
            // Display Password
            Text(
              'Password: ${widget.password ?? 'No password provided'}',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
