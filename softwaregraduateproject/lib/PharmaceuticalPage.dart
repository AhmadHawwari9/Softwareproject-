import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';  // Make sure to add the intl package in your pubspec.yaml

// Assuming you have a class to represent medication
class Medication {
  final String name;
  final String time;
  final String doctor;

  Medication({
    required this.name,
    required this.time,
    required this.doctor,
  });

  // Factory method to convert JSON to Medication object
  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
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

class PharmaceuticalPage extends StatefulWidget {
  final String savedToken;
  PharmaceuticalPage(this.savedToken);

  @override
  _PharmaceuticalPageState createState() => _PharmaceuticalPageState();
}

class _PharmaceuticalPageState extends State<PharmaceuticalPage> {
  List<Medication> _medications = [];

  @override
  void initState() {
    super.initState();
    _fetchMedications();
  }

  Future<void> _fetchMedications() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3001/medications'),
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
      });
    } else {
      throw Exception('Failed to load medications');
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

  void _showAddMedicationDialog() {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _timeController = TextEditingController();
    final TextEditingController _doctorController = TextEditingController();

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
              controller: _timeController,
              decoration: InputDecoration(
                labelText: 'Time (e.g., 08:00 AM)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _doctorController,
              decoration: InputDecoration(
                labelText: 'Doctor Name',
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
              setState(() {
                _medications.add(Medication(
                  name: _nameController.text,
                  time: _timeController.text,
                  doctor: _doctorController.text,
                ));
              });
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
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
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
