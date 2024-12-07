import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'Login.dart';

class CareGiverFileUpload extends StatefulWidget {
  final Map<String, String> userData;

  CareGiverFileUpload({required this.userData});

  @override
  _CareGiverFileUploadState createState() => _CareGiverFileUploadState();
}

class _CareGiverFileUploadState extends State<CareGiverFileUpload> {
  File? _selectedFile;
  bool _isLoading = false;

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  bool _isImageFile(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(ext);
  }

  Future<void> submitApplication() async {
    if (_selectedFile != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Prepare the multipart request
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://10.0.2.2:3001/caregiverRequestToTheAdmin'),
        );

        // Add text fields
        request.fields.addAll(widget.userData);

        // Add the photo (assuming it's another file field you need to add)
        if (_selectedFile != null) {
          var photoFile = await http.MultipartFile.fromPath('photo', _selectedFile!.path);
          request.files.add(photoFile);
        }

        // Log the form data
        print('Request Fields: ${request.fields}');
        print('Photo Field Added: ${_selectedFile!.path}');

        // Add the file (this is likely the hardware presentation file)
        var file = await http.MultipartFile.fromPath('file', _selectedFile!.path);
        request.files.add(file);

        // Log the file details
        print('File: ${file.filename}');

        // Send the request
        var response = await request.send();

        if (response.statusCode == 201) {
          var responseBody = await http.Response.fromStream(response);
          var responseData = json.decode(responseBody.body);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Application submitted successfully!")),
          );

          // Log response data
          print("Response Data: $responseData");

          // Navigate to the login page and remove all previous routes
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Loginpage()),
                (route) => false, // This removes all previous routes
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to submit application.")),
          );
          print("Error: ${response.statusCode} - ${response.reasonPhrase}");
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Caregiver Application"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
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
                    "Caregiver Application",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Upload your certificate or any proof of your ability to act as a caregiver.also put an image of your identity inside the pdf and then upload them in one file This application will be sent to the admin for review. Try again to sign in to the app later.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: pickFile,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blueAccent, width: 2),
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
                    Icon(Icons.upload_file, size: 50, color: Colors.blueAccent),
                    SizedBox(height: 10),
                    Text(
                      "Tap to upload a file",
                      style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                    ),
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isImageFile(_selectedFile!.path)
                        ? Image.file(_selectedFile!, height: 100, width: 100, fit: BoxFit.cover)
                        : Icon(Icons.insert_drive_file, size: 50, color: Colors.blueAccent),
                    SizedBox(height: 10),
                    Text(
                      _selectedFile!.path.split('/').last,
                      style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : submitApplication,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: Colors.blueAccent,
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
