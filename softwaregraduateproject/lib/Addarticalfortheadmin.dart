import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';

class AddArticlePage extends StatefulWidget {
  @override
  _AddArticlePageState createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage; // For mobile
  Uint8List? _webImage; // For web
  String? _webImageName; // File name for web
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        // Web-specific image picker
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          // Read the file as bytes and update the UI in setState
          final imageBytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = imageBytes; // Store image as bytes
            _webImageName = pickedFile.name; // Store file name
          });
        }
      } else {
        // Mobile-specific image picker
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


  Future<void> _submitArticle() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null && _webImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final apiUrl = kIsWeb
          ? 'http://localhost:3001/addnewArticle' // Web environment
          : 'http://10.0.2.2:3001/addnewArticle'; // Mobile emulator

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.fields['title'] = _titleController.text;
      request.fields['content'] = _contentController.text;

      if (kIsWeb && _webImage != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'photo',
          _webImage!,
          filename: _webImageName,
          contentType: MediaType('image', 'jpeg'), // Adjust MIME type if needed
        ));
      } else if (_selectedImage != null) {
        final mimeTypeData = _getMimeTypeFromFile(_selectedImage!.path);
        if (mimeTypeData == null) {
          throw Exception('Unable to determine mime type of the selected image');
        }

        request.files.add(await http.MultipartFile.fromPath(
          'photo', // The backend key for file upload
          _selectedImage!.path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        ));
      }

      // Send the request
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Article added successfully!')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _selectedImage = null;
          _webImage = null;
          _webImageName = null;
        });
      } else {
        throw Exception('Failed to add article. Status code: ${response.statusCode}');
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No Internet connection or server unreachable')),
      );
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
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
    } else if (extension == '.pdf') {
      return ['application', 'pdf'];
    } else {
      print('Unsupported file type: $extension');
      return null; // Unsupported file type
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Article', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
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
              SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitArticle,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: _isSubmitting
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'Add Article',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
