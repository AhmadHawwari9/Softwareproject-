import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:softwaregraduateproject/PdfReader.dart';
import 'Gps.dart';
import 'Login.dart'; // Ensure this widget is correctly defined
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';

import 'CareGiverHomepage.dart';
import 'Noti.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';


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
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyCt3ijsN07Pwrsawq8SNj1B6iA9hVh7HNY',  // Replace with your Firebase project values
        appId: '1:341638346767:android:4b52a5f11b0893749ecb7a',
        messagingSenderId: '341638346767',
        projectId: 'softwareproject-cf82f',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }


  await Noti.initialize(flutterLocalNotificationsPlugin);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print("User granted permission");
  } else {
    print("User declined or has not accepted permission");
  }

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize("e4855ea9-18df-4a72-8296-e3a54dcdb9fe");

// The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  OneSignal.Notifications.requestPermission(true);


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
