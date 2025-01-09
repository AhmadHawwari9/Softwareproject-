import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:softwaregraduateproject/Login.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class NewPassword extends StatefulWidget {
  final String? email;

  const NewPassword(this.email, {super.key});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double _imageOpacity = 0.0;
  double _emailOpacity = 0.0;
  double _buttonsOpacity = 0.0;

  String? _errorMessage;
  List<String> _validationErrors = [];
  String? newpass;
  String? confirmedpass;
  bool _obscurePassword = true; //
  bool _obscureConfirmPassword = true; //

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        _imageOpacity = 1.0;
      });
    });

    Future.delayed(Duration(milliseconds: 2000), () {
      setState(() {
        _emailOpacity = 1.0;
      });
    });

    Future.delayed(Duration(milliseconds: 3000), () {
      setState(() {
        _buttonsOpacity = 1.0;
      });
    });
  }

  String? validatePassword(String? value) {
    _validationErrors.clear();

    if (value == null || value.isEmpty) {
      _validationErrors.add('Please enter a new password');
    }
    if (value != null && value.length < 8) {
      _validationErrors.add('Password must be at least 8 characters long');
    }
    if (value != null && !RegExp(r'[0-9]').hasMatch(value)) {
      _validationErrors.add('Password must contain at least one number');
    }
    if (value != null && !RegExp(r'[a-zAZ]').hasMatch(value)) {
      _validationErrors.add('Password must contain at least one letter');
    }

    return _validationErrors.isNotEmpty ? _validationErrors.join('\n') : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Set New Password"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(  // Wrap the entire body with SingleChildScrollView
        padding: EdgeInsets.all(0.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AnimatedOpacity(
                opacity: _imageOpacity,
                duration: Duration(seconds: 2),
                child:               Image.asset(
                  "imgs/project_logo.png",
                  width: MediaQuery.of(context).size.width, // Full width of the screen
                  height: MediaQuery.of(context).size.height * 0.40, // 40% of the screen height
                  fit: BoxFit.cover, // Ensures the image fills the space without distortion
                ),
              ),

              AnimatedOpacity(
                opacity: _emailOpacity,
                duration: Duration(seconds: 2),
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  width: 320,
                  child: Column(
                    children: [
                      Text(
                        'Please set a new password for',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        "${widget.email}",
                        style: TextStyle(fontSize: 20, color: Colors.teal),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword; // Toggle the state
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: validatePassword,
                        onChanged: (val) {
                          newpass = val;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword; // Toggle the state
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null; // Return null if validation is successful
                        },
                        onChanged: (val) {
                          confirmedpass = val;
                        },
                      ),
                      if (_validationErrors.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _validationErrors.join('\n'),
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              AnimatedOpacity(
                opacity: _buttonsOpacity,
                duration: Duration(seconds: 2),
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
                            setState(() {
                              _validationErrors.clear();
                              _errorMessage = null;
                            });

                            if (_formKey.currentState!.validate()) {
                              if (confirmedpass == newpass) {
                                try {
                                  final userData = {
                                    'email': widget.email,
                                    'newPassword': newpass
                                  };
                                  final String baseUrl = kIsWeb
                                      ? 'http://localhost:3001' // Web environment
                                      : 'http://10.0.2.2:3001'; // Mobile environment

                                  final response = await http.post(
                                    Uri.parse('$baseUrl/api/ForgetPassword/verifycode/Newpassword'),
                                    headers: {'Content-Type': 'application/json'},
                                    body: json.encode(userData),
                                  );

                                  print("Response status: ${response.statusCode}");
                                  print("Response body: ${response.body}");

                                  if (response.statusCode == 200) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (context) => Loginpage()), // Navigate to the Login page
                                          (Route<dynamic> route) => false, // Remove all previous routes
                                    );

                                    print("user exist");
                                  } else {
                                    final Map<String, dynamic> responseBody = json.decode(response.body);
                                    setState(() {
                                      _validationErrors.addAll(responseBody['errors'].map((error) => error['msg']).toList().cast<String>());
                                    });
                                  }
                                } catch (error) {
                                  print("Request failed: $error");
                                  setState(() {
                                    _errorMessage = "An error occurred: $error";
                                  });
                                }
                              } else {
                                setState(() {
                                  _validationErrors.add('Passwords do not match');
                                });
                              }
                            }
                          },
                          child: Text("Set New Password"),
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
    );
  }
}
