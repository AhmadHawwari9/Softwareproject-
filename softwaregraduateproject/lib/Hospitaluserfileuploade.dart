import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'Login.dart';

class HospitaluserFileUpload extends StatefulWidget {
  final Map<String, String> userData;
  final File? selectedImage;  // You might want to keep this as it is.
  final Uint8List? webImage;  // Declare the webImage property here.
  final String? webImageName;  // Declare the webImageName property here.

  HospitaluserFileUpload({
    required this.userData,
    this.selectedImage,
    this.webImage,  // Add the webImage parameter to the constructor.
    this.webImageName,  // Add the webImageName parameter to the constructor.
  });

  @override
  _CareGiverFileUploadState createState() => _CareGiverFileUploadState();
}

class _CareGiverFileUploadState extends State<HospitaluserFileUpload> {
  File? _selectedFile;
  bool _isLoading = false;



  FilePickerResult? result;

  void pickFileweb() async {
    result = await FilePicker.platform.pickFiles();  // Assign result here

    if (result != null) {
      if (kIsWeb) {
        // Web: Use bytes and name
        Uint8List? fileBytes = result!.files.single.bytes;
        String fileName = result!.files.single.name;

        if (fileBytes != null) {
          setState(() {
            _selectedFile = File(""); // Placeholder to trigger UI update
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Picked file: $fileName")),
          );
        }
      } else {
        // Non-Web: Use file path
        setState(() {
          _selectedFile = File(result!.files.single.path!);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Picked file: ${_selectedFile!.path.split('/').last}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No file selected.")),
      );
    }
  }
  void pickFileapp() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }


  Future<void> submitApplicationapp() async {
    if (_selectedFile != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://10.0.2.2:3001/caregiverRequestToTheAdmin'),
        );

        request.fields.addAll(widget.userData);

        if (_selectedFile != null) {
          var photoFile = await http.MultipartFile.fromPath('photo', _selectedFile!.path);
          request.files.add(photoFile);
        }

        var file = await http.MultipartFile.fromPath('file', _selectedFile!.path);
        request.files.add(file);

        var response = await request.send();

        if (response.statusCode == 201) {
          var responseBody = await http.Response.fromStream(response);
          var responseData = json.decode(responseBody.body);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Application submitted successfully!")),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Loginpage()),
                (route) => false,
          );
        } else {
          var responseBody = await http.Response.fromStream(response);
          var responseData = json.decode(responseBody.body);

          // Check if the response contains errors
          if (responseData.containsKey('errors')) {
            // Loop through the errors to find the email-related error
            for (var error in responseData['errors']) {
              if (error['path'] == 'email') {
                // Display a user-friendly message for email-related errors
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Email already exists. Please try another email.")),
                );
                break; // Stop after finding the email error
              }
            }
          } else if (responseData.containsKey('error')) {
            // If the backend returns a single error message
            String errorMessage = responseData['error'];
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
          } else {
            // Fallback error message if no specific error is found
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to submit application. Please try again.")),
            );
          }

          // Log the error details for debugging
          print("Error: ${response.statusCode} - ${response.reasonPhrase}");
          print("Response Body: $responseData");
        }
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred. Please try again.")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload a file first.")),
      );
    }
  }


  bool _isImageFile(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(ext);
  }


  final baseUrl = kIsWeb
      ? 'http://localhost:3001' // Web environment (localhost)
      : 'http://10.0.2.2:3001'; // Mobile emulator

  Future<void> submitApplicationweb() async {
    if (widget.userData['typeofuser'] == 'Hospital') {
      if (_selectedFile != null || kIsWeb) {
        setState(() {
          _isLoading = true;
        });

        try {
          if (kIsWeb && result == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("File selection canceled.")),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }

          var request = http.MultipartRequest(
            'POST',
            Uri.parse('$baseUrl/caregiverRequestToTheAdmin'),
          );

          request.fields.addAll(widget.userData);

          // Add the image from the previous page if available
          if (widget.webImage != null && widget.webImageName != null) {
            request.files.add(
              http.MultipartFile.fromBytes(
                'photo',
                widget.webImage!,
                filename: widget.webImageName,
              ),
            );
          }

          // Add the file selected from this page
          if (kIsWeb && result != null) {
            Uint8List? fileBytes = result!.files.single.bytes;
            String? fileName = result!.files.single.name;

            if (fileBytes != null && fileName != null) {
              request.files.add(
                http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to read file.")),
              );
              setState(() {
                _isLoading = false;
              });
              return;
            }
          } else if (!kIsWeb && _selectedFile != null) {
            var file = await http.MultipartFile.fromPath('file', _selectedFile!.path);
            request.files.add(file);
          }

          var response = await request.send();

          if (response.statusCode == 201) {
            var responseBody = await http.Response.fromStream(response);
            var responseData = json.decode(responseBody.body);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Application submitted successfully!")),
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Loginpage()),
                  (route) => false,
            );
          } else {
            var responseBody = await http.Response.fromStream(response);
            var responseData = json.decode(responseBody.body);

            // Check if the response contains errors
            if (responseData.containsKey('errors')) {
              // Loop through the errors to find the email-related error
              for (var error in responseData['errors']) {
                if (error['path'] == 'email') {
                  // Display a user-friendly message for email-related errors
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Email already exists. Please try another email.")),
                  );
                  break; // Stop after finding the email error
                }
              }
            } else if (responseData.containsKey('error')) {
              // If the backend returns a single error message
              String errorMessage = responseData['error'];
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMessage)),
              );
            } else {
              // Fallback error message if no specific error is found
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to submit application. Please try again.")),
              );
            }

            // Log the error details for debugging
            print("Error: ${response.statusCode} - ${response.reasonPhrase}");
            print("Response Body: $responseData");
          }
        } catch (e) {
          print("Error: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("An error occurred. Please try again.")),
          );
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please upload a file first.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You are not authorized to submit as a caregiver.")),
      );
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hospital Application",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Hospital Application",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Upload your certificate or any proof that you are Hospital.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: kIsWeb ? pickFileweb : pickFileapp,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.teal, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: _selectedFile == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file, size: 50, color: Colors.teal),
                    SizedBox(height: 10),
                    Text(
                      "Tap to upload a file",
                      style: TextStyle(fontSize: 16, color: Colors.teal),
                    ),
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isImageFile(_selectedFile!.path)
                        ? Image.file(_selectedFile!, height: 100, width: 100, fit: BoxFit.cover)
                        : Icon(Icons.insert_drive_file, size: 50, color: Colors.teal),
                    SizedBox(height: 10),
                    Text(
                      _selectedFile!.path.split('/').last,
                      style: TextStyle(fontSize: 16, color: Colors.teal),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : (kIsWeb ? submitApplicationweb : submitApplicationapp),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                "Submit Application",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
