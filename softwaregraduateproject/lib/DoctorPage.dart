import 'package:flutter/material.dart';
import 'UserToDoctor.dart';



class DoctorPage extends StatefulWidget {
  @override
  _DoctorPageState createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  // قائمة الأطباء مع تفاصيلهم
  final List<Map<String, String>> _doctors = [
    {"name": "Dr. John Doe", "specialization": "Cardiologist", "image": "assets/doctor1.jpg", "id": "1"},
    {"name": "Dr. Sarah Smith", "specialization": "Dermatologist", "image": "assets/doctor2.jpg", "id": "2"},
    {"name": "Dr. William Brown", "specialization": "Neurologist", "image": "assets/doctor3.jpg", "id": "3"},
    {"name": "Dr. Emma Johnson", "specialization": "Pediatrician", "image": "assets/doctor4.jpg", "id": "4"},
  ];

  // الانتقال إلى صفحة تفاصيل الطبيب
  void _navigateToDoctorDetails(BuildContext context, Map<String, String> doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserToDoctor(doctor: doctor), // الانتقال إلى الصفحة الجديدة
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Text(
          'Doctors List',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _doctors.length,
          itemBuilder: (context, index) {
            final doctor = _doctors[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(doctor["image"]!),
                ),
                title: Text(doctor["name"]!),
                subtitle: Text(doctor["specialization"]!),
                onTap: () => _navigateToDoctorDetails(context, doctor), // الانتقال إلى صفحة تفاصيل الطبيب
              ),
            );
          },
        ),
      ),

    );
  }
}
