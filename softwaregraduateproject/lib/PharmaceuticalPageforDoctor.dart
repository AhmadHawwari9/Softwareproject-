import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';  // Make sure to add the intl package in your pubspec.yaml
import 'package:flutter/foundation.dart' show kIsWeb;

class Medication {
  final int id;  // Add the id field
  final String name;
  final String time;
  final String doctor;
  bool isDoctor;  // Add this field to check if the logged-in doctor is the same

  Medication({
    required this.id,
    required this.name,
    required this.time,
    required this.doctor,
    this.isDoctor = false,
  });

  // Factory method to convert JSON to Medication object
  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],  // Ensure the id is included
      name: json['medicine_name'],
      time: _formatTime(json['timings']),
      doctor: json['doctor_email'],
    );
  }

  // Method to format the time string
  static String _formatTime(String time) {
    try {
      final timeFormat = DateFormat("HH:mm"); // Format the time to HH:mm
      final formattedTime = timeFormat.parse(time); // Parse the input time string
      return DateFormat("HH:mm").format(formattedTime) + " /day";  // Return formatted time with /day
    } catch (e) {
      return time;  // If parsing fails, return the original time string
    }
  }
}


class PharmaceuticalPagefordoctor extends StatefulWidget {
  final String savedToken;
  final String recipientId;

  PharmaceuticalPagefordoctor(this.savedToken,this.recipientId);

  @override
  _PharmaceuticalPageState createState() => _PharmaceuticalPageState();
}

class _PharmaceuticalPageState extends State<PharmaceuticalPagefordoctor> {
  List<Medication> _medications = [];

  @override
  void initState() {
    super.initState();
    _fetchMedications();
  }
  final baseUrl = kIsWeb
      ? 'http://localhost:3001' // Web environment (localhost)
      : 'http://10.0.2.2:3001'; // Mobile emulator

  Future<String> _fetchDoctorEmail() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/email'),
      headers: {
        'Authorization': 'Bearer ${widget.savedToken}',  // Add token to header
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['email'];  // Assuming the response contains 'email'
    } else {
      throw Exception('Failed to load doctor email');
    }
  }

  Future<void> _deleteMedication(Medication medication) async {
    final url = Uri.parse('$baseUrl/medication/${medication.id}');  // Use id instead of name

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.savedToken}',  // Sending token in headers
      },
    );

    if (response.statusCode == 200) {
      // Successfully deleted, so refresh the medications list
      _fetchMedications();
    } else {
      throw Exception('Failed to delete medication');
    }
  }



  Future<void> _fetchMedications() async {
    try {
      final doctorEmail = await _fetchDoctorEmail();  // Fetch doctor's email
      final response = await http.get(
        Uri.parse('$baseUrl/medications/${widget.recipientId}'),
        headers: {
          'Authorization': 'Bearer ${widget.savedToken}', // Add token to header
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> medicationList = json.decode(response.body);

        setState(() {
          _medications = medicationList
              .map((data) => Medication.fromJson(data))
              .toList();

          // Add doctor email to each medication
          _medications.forEach((medication) {
            medication.isDoctor = medication.doctor == doctorEmail;
          });
        });
      } else {
        throw Exception('Failed to load medications');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _navigateToMedicationDetails(BuildContext context, Medication medication) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationDetailsPage(medication: medication),
      ),
    );
  }

  Future<void> _addMedication({
    required String medicineName,
    required String dosage,
    required List<String> timings,
  }) async {
    final url = Uri.parse('$baseUrl/add-medication');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.savedToken}',  // Sending the token in headers
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'patientId': widget.recipientId,  // Assuming recipientId is the patientId
        'medicineName': medicineName,
        'dosage': dosage,
        'timings': timings,
      }),
    );

    if (response.statusCode == 200) {
      // Handle successful addition (e.g., refresh the list of medications)
      _fetchMedications();
    } else {
      throw Exception('Failed to add medication');
    }
  }

  void _showAddMedicationDialog() {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _dosageController = TextEditingController();
    final TextEditingController _timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Add New Medication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Medication Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _dosageController,
              decoration: InputDecoration(
                labelText: 'Dosage (e.g., 250 mg)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: 'Times (comma separated, e.g., 08:00:00, 14:00:00)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final String medicineName = _nameController.text;
              final String dosage = _dosageController.text;
              final List<String> timings = _timeController.text.split(',').map((e) => e.trim()).toList();

              // Ensure timings are in the correct format
              _addMedication(
                medicineName: medicineName,
                dosage: dosage,
                timings: timings,
              );
              _fetchMedications();
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 4,
        title: Text(
          'My Medications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _medications.length,
                itemBuilder: (context, index) {
                  final medication = _medications[index];

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: Icon(Icons.medication, color: Colors.teal),
                      title: Text(
                        medication.name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Time: ${medication.time}/day\nDoctor: ${medication.doctor}',
                        style: TextStyle(fontSize: 14),
                      ),
                      onTap: () => _navigateToMedicationDetails(context, medication),
                      trailing: medication.isDoctor // Check if the doctor's email matches
                          ? IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMedication(medication), // Call delete function
                      )
                          : null,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _showAddMedicationDialog,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Medication',
      ),
    );
  }

}

class MedicationDetailsPage extends StatelessWidget {
  final Medication medication;

  const MedicationDetailsPage({Key? key, required this.medication}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Medication Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,

          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 4,
        iconTheme: IconThemeData(color: Colors.white),

      ),
      body: Container(
        height: double.infinity,  // Ensure the container takes the full screen height
        decoration: BoxDecoration(
          color: Colors.teal.shade100,  // Lighter teal color for the entire background
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMedicationCard(),
                SizedBox(height: 20),
                _buildDetailCard('Time', '${medication.time}/day'),
                _buildDetailCard('Doctor', medication.doctor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.medication, size: 50, color: Colors.teal.shade700),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                medication.name,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String detail) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.teal.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              detail,
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
