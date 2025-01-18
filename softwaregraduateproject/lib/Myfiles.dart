import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:universal_html/html.dart' as html;

class PdfFilesPage extends StatefulWidget {
  final String jwtToken;

  PdfFilesPage({required this.jwtToken});

  @override
  _PdfFilesPageState createState() => _PdfFilesPageState();
}

class _PdfFilesPageState extends State<PdfFilesPage> {
  List<dynamic> files = [];

  @override
  void initState() {
    super.initState();
    fetchPdfFiles();
  }

  final baseUrl = kIsWeb
      ? 'http://localhost:3001' // Web environment (localhost or public URL)
      : 'http://10.0.2.2:3001'; // Mobile emulator

  // Fetch PDF files from the backend
  Future<void> fetchPdfFiles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/files'), // Backend URL to fetch file paths
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}', // Sending JWT token for authentication
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          files = data['files'] ?? []; // Handle null case for 'files'
        });
      } else {
        throw Exception('Failed to load files');
      }
    } catch (e) {
      print('Error fetching files: $e');
    }
  }

  // Function to delete a file
  Future<void> deleteFile(String fileId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user/files/$fileId'), // API endpoint with file ID
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}', // Sending JWT token for authentication
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File deleted successfully')),
        );

        // Refresh the file list
        fetchPdfFiles();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete file')),
        );
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

// Show confirmation dialog before deleting a file
  Future<void> showDeleteConfirmationDialog(String fileId, String fileName) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete_forever, // Elegant delete icon
                  color: Colors.teal, // Soft purple for elegance
                  size: 60.0,
                ),
                SizedBox(height: 16.0),
                Text(
                  'Confirm Deletion',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal, // Deep indigo for the title
                  ),
                ),
                SizedBox(height: 12.0),
                Text(
                  'Are you sure you want to delete the file: "$fileName"?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.teal, // White text for contrast
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: Text(
                        'No',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop(); // Close the dialog
                        await deleteFile(fileId); // Delete the file
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.deepOrangeAccent, // White text for contrast
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: Text(
                        'Yes',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Medical Reports',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal, // Set a custom color for the app bar
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
      ),
      body: files.isEmpty
          ? Center(child: CircularProgressIndicator()) // Styled loading indicator
          : ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          final filePath = file['path']?.toString() ?? ''; // Ensure filePath is a string
          final fileId = file['id']?.toString() ?? ''; // Ensure fileId is a string

          return Padding(
            padding: const EdgeInsets.all(8.0), // Padding for spacing
            child: Card(
              elevation: 5.0, // Card shadow for better visual separation
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              child: ListTile(
                contentPadding:
                EdgeInsets.all(16.0), // Add padding inside the tile
                leading: Icon(
                  Icons.picture_as_pdf, // PDF icon for visual recognition
                  color: Colors.red,
                  size: 30.0,
                ),
                title: Text(
                  filePath.split('/').last, // Extract file name
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold, // Bold text for the file name
                  ),
                ),
                subtitle: Text('Tap to view',
                    style: TextStyle(fontSize: 14.0)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if(!kIsWeb)
                    IconButton(
                      icon: Icon(Icons.download),
                      onPressed: () async {
                        try {
                          String localPath = await downloadPdf(filePath);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                Text('Downloaded to $localPath')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Error downloading file: $e')),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () {
                        showDeleteConfirmationDialog(
                          fileId,
                          filePath.split('/').last,
                        );
                      },
                    ),
                  ],
                ),
                onTap: () async {
                  // When a file is tapped, download the PDF and then navigate to the viewer
                  try {
                    String localPath = await downloadPdf(filePath);
                    if(!kIsWeb){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfViewerPage(
                            pdfPath:
                            localPath, // Pass the local file path to the viewer
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error opening file: $e')),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<String> downloadPdf(String pdfPath) async {
    try {
      if (pdfPath.isEmpty) throw Exception('Invalid file path');

      // Determine the base URL based on platform (web or mobile)
      final baseUrl = kIsWeb
          ? 'http://localhost:3001' // Web environment (localhost)
          : 'http://10.0.2.2:3001'; // Mobile emulator

      final url = Uri.parse('$baseUrl/$pdfPath'); // Complete URL for mobile/web

      if (kIsWeb) {
        // Web-specific code
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          final base64Data = base64Encode(bytes);

          // Create an anchor element to trigger the file download on web
          final anchor = html.AnchorElement(href: "data:application/octet-stream;base64,$base64Data")
            ..download = pdfPath.split('/').last
            ..target = 'blank'
            ..click(); // Trigger the download by simulating a click

          return 'File downloaded successfully in the browser';
        } else {
          throw Exception('Failed to download PDF');
        }
      } else {
        // Mobile-specific code (Android/iOS)
        final permissionStatus = await Permission.storage.request();
        if (permissionStatus.isGranted) {
          final response = await http.get(url);
          if (response.statusCode == 200) {
            final appDocDir = await getExternalStorageDirectory();
            if (appDocDir != null) {
              final file = File('${appDocDir.path}/${pdfPath.split('/').last}');
              await file.writeAsBytes(response.bodyBytes); // Save the file

              return file.path; // Return the local path of the file
            } else {
              throw Exception('Failed to get storage directory');
            }
          } else {
            throw Exception('Failed to download PDF');
          }
        } else {
          throw Exception('Storage permission denied');
        }
      }
    } catch (e) {
      print('Error downloading PDF: $e');
      throw e;
    }
  }
}

class PdfViewerPage extends StatelessWidget {
  final String pdfPath;

  PdfViewerPage({required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal, // Keep consistent theme
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
      ),
      body: Center(
        child: PDFView(
          filePath: pdfPath, // Pass the local path to the PDF file
        ),
      ),
    );
  }
}
