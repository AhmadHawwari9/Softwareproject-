import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:softwaregraduateproject/homepage.dart';

import 'Login.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool _isPasswordVisible = false; // Toggle password visibility
  bool status = false;
  String? selectedRole = "";
  String? firstName = '';
  String? lastName = '';
  String? email = '';
  String? age;
  String? password = '';
  String? _token;

  // Animation Opacity Variables
  double _imageOpacity = 0.0;
  double _firstNameOpacity = 0.0;
  double _lastNameOpacity = 0.0;
  double _emailOpacity = 0.0;
  double _ageOpacity = 0.0;
  double _passwordOpacity = 0.0;
  double _roleOpacity = 0.0;
  double _buttonOpacity = 0.0;

  // GlobalKey for form validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Control the delay of the appearance of elements
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _imageOpacity = 1.0;
      });
    });

    Future.delayed(Duration(milliseconds: 600), () {
      setState(() {
        _firstNameOpacity = 1.0;
      });
    });

    Future.delayed(Duration(milliseconds: 900), () {
      setState(() {
        _lastNameOpacity = 1.0;
      });
    });

    Future.delayed(Duration(milliseconds: 1200), () {
      setState(() {
        _emailOpacity = 1.0;
      });
    });

    Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        _ageOpacity = 1.0;
      });
    });

    Future.delayed(Duration(milliseconds: 1800), () {
      setState(() {
        _passwordOpacity = 1.0;
      });
    });

    Future.delayed(Duration(milliseconds: 2100), () {
      setState(() {
        _roleOpacity = 1.0;
      });
    });

    Future.delayed(Duration(milliseconds: 2400), () {
      setState(() {
        _buttonOpacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up to SafeAging"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey, // Assign the form key
          child: Column(
            children: [
              // Image with fade animation
              AnimatedOpacity(
                opacity: _imageOpacity,
                duration: Duration(milliseconds: 500),
                child: Image.asset("imgs/project_logo.png"),
              ),

              Container(
                width: 320,
                height: 850,
                child: Column(
                  children: [
                    // First Name Field with fade animation
                    AnimatedOpacity(
                      opacity: _firstNameOpacity,
                      duration: Duration(milliseconds: 500),
                      child: Container(
                        margin: EdgeInsets.only(top: 50, right: 10),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "First Name",
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "First name is required";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            firstName = val;
                          },
                        ),
                      ),
                    ),
                    // Last Name Field with fade animation
                    AnimatedOpacity(
                      opacity: _lastNameOpacity,
                      duration: Duration(milliseconds: 500),
                      child: Container(
                        margin: EdgeInsets.only(top: 30, right: 10),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "Last Name",
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Last name is required";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            lastName = val;
                          },
                        ),
                      ),
                    ),
                    // Email Field with fade animation
                    AnimatedOpacity(
                      opacity: _emailOpacity,
                      duration: Duration(milliseconds: 500),
                      child: Container(
                        margin: EdgeInsets.only(top: 30, right: 10),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "Email",
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Email is required";
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return "Please enter a valid email";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            email = val;
                          },
                        ),
                      ),
                    ),
                    // Age Field with fade animation
                    AnimatedOpacity(
                      opacity: _ageOpacity,
                      duration: Duration(milliseconds: 500),
                      child: Container(
                        margin: EdgeInsets.only(top: 30, right: 10),
                        child: TextFormField(
                          keyboardType: TextInputType.number, // Allow only numbers
                          decoration: InputDecoration(
                            labelText: "Age",
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Age is required";
                            }
                            if (int.tryParse(value) == null) {
                              return "Please enter a valid number";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            age = val;
                          },
                        ),
                      ),
                    ),
                    // Password Field with toggle visibility and fade animation
                    AnimatedOpacity(
                      opacity: _passwordOpacity,
                      duration: Duration(milliseconds: 500),
                      child: Container(
                        margin: EdgeInsets.only(top: 30, right: 10),
                        child: TextFormField(
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: "Password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
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
                              return "Password is required";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            password = val;
                          },
                        ),
                      ),
                    ),
                    // Role Selection with fade animation
                    AnimatedOpacity(
                      opacity: _roleOpacity,
                      duration: Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 60),
                            margin: EdgeInsets.only(top: 25),
                            child: Text(
                              "Choose the type of the user",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          RadioListTile(
                            activeColor: Colors.blue,
                            title: Text("Care giver"),
                            value: "Care giver",
                            groupValue: selectedRole,
                            onChanged: (val) {
                              setState(() {
                                selectedRole = val!;
                              });
                            },
                          ),
                          RadioListTile(
                            activeColor: Colors.blue,
                            title: Text("Care recipient"),
                            value: "Care recipient",
                            groupValue: selectedRole,
                            onChanged: (val) {
                              setState(() {
                                selectedRole = val!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    // Sign Up Button with fade animation
                    AnimatedOpacity(
                      opacity: _buttonOpacity,
                      duration: Duration(milliseconds: 500),
                      child: Container(
                        height: 50,
                        width: 200,
                        margin: EdgeInsets.only(top: 30),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: MaterialButton(
                            color: Colors.lightBlue,
                            // Inside the onPressed method of the Sign Up button
                            onPressed: () async {
                              // Validate the form
                              if (_formKey.currentState!.validate()) {
                                print("All fields are valid");

                                final userData = {
                                  'first_name': firstName,
                                  'last_name': lastName,
                                  'email': email,
                                  'age': age.toString(), // Ensure it's sent as a string if required
                                  'password': password,
                                  'typeofuser': selectedRole, // Ensure this matches the expected key
                                };

                                try {

                                  final response = await http.post(
                                    Uri.parse('http://10.0.2.2:3001/api/users'),
                                    headers: {'Content-Type': 'application/json'},
                                    body: json.encode(userData),
                                  );

                                  print("Response status: ${response.statusCode}");
                                  print("Response body: ${response.body}");

                                  if (response.statusCode == 200 || response.statusCode == 201) {
                                    // User created successfully
                                    final responseBody = json.decode(response.body);
                                    _token = responseBody['accesstoken'];
                                    print("User created successfully");
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (context) => Loginpage()), // Navigate to the Login page
                                          (Route<dynamic> route) => false, // Remove all previous routes
                                    );
                                  } else if (response.statusCode == 409||response.statusCode == 500) { // Assuming 409 is used for email already exists
                                    // Show a SnackBar indicating the email already exists
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Email already exists. Please use another email."),
                                        backgroundColor: Colors.red,  // You can customize the color
                                      ),
                                    );
                                  } else {
                                    // Handle other potential errors
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("An error occurred. Please try again."),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (error) {
                                  print("Request failed: $error");
                                  // Show SnackBar for network errors
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Network error. Please try again."),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                print("Validation failed");
                              }
                            },

                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                              ),
                            ),
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
    );
  }
}
