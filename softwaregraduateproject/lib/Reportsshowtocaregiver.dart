import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class MedicalReportsPage extends StatelessWidget {
  final List<dynamic> files;

  MedicalReportsPage({required this.files});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Reports',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
      ),
      body: files.isEmpty
          ? Center(child: Text('No files available', style: TextStyle(fontSize: 18.0)))
          : ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          final filePath = file['path'] ?? '';
          String displayFilePath = filePath.replaceAll('Uploade/', '');

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16.0),
                leading: Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                  size: 30.0,
                ),
                title: Text(
                  displayFilePath, // Display the file path without "Uploade/"
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('Tap to view', style: TextStyle(fontSize: 14.0)),
                onTap: () async {
                  // When a file is tapped, download the PDF and then navigate to the viewer
                  try {
                    String localPath = await downloadPdf(filePath);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfViewerPage(
                          pdfPath: localPath, // Pass the local file path to the viewer
                        ),
                      ),
                    );
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

  // Function to download PDF file and save it locally
  Future<String> downloadPdf(String pdfPath) async {
    try {
      if (pdfPath.isEmpty) throw Exception('Invalid file path');
      final permissionStatus = await Permission.storage.request();

      if (permissionStatus.isGranted) {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:3001/$pdfPath'),
        );

        if (response.statusCode == 200) {
          // Get the path for the Downloads folder
          final downloadsDirectory =
          Directory('/storage/emulated/0/Download'); // Path to Downloads

          if (!await downloadsDirectory.exists()) {
            await downloadsDirectory.create(recursive: true); // Create the folder
          }

          // Create the file path
          final file = File(
            '${downloadsDirectory.path}/${pdfPath.split('/').last}',
          );
          await file.writeAsBytes(response.bodyBytes); // Save the file

          return file.path; // Return the local path of the file
        } else {
          throw Exception('Failed to download PDF');
        }
      } else {
        throw Exception('Storage permission denied');
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
