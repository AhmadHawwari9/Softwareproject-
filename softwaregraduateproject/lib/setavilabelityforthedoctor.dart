import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AvailabilityPage extends StatefulWidget {
  final String savedToken;

  AvailabilityPage(this.savedToken);

  @override
  _AvailabilityPageState createState() => _AvailabilityPageState();
}

class _AvailabilityPageState extends State<AvailabilityPage> {
  List<String> daysOfWeek = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];
  List<bool> selectedDays = List.filled(7, false);
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  // Helper function to convert TimeOfDay to 24-hour format
  String formatTimeTo24Hour(TimeOfDay time) {
    final now = DateTime.now();
    final formattedTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return "${formattedTime.hour.toString().padLeft(2, '0')}:${formattedTime.minute.toString().padLeft(2, '0')}";
  }

  Future<void> selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  Future<void> saveAvailability() async {
    // Collect selected days and times
    String selectedDaysString = daysOfWeek
        .asMap()
        .entries
        .where((entry) => selectedDays[entry.key])
        .map((entry) => entry.value)
        .join(", ");
    String startTimeString = startTime != null ? formatTimeTo24Hour(startTime!) : '';
    String endTimeString = endTime != null ? formatTimeTo24Hour(endTime!) : '';

    // Make sure the data is valid
    if (selectedDaysString.isEmpty || startTimeString.isEmpty || endTimeString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select days and time range.")));
      return;
    }

    // Prepare the request body
    Map<String, dynamic> body = {
      'days': selectedDaysString,
      'startTime': startTimeString,
      'endTime': endTimeString,
    };

    // Send the data to the server
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3001/setAvailability'),  // Replace with your actual API URL
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.savedToken}',  // Pass the token in the header
      },
      body: json.encode(body),
    );

    // Handle the response
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Availability saved successfully!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving availability")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Set Availability", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select the time that you can receive reservations at:",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            SizedBox(height: 20),
            Text(
              "Select Days:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...daysOfWeek.asMap().entries.map((entry) {
              int index = entry.key;
              String day = entry.value;
              return CheckboxListTile(
                title: Text(day),
                value: selectedDays[index],
                activeColor: Colors.teal,  // This sets the color when the checkbox is selected
                onChanged: (bool? value) {
                  setState(() {
                    selectedDays[index] = value ?? false;
                  });
                },
              );
            }).toList(),
            SizedBox(height: 20),
            Text(
              "Select Time Range:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => selectTime(context, true),
                  child: Text(
                    startTime == null ? "Start Time" : formatTimeTo24Hour(startTime!),
                    style: TextStyle(fontSize: 16, color: Colors.teal),
                  ),
                ),
                Text(
                  "to",
                  style: TextStyle(fontSize: 16),
                ),
                TextButton(
                  onPressed: () => selectTime(context, false),
                  child: Text(
                    endTime == null ? "End Time" : formatTimeTo24Hour(endTime!),
                    style: TextStyle(fontSize: 16, color: Colors.teal),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: saveAvailability,
                child: Text(
                  "Save Availability",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20), // Adds space below the button
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, String>>> fetchAvailability() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3001/getAvailability'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.savedToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Explicitly cast the map to Map<String, String>
        return data.map((item) => {
          'days': item['days'] as String,
          'start_time': item['start_time'] as String,
          'end_time': item['end_time'] as String,
        }).toList();
      } else {
        throw Exception('Failed to load availability');
      }
    } catch (e) {
      print('Error fetching availability: $e');
      return [];
    }
  }

}
