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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medical History'),backgroundColor: Colors.blue,),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // For horizontal scrolling
        child: Card(
          elevation: 4, // Card shadow effect
          child: Column(
            children: [
              Container(
                height: 186,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Vertical scrolling for rows
                  child: DataTableTheme(
                    data: DataTableThemeData(
                      headingRowColor: MaterialStateProperty.all(Colors.blue), // Header background color
                      headingTextStyle: TextStyle(
                        color: Colors.white, // Header text color
                        fontWeight: FontWeight.bold,
                      ),
                      dataRowColor: MaterialStateProperty.all(Colors.lightBlue.shade50), // Row background color
                      dataTextStyle: TextStyle(
                        color: Colors.black87, // Row text color
                      ),
                    ),
                    child: DataTable(
                      headingRowHeight: 40, // Adjust header height
                      columns: [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Heartrate')),
                        DataColumn(label: Text('Fasting Blood Sugar')),
                        DataColumn(label: Text('Haemoglobin')),
                        DataColumn(label: Text('White Blood Cells')),
                        DataColumn(label: Text('Blood Pressure')),
                        DataColumn(label: Text('HDL')),
                        DataColumn(label: Text('LDL')),
                      ],
                      rows: medicalReports.isEmpty
                          ? [
                        DataRow(cells: [
                          DataCell(Text('No data available')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                        ])
                      ]
                          : medicalReports.map<DataRow>((report) {
                        return DataRow(cells: [
                          DataCell(Text(report['Date'])),
                          DataCell(Text(report['Heartrate'])),
                          DataCell(Text(report['FastingBloodSugar'])),
                          DataCell(Text(report['Haemoglobin'])),
                          DataCell(Text(report['whitebloodcells'])),
                          DataCell(Text(report['Bloodpressure'])),
                          DataCell(Text(report['HDL'])),
                          DataCell(Text(report['LDL'])),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
