import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Login.dart'; // Ensure this widget is correctly defined

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Loginpage(), // Ensure Loginpage is properly implemented
    );
  }
}
