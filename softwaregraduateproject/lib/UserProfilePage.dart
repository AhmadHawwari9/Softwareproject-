import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UserProfilePage extends StatefulWidget {
  final String jwtToken;
  UserProfilePage({required this.jwtToken, required String email});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Future<Map<String, dynamic>> userDataFuture;
  late Map<String, dynamic> userData;

  final ImagePicker _picker = ImagePicker(); // Image picker instance

  @override
  void initState() {
    super.initState();
    userDataFuture = fetchUserData(); // Initialize data fetching
  }

  // Fetch user data from API
  Future<Map<String, dynamic>> fetchUserData() async {
    final url = Uri.parse('http://10.0.2.2:3001/profile'); // Replace with your API URL
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.jwtToken}', // Include JWT token if required
    });

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load user data');
    }
  }

  // Function to update bio in the database via PUT request
  Future<void> updateBio(String newBio) async {
    final url = Uri.parse('http://10.0.2.2:3001/update-bio'); // API URL for updating bio
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.jwtToken}',
        'Content-Type': 'application/json',
      },
      body: json.encode({'bio': newBio}), // Send the new bio in the request body
    );

    if (response.statusCode == 200) {
      // Handle successful response (update local state or show a success message)
      print('Bio updated successfully');
    } else {
      // Handle error response
      throw Exception('Failed to update bio');
    }
  }



  // Function to update the user's age in the database via PUT request
  Future<void> updateAge(String newAge) async {
    final url = Uri.parse('http://10.0.2.2:3001/update-age'); // API URL for updating age
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.jwtToken}',
        'Content-Type': 'application/json',
      },
      body: json.encode({'age': newAge}), // Send the new age in the request body
    );

    if (response.statusCode == 200) {
      // Handle successful response (update local state or show a success message)
      print('Age updated successfully');
    } else {
      // Handle error response
      throw Exception('Failed to update age');
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        final url = Uri.parse('http://10.0.2.2:3001/update-image');
        final request = http.MultipartRequest('POST', url)
          ..headers['Authorization'] = 'Bearer ${widget.jwtToken}'
          ..files.add(await http.MultipartFile.fromPath('photo', pickedFile.path));

        final response = await request.send();

        if (response.statusCode == 200) {
          final responseString = await response.stream.bytesToString();
          final updatedImagePath = jsonDecode(responseString)['image_path'];

          // Trigger a state refresh with the updated data
          setState(() {
            userData['image_path'] = updatedImagePath;
            userDataFuture = fetchUserData(); // Refresh user data
          });
        } else {
          final responseString = await response.stream.bytesToString();
          print('Failed to update image. Response: $responseString');
          throw Exception('Failed to update image');
        }
      } catch (e) {
        print('Error occurred: $e');
        throw Exception('Error occurred while updating image');
      }
    } else {
      print('No image selected');
    }
  }

  Future<void> updateImage() async {
    final url = Uri.parse('http://10.0.2.2:3001/update-image'); // API URL for updating image
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // Or use camera as source

    if (pickedFile != null) {
      try {
        final request = http.MultipartRequest('POST', url)
          ..headers['Authorization'] = 'Bearer ${widget.jwtToken}' // Include JWT token for authentication
          ..files.add(await http.MultipartFile.fromPath(
            'photo',
            pickedFile.path,
            // Specify the content type as 'image/jpeg' (or adjust as needed)
          ));

        final response = await request.send();

        if (response.statusCode == 200) {
          // Handle successful response (e.g., show a success message, update UI)
          print('Image updated successfully');
          setState(() {
            userData['image_path'] = pickedFile.path; // Update the local image data
          });
        } else {
          // Handle error response
          final responseString = await response.stream.bytesToString();
          print('Failed to update image. Response: $responseString');
          throw Exception('Failed to update image');
        }
      } catch (e) {
        print('Error occurred: $e');
        throw Exception('Error occurred while updating image');
      }
    } else {
      print('No image selected');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: userDataFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // If data is fetched successfully, show profile page
          if (snapshot.hasData) {
            userData = snapshot.data!;
            return ProfileWidget(data: userData, updateBio: updateBio, updateAge: updateAge, updateData: updateUserData, pickImage: pickImage);
          }

          // Default fallback if no data available
          return const Center(child: Text("No data available"));
        },
      ),
    );
  }

  // Function to update the local state when bio or age is updated
  void updateUserData(Map<String, dynamic> newData) {
    setState(() {
      userData = newData;
    });
  }
}


class ProfileWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  final Future<void> Function(String) updateBio;
  final Future<void> Function(String) updateAge;
  final Function(Map<String, dynamic>) updateData;
  final Future<void> Function() pickImage;

  const ProfileWidget({
    Key? key,
    required this.data,
    required this.updateBio,
    required this.updateAge,
    required this.updateData,
    required this.pickImage,
  }) : super(key: key);

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late String bio;
  late String age;

  @override
  void initState() {
    super.initState();
    bio = widget.data["Bio"] ?? 'No bio available.';
    age = widget.data["Age"]?.toString() ?? 'Not available';
  }

  void updateBioAndAge(String newBio, String newAge) {
    setState(() {
      bio = newBio;
      age = newAge;

    });
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.data['image_path'] ?? '';
    final imageUrl = imagePath.isNotEmpty
        ? 'http://10.0.2.2:3001/${imagePath.startsWith('/') ? imagePath.substring(1) : imagePath}'
        : 'https://via.placeholder.com/150';  // Fallback image if no path


    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Banner with Gradient Background
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(
              children: [
                // Stack to overlay the Camera Icon above the Image
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    // CircleAvatar for Profile Image
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: GestureDetector(
                          onTap: widget.pickImage, // Allow user to pick image on tap
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person, size: 60, color: Colors.grey); // Fallback icon
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const CircularProgressIndicator(); // Loader while loading
                            },
                          ),
                        ),
                      ),
                    ),
                    // Camera Icon on top of the Image
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.blue, size: 30),
                        onPressed: widget.pickImage,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "${widget.data["First_name"] ?? 'Unknown'} ${widget.data["Last_name"] ?? ''}",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.data["Email"] ?? 'No email available',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Bio Section with Enhanced Card Design
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Card(
              elevation: 8,
              shadowColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Bio",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                TextEditingController bioController =
                                TextEditingController(text: bio);

                                return AlertDialog(
                                  title: const Text("Edit Bio"),
                                  content: TextField(
                                    controller: bioController,
                                    maxLines: 4,
                                    decoration: const InputDecoration(
                                      hintText: "Enter your bio here...",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await widget.updateBio(bioController.text);
                                        widget.updateData(widget.data); // Update the local data
                                        updateBioAndAge(bioController.text, age); // Update bio in the UI
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Save"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    Text(
                      bio,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Age Section with Icon and Stylish Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Card(
              elevation: 8,
              shadowColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Age:",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      age,
                      style: const TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            TextEditingController ageController =
                            TextEditingController(text: age);

                            return AlertDialog(
                              title: const Text("Edit Age"),
                              content: TextField(
                                controller: ageController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: "Enter your age here...",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await widget.updateAge(ageController.text);
                                    widget.updateData(widget.data); // Update the local data
                                    updateBioAndAge(bio, ageController.text); // Update age in the UI
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Save"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // User Type Section with Clear Typography
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Card(
              elevation: 8,
              shadowColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "User Type:",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.data["Type_oftheuser"] ?? 'Not available',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


