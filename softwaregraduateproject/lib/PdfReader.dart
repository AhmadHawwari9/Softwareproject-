import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf_pdf;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart'; // Import for file system access
import 'package:permission_handler/permission_handler.dart'; // Import for permission handling
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html; // Import universal_html package

import 'ResponsePage.dart';

class PDFReaderApp extends StatelessWidget {
  final String jwtToken;
  PDFReaderApp({required this.jwtToken});

  @override
  Widget build(BuildContext context) {
    return PDFReaderScreen(jwtToken: jwtToken);
  }
}


class PDFReaderScreen extends StatefulWidget {
  final String jwtToken;  // Add this field to hold the token

  PDFReaderScreen({required this.jwtToken});
  @override
  _PDFReaderScreenState createState() => _PDFReaderScreenState();
}

class _PDFReaderScreenState extends State<PDFReaderScreen> {
  String? _filePath;
  String _extractedText = '';

  Future<void> _pickAndExtractPDFweb() async {
    if (kIsWeb) {
      final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'application/pdf';
      uploadInput.click();

      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files == null || files.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No file selected')),
          );
          return;
        }

        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);

        reader.onLoadEnd.listen((e) async {
          final bytes = reader.result as Uint8List;
          try {
            final pdfDocument = sf_pdf.PdfDocument(inputBytes: bytes);
            final text = sf_pdf.PdfTextExtractor(pdfDocument).extractText();
            print(text);
            setState(() {
              _extractedText = text;
            });

            kIsWeb?
            // Send the extracted text to the backend
            await _sendExtractedTextToBackendweb(_extractedText):await _sendExtractedTextToBackendapp(_extractedText);
            pdfDocument.dispose();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error extracting text: $e')),
            );
          }
        });

        reader.onError.listen((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error reading file: $e')),
          );
        });
      });
    }
  }



  Future<void> _sendDataToBackendapp() async {
    if (_filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No file selected')),
      );
      return;
    }

    try {
      // Open the PDF file as bytes
      final fileBytes = File(_filePath!).readAsBytesSync();

      // Extract the original filename from the file path
      String originalFilename = _filePath!.split('/').last;

      // Get the current timestamp
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a new filename by appending the timestamp
      String newFilename = '$originalFilename-$timestamp.pdf';

      // Prepare the multipart request
      var uri = Uri.parse('http://10.0.2.2:3001/upload');
      var request = http.MultipartRequest('POST', uri);

      // Attach the file to the request
      request.files.add(
        http.MultipartFile.fromBytes(
          'file', // The form field name for the file
          fileBytes,
          filename: newFilename, // The new filename with timestamp
          contentType: MediaType('application', 'pdf'),
        ),
      );

      // Add authorization header (JWT token)
      request.headers['Authorization'] = 'Bearer ${widget.jwtToken}';

      // Send the file upload request
      var response = await request.send();

      if (response.statusCode == 200) {
        // File uploaded successfully, now send the extracted text
        if (_extractedText.isNotEmpty) {
          kIsWeb?
          // Send the extracted text to the backend
          await _sendExtractedTextToBackendweb(_extractedText):await _sendExtractedTextToBackendapp(_extractedText);
        }

        // Show success message after file upload and text extraction
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File uploaded and data processed successfully!')),
        );
      } else {
        String responseBody = await response.stream.bytesToString();
        print('Failed upload response: $responseBody'); // Log response body
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload file')),
        );
      }
    } catch (e) {
      print('Error uploading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
      );
    }
  }

  final baseUrl = kIsWeb
      ? 'http://localhost:3001' // Web environment (localhost)
      : 'http://10.0.2.2:3001'; // Mobile emulator


  Future<void> _sendDataToBackendweb() async {
    if (_filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No file selected')),
      );
      return;
    }

    try {
      // Open the PDF file as bytes
      final fileBytes = File(_filePath!).readAsBytesSync();

      // Extract the original filename from the file path
      String originalFilename = _filePath!.split('/').last;

      // Get the current timestamp
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a new filename by appending the timestamp
      String newFilename = '$originalFilename-$timestamp.pdf';

      // Prepare the multipart request
      var uri = Uri.parse('$baseUrl/upload');  // Use baseUrl here
      var request = http.MultipartRequest('POST', uri);

      // Attach the file to the request
      request.files.add(
        http.MultipartFile.fromBytes(
          'file', // The form field name for the file
          fileBytes,
          filename: newFilename, // The new filename with timestamp
          contentType: MediaType('application', 'pdf'),
        ),
      );

      // Add authorization header (JWT token)
      request.headers['Authorization'] = 'Bearer ${widget.jwtToken}';

      // Send the file upload request
      var response = await request.send();

      if (response.statusCode == 200) {
        // File uploaded successfully, now send the extracted text
        if (_extractedText.isNotEmpty) {
          kIsWeb?
          // Send the extracted text to the backend
          await _sendExtractedTextToBackendweb(_extractedText):await _sendExtractedTextToBackendapp(_extractedText);
        }

        // Show success message after file upload and text extraction
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File uploaded and data processed successfully!')),
        );

        // Navigate to the ResponsePage with the result
        _showResponsePopup(context, 'File uploaded and processed successfully!');
      } else {
        String responseBody = await response.stream.bytesToString();
        print('Failed upload response: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload file')),
        );
      }
    } catch (e) {
      print('Error uploading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
      );
    }
  }

  Future<void> _sendExtractedTextToBackendapp(String extractedText) async {
    try {
      // Sanitize the extracted text by escaping special characters
      String sanitizedText = extractedText.replaceAll(RegExp(r'[\n\r\t]'), ''); // Removes newlines, carriage returns, tabs

      // Prepare the POST request for sending extracted text
      var uri = Uri.parse('http://10.0.2.2:3001/check'); // URL to backend
      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'text': sanitizedText}), // Sending sanitized extracted text
      );

      // Check the response status code and handle accordingly
      if (response.statusCode == 200||response.statusCode==201) {
        // Show the response in a beautiful popup
        _showResponsePopup(context,response.body);
      } else {
        // Log the response error for debugging purposes
        print('Error: ${response.statusCode} - ${response.body}');
        // If the server response isn't successful, show an error
        _showResponsePopup(context,'Failed to process the document. this report you enter may contain wrong values Please try again later.');
      }
    } catch (e) {
      // Log any error that occurs during the request for debugging purposes
      print('Error sending text: $e');
      // Show a user-friendly error message in the popup
      _showResponsePopup(context,'An error occurred while sending data.');
    }
  }


  Future<void> _sendExtractedTextToBackendweb(String extractedText) async {
    try {
      // Sanitize the extracted text by escaping special characters
      String sanitizedText = extractedText.replaceAll(RegExp(r'[\n\r\t]'), ''); // Removes newlines, carriage returns, tabs

      // Prepare the POST request for sending extracted text
      var uri = Uri.parse('$baseUrl/check'); // Use baseUrl here
      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'text': sanitizedText}), // Sending sanitized extracted text
      );

      // Check the response status code and handle accordingly
      if (response.statusCode == 200 || response.statusCode == 201) {
        // If successful, show the response in the ResponsePage
        _showResponsePopup(context, response.body);
      } else {
        // Log the response error for debugging purposes
        print('Error: ${response.statusCode} - ${response.body}');
        // If the server response isn't successful, show an error
        _showResponsePopup(context, 'Failed to process the document. This report may contain wrong values. Please try again later.');
      }
    } catch (e) {
      // Log any error that occurs during the request for debugging purposes
      print('Error sending text: $e');
      // Show a user-friendly error message in the popup
      _showResponsePopup(context, 'An error occurred while sending data.');
    }
  }




  void _showResponsePopup(BuildContext context, String responseText) {
    // Navigate to the ResponsePage and pass the responseText as a parameter
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResponsePage(responseText: responseText),
      ),
    );
  }




  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
        return false;
      }

      // For Android 11 and higher, check if 'MANAGE_EXTERNAL_STORAGE' permission is needed
      if (await Permission.manageExternalStorage.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Manage External Storage permission denied')),
        );
        return false;
      }
      if (!await Permission.manageExternalStorage.request().isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Manage External Storage permission required')),
        );
        return false;
      }
    }
    return true;
  }


  Future<void> _downloadFormweb() async {
    try {
      // Load the PDF file from assets
      final byteData = await rootBundle.load('assets/PDFmedicalformreport/reportform.pdf');
      final buffer = byteData.buffer.asUint8List();

      // Create a Blob object from the PDF file
      final blob = html.Blob([buffer]);

      // Create an anchor element and simulate a click to download the file
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = 'reportform.pdf'
        ..click();

      // Clean up the URL object after download
      html.Url.revokeObjectUrl(url);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form downloaded successfully!')),
      );
    } catch (e) {
      print('Error downloading form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading form: $e')),
      );
    }
  }

  Future<Directory?> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // Use path_provider to get the external storage directory
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final downloadsDir = Directory('${directory.path}/Download');
        if (await downloadsDir.exists()) {
          return downloadsDir;
        } else {
          await downloadsDir.create(recursive: true);
          return downloadsDir;
        }
      }
    }
    return null; // For other platforms, handle accordingly
  }



  Future<void> _pickAndExtractPDFapp() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );


    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path;
      });

      try {
        // Load the PDF file as bytes
        final fileBytes = File(_filePath!).readAsBytesSync();
        final pdfDocument = sf_pdf.PdfDocument(inputBytes: fileBytes);

        // Extract text from the PDF
        final text = sf_pdf.PdfTextExtractor(pdfDocument).extractText();
        print(text);

        setState(() {
          _extractedText = text;
        });
        kIsWeb?
        // Send the extracted text to the backend
        await _sendDataToBackendweb(): await _sendDataToBackendapp();;


        pdfDocument.dispose(); // Dispose of the document after use
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error extracting text: $e')),
        );
      }
    }
  }

  Future<void> _downloadFormapp() async {
    // Request storage permission
    bool hasPermission = await _requestStoragePermission();
    if (!hasPermission) return;

    try {
      // Load the PDF file from assets
      final byteData = await rootBundle.load('assets/PDFmedicalformreport/reportform.pdf');
      final buffer = byteData.buffer.asUint8List();

      // Define the Downloads directory path
      final downloadsPath = '/storage/emulated/0/Download';
      final downloadsDir = Directory(downloadsPath);

      // Ensure the Downloads folder exists
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Define the file path for saving the downloaded file
      final filePath = '$downloadsPath/reportform.pdf';
      final file = File(filePath);

      // Write the PDF bytes to the file
      await file.writeAsBytes(buffer);

      // Verify the file exists
      if (await file.exists()) {
        print('File successfully written to: $filePath');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Form downloaded successfully to Downloads folder!')),
        );
      } else {
        print('File does not exist after writing.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: File not found after download.')),
        );
      }
    } catch (e) {
      print('Error downloading form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading form: $e')),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical PDF Reader',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Instructions Section
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please use our form to enter your medical examinations.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: kIsWeb?_downloadFormweb:_downloadFormapp,
                      icon: Icon(Icons.download,color: Colors.teal,),
                      label: Text('Download Form',style: TextStyle(color: Colors.teal),),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // PDF Pick and Extract Section
            ElevatedButton.icon(
              onPressed: kIsWeb?_pickAndExtractPDFweb:_pickAndExtractPDFapp,
              icon: Icon(Icons.picture_as_pdf,color: Colors.teal,),
              label: Text('Pick and Extract PDF',style:TextStyle(color: Colors.teal),),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),

            // PDF View Section
            kIsWeb
                ? Expanded(child: Center(child: Text('')))
                : _filePath == null
                ? Expanded(child: Center(child: Text('No PDF selected')))
                : Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: PDFView(filePath: _filePath!),
              ),
            ),


            // Extracted Text Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Extracted Text:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: Text(_extractedText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
