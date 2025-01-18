import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:softwaregraduateproject/CareGiverHomepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AdminHomepage.dart';
import 'CareGiverFileUpload.dart';
import 'CareRecipientHomepage.dart';
import 'Hospitaluser.dart';
import 'Hospitaluserfileuploade.dart';
import 'Login.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;

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

  final baseUrl = kIsWeb
      ? 'http://localhost:3001' // Web environment (localhost)
      : 'http://10.0.2.2:3001'; // Mobile emulator

  Future<void> fetchHomepageAndNavigate(
      BuildContext context, String email, String password, String token) async {
    try {
      // Make the request to /api/homepage to get the user type
      final homepageResponse = await http.get(
        Uri.parse('$baseUrl/api/homepage'),
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



  File? _selectedImage; // For mobile
  Uint8List? _webImage; // For web
  String? _webImageName; // File name for web
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  Future<void> pickFile() async {
    try {
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
        if (result != null) {
          setState(() {
            _webImage = result.files.first.bytes;
            _webImageName = result.files.first.name;
          });
        } else {
          setState(() {
            _webImage = null;
            _webImageName = null;
          });
        }
      } else {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });
        }
      }
    } on PlatformException catch (e) {
      print("Error picking image: $e");
    }
  }


  List<String>? _getMimeTypeFromFile(String filePath) {
    // Attempt to get MIME type using lookupMimeType
    final mimeType = lookupMimeType(filePath);
    if (mimeType != null) {
      final mimeTypeParts = mimeType.split('/');
      if (mimeTypeParts.length == 2) {
        return mimeTypeParts;
      }
    }

    // Fallback to file extension if MIME type cannot be determined
    final extension = path.extension(filePath).toLowerCase();
    if (extension == '.jpg' || extension == '.jpeg') {
      return ['image', 'jpeg'];
    } else if (extension == '.png') {
      return ['image', 'png'];
    } else if (extension == '.gif') {
      return ['image', 'gif'];
    } else if (extension == '.bmp') {
      return ['image', 'bmp'];
    } else if (extension == '.webp') {
      return ['image', 'webp'];
    } else if (extension == '.svg') {
      return ['image', 'svg+xml'];
    } else {
      print('Unsupported file type: $extension');
      return null; // Unsupported file type
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
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: _selectedImage == null && _webImage == null
                            ? Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                            : kIsWeb && _webImage != null
                            ? Image.memory(
                          _webImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
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


                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HospitaluserFileUpload(
                                      userData: Map<String, String>.from(userData),
                                      selectedImage: _selectedImage, // Pass image here
                                      webImage: _webImage, // Pass web image if selected
                                      webImageName: _webImageName,
                                    ),
                                  ),
                                );

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