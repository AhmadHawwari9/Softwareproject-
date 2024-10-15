import 'package:flutter/material.dart';

import 'Login.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatefulWidget{
MyApp({super.key});
State <StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State <MyApp> {
  int i=0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Loginpage(),);
  }

}


