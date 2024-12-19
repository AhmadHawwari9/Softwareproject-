import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  final String recipientId;

  HistoryPage({required this.recipientId});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> medicalReports = [];

  @override
  void initState() {
    super.initState();
    // Call the API when the page is loaded
    showHistory(widget.recipientId);
  }

  // Function to fetch medical reports based on user id (recipientId)
  Future<void> showHistory(String userId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3001/History/$userId'),
    );

    if (response.statusCode == 200) {
      // If the server returns a successful response, parse the data
      setState(() {
        medicalReports = json.decode(response.body);
      });
    } else {
      // If the server doesn't return a successful response, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data')),
      );
    }
  }

  // Function to fetch data for a specific column (like HDL, BloodPressure, etc.)
  List<dynamic> getColumnData(String column) {
    return medicalReports
        .map((report) => {'Date': report['Date'], column: report[column]})
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical History',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
      ),
      body: SingleChildScrollView( // Enable vertical scrolling
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding for the whole screen
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title for the section
              Text(
                'select what history do you want to see',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              // Add Buttons to Navigate to Detail Pages, with better styling
              _buildStyledButton(
                  context,
                  'Heartrate',
                  'Heartrate',
                  getColumnData('Heartrate')
              ),
              SizedBox(height: 12),
              _buildStyledButton(
                  context,
                  'Fasting Blood Sugar',
                  'FastingBloodSugar',
                  getColumnData('FastingBloodSugar')
              ),
              SizedBox(height: 12),
              _buildStyledButton(
                  context,
                  'Haemoglobin',
                  'Haemoglobin',
                  getColumnData('Haemoglobin')
              ),
              SizedBox(height: 12),
              _buildStyledButton(
                  context,
                  'WBC',
                  'whitebloodcells',
                  getColumnData('whitebloodcells')
              ),
              SizedBox(height: 12),
              _buildStyledButton(
                  context,
                  'Blood Pressure',
                  'Bloodpressure',
                  getColumnData('Bloodpressure')
              ),
              SizedBox(height: 12),
              _buildStyledButton(
                  context,
                  'HDL',
                  'HDL',
                  getColumnData('HDL')
              ),
              SizedBox(height: 12),
              _buildStyledButton(
                  context,
                  'LDL',
                  'LDL',
                  getColumnData('LDL')
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build a styled button
  Widget _buildStyledButton(
      BuildContext context,
      String label,
      String title,
      List<dynamic> data
      ) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(
                title: title,
                data: data,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}



class DetailPage extends StatelessWidget {
  final String title;
  final List<dynamic> data;

  DetailPage({required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    // Sort the data by date
    data.sort((a, b) {
      DateTime dateA = _parseDate(a['Date']);
      DateTime dateB = _parseDate(b['Date']);
      return dateA.compareTo(dateB);
    });

    // Group data by month and year
    Map<int, Map<int, List<dynamic>>> groupedData = {};
    for (var item in data) {
      DateTime date = _parseDate(item['Date']);
      int year = date.year;
      int month = date.month;

      if (!groupedData.containsKey(year)) {
        groupedData[year] = {};
      }
      if (!groupedData[year]!.containsKey(month)) {
        groupedData[year]![month] = [];
      }
      groupedData[year]![month]!.add(item);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$title History',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        elevation: 4,
        iconTheme: IconThemeData(
          color: Colors.white, // This makes the back arrow white
        ),
      ),
      body: ListView.builder(
        itemCount: groupedData.length,
        itemBuilder: (context, yearIndex) {
          int year = groupedData.keys.toList()[yearIndex];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Year $year',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 10),
                ...groupedData[year]!.keys.toList().map((month) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getMonthName(month),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(height: 8),
                      ...groupedData[year]![month]!.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Card(
                            elevation: 8,
                            shadowColor: Colors.grey.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              title: Text(
                                'Date: ${item['Date']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              subtitle: Text(
                                '$title: ${item[title]}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  DateTime _parseDate(String dateString) {
    // Convert DD/MM/YYYY to YYYY-MM-DD format
    List<String> parts = dateString.split('/');
    String formattedDate = '${parts[2]}-${parts[1]}-${parts[0]}';
    return DateTime.parse(formattedDate);
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }
}

