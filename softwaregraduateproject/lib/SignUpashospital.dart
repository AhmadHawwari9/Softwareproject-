import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:softwaregraduateproject/CareGiverHomepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AdminHomepage.dart';
import 'CareGiverFileUpload.dart';
import 'CareRecipientHomepage.dart';
import 'Hospitaluser.dart';
import 'Hospitaluserfileuploade.dart';
import 'Login.dart';

File? _image;


class Signupashospital extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signupashospital> {
  bool _isPasswordVisible = false; // Toggle password visibility
  bool status = false;
  String? selectedRole = "Hospital";
  String? firstName = '';
  String? lastName = '';
  String? email = '';
  String? age;
  String? password = '';
  String? _token;
  File? _image;
  String? _errorMessage;

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




    _checkLoginStatus();
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
              builder: (context) => CareRecipientHomepage(email, password, token,false),
            ),
                (route) => false, // This removes all previous routes
          );
        } else if (userType == 'Admin') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => AdminHomepage(email, password, token,false),
            ),
                (route) => false, // This removes all previous routes
          );
        } else if (userType == 'Care giver') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => CareGiverHomepage(email, password, token,false),
            ),
                (route) => false, // This removes all previous routes
          );
        }
        else{
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HospitalUserForm(email, password, token,false),
            ),
                (route) => false, // This removes all previous routes
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



  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedToken = prefs.getString('token');
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');

    if (savedToken != null && savedEmail != null && savedPassword != null) {
      await fetchHomepageAndNavigate(context, savedEmail, savedPassword, savedToken);

    }
  }



  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _image = File(result.files.single.path!);
      });
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
      appBar: AppBar(
        title: Text("Sign Up as Hospital",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
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
                child:               Image.asset(
                  "imgs/project_logo.png",
                  width: MediaQuery.of(context).size.width, // Full width of the screen
                  height: MediaQuery.of(context).size.height * 0.40, // 40% of the screen height
                  fit: BoxFit.cover, // Ensures the image fills the space without distortion
                ),
              ),

              Container(
                width: 320,
                height: 1050,
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

                    Container(
                      padding: EdgeInsets.only(right: 60),
                      margin: EdgeInsets.only(top: 25),
                      child: Text(
                        "Choose your profile photo",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Image Selection Area
                    GestureDetector(
                      onTap: pickFile,
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.teal, width: 2),
                          image: _image != null
                              ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _image == null
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload,
                              color: Colors.teal,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Upload Photo",
                              style: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                            : null,
                      ),
                    ),

                    SizedBox(height: 10),
                    Text("Tap to select your profile picture", style: TextStyle(color: Colors.grey)),
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
                            color: Colors.teal,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                print('First Name: ${firstName ?? 'null'}');
                                print('Last Name: ${lastName ?? 'null'}');
                                print('Email: ${email ?? 'null'}');
                                print('Age: ${age ?? 'null'}');
                                print('Password: ${password ?? 'null'}');
                                print('User Type: ${selectedRole ?? 'null'}');

                                final userData = {
                                  'first_name': firstName ?? '',
                                  'last_name': lastName ?? '',
                                  'email': email ?? '',
                                  'age': age?.isNotEmpty == true ? age : '0',
                                  'password': password ?? '',
                                  'typeofuser': selectedRole ?? 'guest',
                                };


                                  // Navigate to CareGiverFileUpload and pass userData
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HospitaluserFileUpload(userData: Map<String, String>.from(userData),
                                        ),
                                      ));

                              }
                            }

                            ,



                            child: Text(
                              "Sign Up",
                              style: TextStyle(color: Colors.white, fontSize: 18),
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