import 'package:flutter/material.dart';
import 'chatwithspecificperson.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

class HospitalDetails extends StatelessWidget {
  final Map<String, String> hospital;
  final String savedToken;
  final String hospitalId;
  final String userEmail;

  const HospitalDetails({
    Key? key,
    required this.hospital,
    required this.savedToken,
    required this.userEmail,
    required this.hospitalId,
  }) : super(key: key);

  // Dynamically set the base URL depending on the environment
  final String baseUrl = kIsWeb
      ? 'http://localhost:3001' // Web environment
      : 'http://10.0.2.2:3001'; // Mobile environment

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${hospital["name"]}', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hospital Image with rounded borders and shadow
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: hospital['image'] != null
                    ? Image.network(
                  // Use the dynamic base URL
                  '$baseUrl/${hospital['image']!.startsWith('/') ? hospital['image']!.substring(1) : hospital['image']!}',
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                )
                    : Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(Icons.home, size: 80, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Hospital Name
            Text(
              '${hospital["name"] ?? "N/A"}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 10),

            // Location
            _buildInfoRow('Location', hospital["location"]),
            const SizedBox(height: 10),

            // Description
            _buildSectionTitle('Description'),
            _buildInfoText(hospital["description"]),
            const SizedBox(height: 20),

            // Clinics
            _buildSectionTitle('Clinics'),
            _buildInfoText(hospital["clinics"]),
            const SizedBox(height: 20),

            // Working Hours
            _buildSectionTitle('Working Hours'),
            _buildInfoText(hospital["workingHours"]),
            const SizedBox(height: 20),

            // Doctors
            _buildSectionTitle('Doctors'),
            _buildInfoText(hospital["doctors"]),
            const SizedBox(height: 20),

            // Contact Information
            _buildSectionTitle('Contact'),
            _buildInfoText(hospital["contact"]),
            const SizedBox(height: 20),

            // Contact Button (For action like calling)
            ElevatedButton(
              onPressed: () {
                // final hospitalId = hospital["User_id"] ?? "";
                // final useremail = hospital["user_email"] ?? "";
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      otherUserId: hospitalId,
                      userEmail: userEmail,
                      jwtToken: savedToken,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Set the background color
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0), // Increase padding
                minimumSize: Size(double.infinity, 60), // Make the button take full width and increase height
              ),
              child: Text(
                'Contact Hospital',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18, // Increase font size
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build title of sections
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
    );
  }

  // Helper function to build text content
  Widget _buildInfoText(String? content) {
    return Text(
      content ?? "Not available",
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      softWrap: true,
    );
  }

  // Helper function to build location and contact rows
  Widget _buildInfoRow(String title, String? content) {
    return Row(
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        Expanded(
          child: Text(
            content ?? "Not available",
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
