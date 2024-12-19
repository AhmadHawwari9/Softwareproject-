import 'package:flutter/material.dart';
import 'HospitalDetails.dart';

class HospitalsPage extends StatelessWidget {
  final List<Map<String, String>> hospitals = [
    {
      "name": "City Hospital",
      "image": "assets/hospital1.jpg",
      "address": "123 Main Street, City",
      "contact": "+1 123-456-7890",
    },
    {
      "name": "Green Valley Clinic",
      "image": "assets/hospital2.jpg",
      "address": "456 Valley Road, Green City",
      "contact": "+1 987-654-3210",
    },
    // يمكن إضافة المزيد من المستشفيات هنا
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hospitals",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
      ),

      body: ListView.builder(
        itemCount: hospitals.length,
        itemBuilder: (context, index) {
          final hospital = hospitals[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(hospital["image"]!),
              ),
              title: Text(hospital["name"]!),
              subtitle: Text(hospital["address"]!),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HospitalDetails(hospital: hospital),
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
