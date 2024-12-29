import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Forgetpassword.dart';
import 'Hospitaluser.dart';
import 'Noti.dart';
import 'SignUpashospital.dart';
import 'Signup.dart';  // Import SignUp Page
import 'CareGiverHomepage.dart';
import 'CareRecipientHomepage.dart';
import 'AdminHomepage.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();


class Loginpage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<Loginpage> {
  String? email = '';
  String? password = '';
  String? _errorMessage;
  String? _token;
  bool _isPasswordVisible = false;
  bool _isCheckingLogin = true; // Flag to track if login check is in progress
  bool isGoogleSignInEnabled = false; // Flag for Google Sign-In

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Noti.initialize(flutterLocalNotificationsPlugin);
    _checkLoginStatus(); // Check if the user is logged in
  }

  // Check if there are saved credentials in SharedPreferences
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedToken = prefs.getString('token');
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');
    bool? savedGoogleSignInFlag = prefs.getBool('isGoogleSignInEnabled') ?? false;

    if (savedToken != null && savedEmail != null && savedPassword != null) {
      // If credentials are found, navigate to the appropriate homepage
      isGoogleSignInEnabled = savedGoogleSignInFlag; // Set flag
      await fetchHomepageAndNavigate(context, savedEmail, savedPassword, savedToken, isGoogleSignInEnabled);
    } else {
      // If no saved credentials, stop loading and show the login page
      setState(() {
        _isCheckingLogin = false;
      });
    }
  }

  Future<void> fetchHomepageAndNavigate(
      BuildContext context, String email, String password, String token, bool isGoogleSignInEnabled) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3001/api/homepage'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userType = data['userType'];

        Widget homepage;
        if (userType == 'Care recipient') {
          homepage = CareRecipientHomepage(email, password, token, isGoogleSignInEnabled);
        } else if (userType == 'Admin') {
          homepage = AdminHomepage(email, password, token, isGoogleSignInEnabled);
        } else if(userType == 'Care giver') {
          homepage = CareGiverHomepage(email, password, token, isGoogleSignInEnabled);
        }else{
          homepage=HospitalUserForm(email, password, token, isGoogleSignInEnabled);
      }

        // If mounted, navigate to the homepage
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => homepage),
          );
        }
      } else {
        _showErrorDialog('Failed to load homepage data');
      }
    } catch (e) {
      _showErrorDialog('An error occurred: $e');
    }
  }

  Future<void> _saveCredentials(String token, String email, String password, bool isGoogleSignInEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setBool('isGoogleSignInEnabled', isGoogleSignInEnabled);
  }

  Future<http.Response> _loginUser(Map<String, String> userData) async {
    try {
      return await http.post(
        Uri.parse('http://10.0.2.2:3001/api/Login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );
    } on SocketException {
      throw Exception('No Internet connection or server unreachable');
    } catch (e) {
      throw Exception('Unexpected error occurred: $e');
    }
  }

  void _showErrorDialog(String message) {
    if (mounted) {
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
  }

  Future<void> signInWithGoogle() async {
    if (!isGoogleSignInEnabled) {
      return; // Skip Google sign-in if the flag is false
    }

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled the sign-in

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        final token = await user.getIdToken();
        email = user.email;

        await prefs.setString('email', email ?? '');
        await prefs.setString('token', token ?? '');
        await prefs.setBool('isGoogleSignInEnabled', true); // Set flag to true

        final response = await http.post(
          Uri.parse('http://10.0.2.2:3001/api/SignInwithGoogle'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'email': email}),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          password = data['result']['password'];
          await fetchHomepageAndNavigate(context, email!, password!, token!, true);
        } else {
          _showErrorDialog('Google sign-in failed');
        }
      }
    } catch (e) {
      _showErrorDialog('Google sign-in error: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingLogin) {
      // Show loading spinner while checking login status
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // Display the progress indicator
        ),
      );
    }

    // Show the login form if no user is logged in
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "imgs/project_logo.png",
                width: MediaQuery.of(context).size.width, // Full width of the screen
                height: MediaQuery.of(context).size.height * 0.40, // 40% of the screen height
                fit: BoxFit.cover, // Ensures the image fills the space without distortion
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.person,color: Colors.teal,),
                    labelText: 'Email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Invalid email';
                    return null;
                  },
                  onChanged: (val) => email = val,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock,color: Colors.teal,),
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,color: Colors.teal,),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your password';
                    return null;
                  },
                  onChanged: (val) => password = val,
                ),
              ),

              // Align "Forget Password?" to the left of the password field
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Forgetpassword()),
                  ),
                  child: Text('Forget Password?',style: TextStyle(color: Colors.teal),),
                ),
              ),

              if (_errorMessage != null)
                Text(_errorMessage!, style: TextStyle(color: Colors.red)),

              // "Login" button - larger, more beautiful
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.teal, // Button color
                  foregroundColor: Colors.white, // Text color
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final response = await _loginUser({'email': email!, 'password': password!});
                    if (response.statusCode == 200) {
                      final data = json.decode(response.body);
                      _token = data['accesstoken'];
                      await _saveCredentials(_token!, email!, password!, isGoogleSignInEnabled);
                      await fetchHomepageAndNavigate(context, email!, password!, _token!, isGoogleSignInEnabled);
                    } else {
                      setState(() => _errorMessage = 'Login failed');
                    }
                  }
                },
                child: Text('Login'),
              ),

              SizedBox(height: 20), // Space between buttons

              // "Sign In with Google" button - larger, more beautiful
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.red, // Button color
                  foregroundColor: Colors.white, // Text color
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Signupashospital()), // Navigate to SignUp page
                ),
                child: Text('Sign Up as a Hospital'),
              ),

              SizedBox(height: 20), // Space between buttons

              // "Don't have an account?" text
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Signup()), // Navigate to SignUp page
                ),
                child: Text('Don\'t have an account? Sign up here',style: TextStyle(color: Colors.teal),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
