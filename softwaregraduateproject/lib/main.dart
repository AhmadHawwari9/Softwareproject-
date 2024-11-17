import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Login.dart'; // Ensure this widget is correctly defined
import 'package:firebase_analytics/firebase_analytics.dart';


import 'CareGiverHomepage.dart';

@pragma("vm:entry point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message received");

  // Check if the notification exists in the message
  if (message.notification != null) {
    print("Notification title: ${message.notification!.title}");
    print("Notification body: ${message.notification!.body}");

    // Example: Handle the notification here (for local notifications, etc.)
    // You can show a local notification or handle the message as needed
  } else {
    print("No notification data in the message.");
  }

  // Optionally, you can handle other data payload here
  if (message.data.isNotEmpty) {
    print("Message data: ${message.data}");
    // Process any data payload that came with the message
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Set notification options for the foreground
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
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
