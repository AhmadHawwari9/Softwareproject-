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

import 'ResponsePage.dart';
class PDFReaderApp extends StatelessWidget {
  final String jwtToken;
  PDFReaderApp({required this.jwtToken});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PDFReaderScreen(jwtToken: jwtToken),
    );
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

  // Method to pick and extract text from the PDF
  Future<void> _pickAndExtractPDF() async {
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

        // Send extracted data to the backend
        await _sendDataToBackend();

        pdfDocument.dispose(); // Dispose of the document after use
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error extracting text: $e')),
        );
      }
    }
  }

  Future<void> _sendDataToBackend() async {
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
          await _sendExtractedTextToBackend(_extractedText);
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

  Future<void> _sendExtractedTextToBackend(String extractedText) async {
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



  void _showResponsePopup(BuildContext context, String responseText) {
    // Navigate to the ResponsePage and pass the responseText as a parameter
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResponsePage(responseText: responseText),
      ),
    );
  }






  // Method to request storage permission
  Future<bool> _requestStoragePermission() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission denied')),
      );
      return false; // Returning false if permission is denied
    }
    return true; // Returning true if permission is granted
  }

  // Method to download the form and save it to the Downloads folder
  Future<void> _downloadForm() async {
    // Request storage permission
    bool hasPermission = await _requestStoragePermission();
    if (!hasPermission) return; // If permission is denied, return early

    try {
      // Load the PDF file from assets
      final byteData = await rootBundle.load('assets/PDFmedicalformreport/reportform.pdf');
      final buffer = byteData.buffer.asUint8List();

      // Get the directory for the Downloads folder
      final directory = await _getDownloadsDirectory();
      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing Downloads folder')),
        );
        return;
      }

      print('Download Path: ${directory.path}');

      // Define the file path for saving the downloaded file
      final tempFile = File('${directory.path}/reportform.pdf');

      // Write the PDF bytes to the file
      await tempFile.writeAsBytes(buffer);
      print('File written to: ${tempFile.path}');

      // Show a message once the download is complete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form downloaded successfully to Downloads folder!')),
      );
    } catch (e) {
      print('Error downloading form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading form: $e')),
      );
    }
  }

  // Method to get the Downloads directory
  Future<Directory?> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // For Android, use external storage directories
      final directory = Directory('/storage/emulated/0/Download');
      if (await directory.exists()) {
        return directory;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download directory does not exist')),
        );
        return null;
      }
    }
    return null; // For iOS or other platforms, you can handle it differently
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical PDF Reader'),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: true,
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
                      onPressed: _downloadForm,
                      icon: Icon(Icons.download),
                      label: Text('Download Form'),
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
              onPressed: _pickAndExtractPDF,
              icon: Icon(Icons.picture_as_pdf),
              label: Text('Pick and Extract PDF'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),

            // PDF View Section
            _filePath == null
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
