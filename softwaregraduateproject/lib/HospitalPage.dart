import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'HospitalDetails.dart';

class HospitalsPage extends StatefulWidget {
  final String savedToken;
  HospitalsPage(this.savedToken);

  @override
  _HospitalsPageState createState() => _HospitalsPageState();
}

class _HospitalsPageState extends State<HospitalsPage> {
  List<Map<String, String>> hospitals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHospitals();
  }

  Future<void> fetchHospitals() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3001/hospitals'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Map<String, String>> hospitalList = [];

      for (var hospital in data['data']) {
        hospitalList.add({
          'id': hospital['id'].toString(),
          'User_id': hospital['User_id']?.toString() ?? '', // Use null-aware operator
          'name': hospital['name'] ?? '',
          'location': hospital['location'] ?? '',
          'description': hospital['description'] ?? "No description available",
          'clinics': hospital['clinics'] ?? "No clinics listed",
          'workingHours': hospital['workingHours'] ?? "Not specified",
          'doctors': hospital['doctors'] ?? "No doctor list available",
          'contact': hospital['contact'] ?? "No contact info available",
          'image': hospital['user_image_path']?.replaceAll(r'\', '/') ?? '',
          'user_email': hospital['user_email'] ?? "No email available",
        });
      }

      setState(() {
        hospitals = hospitalList;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load hospitals');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hospitals", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: hospitals.length,
        itemBuilder: (context, index) {
          final hospital = hospitals[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: hospital['image'] != null
                    ? NetworkImage(
                    'http://10.0.2.2:3001/${hospital['image']!.startsWith('/') ? hospital['image']!.substring(1) : hospital['image']!}')
                    : null,
              ),
              title: Text(hospital["name"]!),
              subtitle: Text(hospital["location"]!),
              onTap: () {
                final hospitalId = hospital['User_id'] ?? '';  // Use User_id instead of id
                final userEmail = hospital['user_email'] ?? '';  // Correct key for user email

                // Print all hospital data for debugging purposes
                print("Hospital Data: ${hospital}");
                print("id: $hospitalId");
                print("email: $userEmail");

                // Pass the correct data to HospitalDetails page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HospitalDetails(
                      hospital: hospital,  // Pass the full hospital data
                      savedToken: widget.savedToken,
                      userEmail: userEmail,  // Pass userEmail
                      hospitalId: hospitalId,  // Pass User_id as hospitalId
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
