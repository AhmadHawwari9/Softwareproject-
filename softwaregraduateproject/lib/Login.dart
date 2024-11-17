import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:softwaregraduateproject/Forgetpassword.dart';
import 'package:softwaregraduateproject/Signup.dart';
import 'package:softwaregraduateproject/CareGiverHomepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'CareRecipientHomepage.dart';
import 'AdminHomepage.dart';
import 'CareGiverHomepage.dart';
class Loginpage extends StatefulWidget {
  @override
  _LoginpageState createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {


  String? email = '';
  String? password = '';
  String? _errorMessage; // Error message variable
  String? _token;
  bool signinwithgoogle=false;

  // State variables
  bool _isPasswordVisible = false; // Used for toggling password visibility
  double _imageOpacity = 0.0; // Opacity for image
  double _emailOpacity = 0.0; // Opacity for email field
  double _passwordOpacity = 0.0; // Opacity for password field
  double _buttonsOpacity = 0.0; // Opacity for buttons

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add form key to control validation

  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();

    // Control the delay of the appearance of elements
    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _imageOpacity = 1.0;
        });
      }
    });

    Future.delayed(Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _emailOpacity = 1.0;
        });
      }
    });

    Future.delayed(Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() {
          _passwordOpacity = 1.0;
        });
      }
    });

    Future.delayed(Duration(milliseconds: 4000), () {
      if (mounted) {
        setState(() {
          _buttonsOpacity = 1.0;
        });
      }
    });

    // Check if the user is already logged in
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedToken = prefs.getString('token');
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');

    // If user is logged in, directly fetch homepage data and navigate
    if (savedToken != null && savedEmail != null && savedPassword != null) {
      await fetchHomepageAndNavigate(context, savedEmail, savedPassword, savedToken);
    } else {
      // If no login data exists, navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Loginpage()),
      );
    }
  }


  @override
  void dispose() {
    // Cancel all timers to prevent callbacks after dispose
    for (var timer in _timers) {
      timer.cancel();
    }
    _timers.clear(); // Clear the list of timers
    super.dispose();
  }


  Future<void> fetchHomepageAndNavigate(
      BuildContext context, String email, String password, String token) async {
    try {
      // Make the request to /api/homepage to get the user type
      final homepageResponse = await http.get(
        Uri.parse('http://10.0.2.2:3001/api/homepage'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print(homepageResponse.statusCode);
      if (homepageResponse.statusCode == 200) {
        final homepageData = json.decode(homepageResponse.body);
        final userType = homepageData['userType'];

        // Navigate based on userType, passing email, password, and token
        if (userType == 'Care recipient') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => CareRecipientHomepage(email, password, token),
            ),
                (Route<dynamic> route) => false, // This will remove all previous pages
          );
        } else if (userType == 'Admin') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => AdminHomepage(email, password, token),
            ),
                (Route<dynamic> route) => false, // This will remove all previous pages
          );
        } else if (userType == 'Care giver') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => CareGiverHomepage(email, password, token),
            ),
                (Route<dynamic> route) => false, // This will remove all previous pages
          );
        }
      } else {
        // Handle API error (e.g., show an error message to the user)
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to load homepage data'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Handle any exceptions (e.g., network error)
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred: $e'),
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


  Future<void> _saveCredentials(String token, String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  Future<void> _clearCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('email');
    await prefs.remove('password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Form(
            key: _formKey, // Attach the form key here
            child: Column(
              children: [
                // Animated image with fading effect
                AnimatedOpacity(
                  opacity: _imageOpacity,
                  duration: Duration(seconds: 2), // Slow transition for image
                  child: Image.asset("imgs/project_logo.png"),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  width: 320,
                  height: 550,
                  child: Column(
                    children: [
                      // Email Field with animated appearance
                      AnimatedOpacity(
                        opacity: _emailOpacity,
                        duration: Duration(seconds: 2), // Slow transition for email field
                        child: Container(
                          margin: EdgeInsets.only(top: 50, right: 10),
                          child: TextFormField(
                            decoration: InputDecoration(
                              icon: Icon(Icons.person),
                              labelText: "Email",
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter your email";
                              }
                              if (!value.contains("@") || !value.contains(".")) {
                                return "This email is not valid";
                              }
                              if (value.indexOf('@') > value.lastIndexOf('.')) {
                                return "The '@' must appear before the '.'";
                              }
                              if (value.indexOf('@') < 1) {
                                return "The '@' must not be the first character";
                              }
                              if (value.indexOf('.') < value.indexOf('@') + 2) {
                                return "The '.' must not be immediately after '@'";
                              }
                              if (value.endsWith('@') || value.endsWith('.')) {
                                return "Email must not end with '@' or '.'";
                              }
                              return null; // No errors
                            },
                            onChanged: (val) {
                              email = val;
                            },
                          ),
                        ),
                      ),
                      // Password Field with animated appearance and visibility toggle
                      AnimatedOpacity(
                        opacity: _passwordOpacity,
                        duration: Duration(seconds: 2), // Slow transition for password field
                        child: Container(
                          margin: EdgeInsets.only(top: 50, right: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.lock),
                                  labelText: "Password",
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please enter your password";
                                  }
                                  return null;
                                },
                                onChanged: (val) {
                                  password = val;
                                },
                              ),
                              // Error message under password field
                              if (_errorMessage != null)
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Animated appearance for buttons
                      AnimatedOpacity(
                        opacity: _buttonsOpacity,
                        duration: Duration(seconds: 2), // Slow transition for buttons
                        child: Column(
                          children: [
                            // Forget Password Button
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(top: 10),
                              child: MaterialButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => Forgetpassword()),
                                  );
                                },
                                child: Text("Forget Password"),
                              ),
                            ),
                            // Login Button
                            Container(
                              height: 50,
                              width: 200,
                              margin: EdgeInsets.only(top: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: MaterialButton(
                                  color: Colors.lightBlue,
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      // Only proceed if validation is successful
                                      if (email!.isNotEmpty && password!.isNotEmpty) {
                                        print("All fields are filled");
                                        final userData = {
                                          'email': email,
                                          'password': password,
                                        };

                                        try {
                                          final response = await http.post(
                                            Uri.parse('http://10.0.2.2:3001/api/Login'),
                                            headers: {'Content-Type': 'application/json'},
                                            body: json.encode(userData),
                                          );

                                          print("Response status: ${response.statusCode}");
                                          print("Response body: ${response.body}");

                                          if (response.statusCode == 200) {
                                            final responseBody = json.decode(response.body);
                                            _token = responseBody['accesstoken'];
                                            print("User logged in successfully");
                                            setState(() {
                                              _errorMessage = null; // Clear any error message
                                            });

                                            // Save token, email, and password in Shared Preferences
                                            await _saveCredentials(_token!, email!, password!);

                                            // Call the function to handle the homepage request and navigation
                                            await fetchHomepageAndNavigate(context, email!, password!, _token!);

                                          } else {
                                            final responseBody = json.decode(response.body);
                                            setState(() {
                                              _errorMessage = responseBody['message'] ?? "Incorrect Password";
                                            });
                                          }
                                        } catch (error) {
                                          print("Request failed: $error");
                                          setState(() {
                                            _errorMessage = "An error occurred. Please try again.";
                                          });
                                        }
                                      } else {
                                        setState(() {
                                          _errorMessage = "Please fill out both fields";
                                        });
                                      }
                                    }
                                  },



                                  child: Text(
                                    "Login",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                            // Signup Button
                            Container(
                              child: Row(
                                children: [
                                  Container(
                                    height: 60,
                                    padding: EdgeInsets.only(left: 15),
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.only(top: 10),
                                    child: Text(
                                      "Don't have Account?",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  Container(
                                    height: 30,
                                    width: 100,
                                    margin: EdgeInsets.only(top: 15),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: MaterialButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(builder: (context) => Signup()),
                                          );
                                        },
                                        child: Text(
                                          "Sign up",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Gmail Login Button
                            Container(
                              height: 50,
                              width: 200,
                              margin: EdgeInsets.only(top: 15),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: MaterialButton(
                                  color: Colors.red,
                                  onPressed: ()  async{
                                    signInWithGoogle();
                                    signinwithgoogle=true;
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(" G",style: TextStyle(fontSize: 25,color: Colors.white),),
                                      SizedBox(width: 10),
                                      Text(
                                        "Sign In with Gmail",
                                        style: TextStyle(fontSize: 12, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );


  }


  Future<void> signInWithGoogle() async {
    if (signinwithgoogle) {
      try {
        // Trigger the authentication flow
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Now sign in to Firebase with the credential
        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = userCredential.user;

        // Save email and token to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', user?.email ?? '');
        await prefs.setString('token', await user?.getIdToken() ?? '');

        // Ensure these variables are set
        email = user?.email; // User's email
        _token = await user?.getIdToken(); // Get the ID token

        // Log the values to check if they are set correctly
        print('Email: $email');
        print('Token: $_token');

        // Now make the HTTP request to your backend API
        if (email != null && _token != null) {
          final response = await http.post(
            Uri.parse('http://10.0.2.2:3001/api/SignInwithGoogle'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $_token', // Optional: If your API uses token authentication
            },
            body: jsonEncode(<String, String>{
              'email': email!, // Only send the email to backend
            }),
          );

          if (response.statusCode == 200) {
            // Successfully signed in with Google and your API
            print('Sign-in with API successful: ${response.body}');

            // Extract password from response (from backend)
            final responseData = json.decode(response.body);
            final password = responseData['result']['password']; // Assuming the response contains password

            // Use the password (or any other necessary info) from the response
            await fetchHomepageAndNavigate(context, email!, password, _token!);
          } else {
            // Handle error from API
            print('Error from API: ${response.body}');
          }
        } else {
          print('One or more variables are null: email=$email, token=$_token');
        }
      } catch (e) {
        print('Error during sign-in: $e');
      }
    }
  }

}








