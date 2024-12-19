import 'package:flutter/material.dart';
//import 'PatientPage.dart';

class PharmaceuticalPage extends StatefulWidget {
  @override
  _PharmaceuticalPageState createState() => _PharmaceuticalPageState();
}

class _PharmaceuticalPageState extends State<PharmaceuticalPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, String>> _medications = [
    {"name": "Paracetamol", "time": "08:00 AM", "doctor": "Dr. Smith", "description": "Used to treat mild to moderate pain and fever."},
    {"name": "Ibuprofen", "time": "02:00 PM", "doctor": "Dr. Johnson", "description": "Reduces pain, inflammation, and fever."},
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();

  void _addMedication() {
    if (_nameController.text.isNotEmpty &&
        _timeController.text.isNotEmpty &&
        _doctorController.text.isNotEmpty) {
      setState(() {
        _medications.add({
          "name": _nameController.text,
          "time": _timeController.text,
          "doctor": _doctorController.text,
          "description": "No description provided.",
        });
      });
      _nameController.clear();
      _timeController.clear();
      _doctorController.clear();
      Navigator.of(context).pop();
    }
  }

  void _showAddMedicationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Medication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Medication Name'),
            ),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(labelText: 'Time (e.g., 08:00 AM)'),
            ),
            TextField(
              controller: _doctorController,
              decoration: InputDecoration(labelText: 'Doctor Name'),
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
            onPressed: _addMedication,
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _navigateToMedicationDetails(BuildContext context, Map<String, String> medication) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationDetailsPage(medication: medication),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Text(
          'My Medications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
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
                    child: ListTile(
                      leading: Icon(Icons.medication, color: Colors.teal),
                      title: Text(medication["name"]!),
                      subtitle: Text('Time: ${medication["time"]!}\nDoctor: ${medication["doctor"]!}'),
                      onTap: () => _navigateToMedicationDetails(context, medication),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showAddMedicationDialog,
              child: Text(
                'Add Medication',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MedicationDetailsPage extends StatelessWidget {
  final Map<String, String> medication;

  const MedicationDetailsPage({Key? key, required this.medication}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication Details'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${medication["name"]}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Time: ${medication["time"]}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Doctor: ${medication["doctor"]}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Description: ${medication["description"]}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
