import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'Newpassword.dart';

class Verifycode extends StatefulWidget {
  final String? email; // Add email parameter

  const Verifycode(this.email, {super.key});

  @override
  State<Verifycode> createState() => _VerifycodeState();
}

class _VerifycodeState extends State<Verifycode> {
  final TextEditingController _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Opacity variables for animation
  double _imageOpacity = 0.0; // Opacity for image
  double _emailOpacity = 0.0; // Opacity for email and message
  double _buttonsOpacity = 0.0; // Opacity for buttons

  String? _errorMessage;
  String? code;

  bool _isCodeObscured = true; // Variable to toggle code visibility

  @override
  void initState() {
    super.initState();

    // Control the delay of the appearance of elements
    Future.delayed(Duration(milliseconds: 1000), () {
      // Show image after 1000ms
      setState(() {
        _imageOpacity = 1.0;
      });
    });

    Future.delayed(Duration(milliseconds: 2000), () {
      // Show email field after 2000ms
      setState(() {
        _emailOpacity = 1.0;
      });
    });

    Future.delayed(Duration(milliseconds: 3000), () {
      // Show buttons after 3000ms
      setState(() {
        _buttonsOpacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Code",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
      ),
      body: SingleChildScrollView(  // Add SingleChildScrollView here
        child: Padding(
          padding: EdgeInsets.all(0.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Animated image with fading effect
                AnimatedOpacity(
                  opacity: _imageOpacity,
                  duration: Duration(seconds: 2), // Slow transition for image
                  child:Image.asset(
                    "imgs/project_logo.png",
                    width: MediaQuery.of(context).size.width, // Full width of the screen
                    height: MediaQuery.of(context).size.height * 0.40, // 40% of the screen height
                    fit: BoxFit.cover, // Ensures the image fills the space without distortion
                  ),
                ),

                // Animated container for email and code input
                AnimatedOpacity(
                  opacity: _emailOpacity,
                  duration: Duration(seconds: 2), // Slow transition for email text and code input
                  child: Container(
                    margin: EdgeInsets.only(top: 20),
                    width: 320,
                    child: Column(
                      children: [
                        Text(
                          'Please enter the verification code sent to',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "${widget.email}",
                          style: TextStyle(fontSize: 20, color: Colors.teal),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          onChanged: (val) {
                            code = val;
                          },
                          controller: _codeController,
                          decoration: InputDecoration(
                            labelText: 'Verification Code',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isCodeObscured
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isCodeObscured = !_isCodeObscured; // Toggle visibility
                                });
                              },
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6, // Limit to 6 digits
                          obscureText: _isCodeObscured, // Toggle obscure text
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the verification code';
                            }
                            if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                              return 'Code must be exactly 6 digits';
                            }
                            return null; // Return null if validation is successful
                          },
                        ),
                        SizedBox(height: 20),
                        // Display error message if any
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                      ],
                    ),
                  ),
                ),

                // Animated buttons with fade effect
                AnimatedOpacity(
                  opacity: _buttonsOpacity,
                  duration: Duration(seconds: 2), // Slow transition for buttons
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        width: 200,
                        margin: EdgeInsets.only(top: 15),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: MaterialButton(
                            color: Colors.teal,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final userData = {
                                  'email': widget.email,
                                  'code': code,
                                };

                                try {
                                  // Determine base URL based on platform
                                  final String baseUrl = kIsWeb
                                      ? 'http://localhost:3001' // For web development
                                      : 'http://10.0.2.2:3001'; // For Android Emulator

                                  // Send POST request to the API
                                  final response = await http.post(
                                    Uri.parse('$baseUrl/api/ForgetPasswword/verifycode'),
                                    headers: {'Content-Type': 'application/json'},
                                    body: json.encode(userData),
                                  );

                                  // Log the response status and body for debugging
                                  print("Response status: ${response.statusCode}");
                                  print("Response body: ${response.body}");

                                  if (response.statusCode == 200) {
                                    // Navigate to the NewPassword screen if the response is successful
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NewPassword(widget.email),
                                      ),
                                    );
                                    print("User exists");
                                    setState(() {
                                      _errorMessage = null; // Clear any existing error message
                                    });
                                  } else {
                                    // Parse the response and extract the error message
                                    final responseBody = json.decode(response.body);
                                    setState(() {
                                      _errorMessage = responseBody['message'] ?? "Incorrect Code";
                                    });
                                  }
                                } catch (error) {
                                  // Handle request errors
                                  print("Request failed: $error");
                                  setState(() {
                                    _errorMessage = "An error occurred: $error";
                                  });
                                }
                              }
                            },
                            child: Text(
                              "Verify Code",
                              style: TextStyle(color: Colors.white),
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
        ),
      ),
    );
  }
}
