import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'Verifycode.dart';

class Forgetpassword extends StatefulWidget {
  const Forgetpassword({super.key});

  @override
  State<Forgetpassword> createState() => _ForgetpasswordState();
}

class _ForgetpasswordState extends State<Forgetpassword> {
  double _imageOpacity = 0.0; // Opacity for image
  double _emailOpacity = 0.0; // Opacity for email field
  double _buttonsOpacity = 0.0; // Opacity for buttons

  String? email = '';
  String? _errorMessage;

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

    Future.delayed(Duration(milliseconds: 2400), () {
      setState(() {
        _buttonsOpacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forget Password"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Form(
            child: Column(
              children: [
                AnimatedOpacity(
                  opacity: _imageOpacity,
                  duration: Duration(seconds: 2), // Slow transition for image
                  child:               Image.asset(
                    "imgs/project_logo.png",
                    width: MediaQuery.of(context).size.width, // Full width of the screen
                    height: MediaQuery.of(context).size.height * 0.40, // 40% of the screen height
                    fit: BoxFit.cover, // Ensures the image fills the space without distortion
                  ),
                ),
                SingleChildScrollView(
                  child:Container(
                    width: 320,
                    height: 910,
                    child: Column(
                      children: [
                        AnimatedOpacity(
                          opacity: _emailOpacity,
                          duration: Duration(milliseconds: 500),
                          child: Container(
                            margin: EdgeInsets.only(top: 50, right: 10),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: "Enter your Email",
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Email is required";
                                }
                                return null;
                              },
                              onChanged: (val) {
                                email = val;
                              },
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: _buttonsOpacity,
                          duration: Duration(milliseconds: 500),
                          child: Container(
                            height: 50,
                            width: 200,
                            margin: EdgeInsets.only(top: 50),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: MaterialButton(
                                color: Colors.lightBlue,
                                onPressed: () async {
                                  final userData = {
                                    'email': email,
                                  };

                                  try {
                                    final response = await http.post(
                                      Uri.parse('http://10.0.2.2:3001/api/ForgetPassword'),
                                      headers: {'Content-Type': 'application/json'},
                                      body: json.encode(userData),
                                    );

                                    print("Response status: ${response.statusCode}");
                                    print("Response body: ${response.body}");

                                    // Parse the response from the server
                                    final responseData = json.decode(response.body);

                                    if (response.statusCode == 200 && responseData['message'] == 'Verification code sent!') {
                                      // Navigate to the Verifycode page
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Verifycode(email),
                                        ),
                                      );
                                      setState(() {
                                        _errorMessage = null; // Clear any error message
                                      });
                                    } else {
                                      setState(() {
                                        _errorMessage = responseData['message'] ?? 'Invalid email';
                                      });
                                    }
                                  } catch (error) {
                                    print("Request failed: $error");
                                    setState(() {
                                      _errorMessage = "An error occurred: $error";
                                    });
                                  }
                                },

                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 10),
                                    Text(
                                      "Send code to Gmail",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Show error message if user does not exist or if there is any other error
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
