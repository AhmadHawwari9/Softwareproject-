import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:syncfusion_flutter_charts/charts.dart';

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
    // Dynamically set base URL depending on whether the app is running in the web or mobile environment
    final String baseUrl = kIsWeb
        ? 'http://localhost:3001' // Web environment
        : 'http://10.0.2.2:3001'; // Mobile environment

    // Use the baseUrl and append the userId to the endpoint
    final response = await http.get(
      Uri.parse('$baseUrl/History/$userId'),
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
      List<dynamic> data,
      ) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          InkWell(
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
                '$label Details',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChartPage(
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
                  colors: [Colors.orange, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                '$label Chart',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
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

    // Group data by month and year, excluding empty months
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
        title: Text('$title History', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        elevation: 4,
        iconTheme: IconThemeData(color: Colors.white),
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
                  // Only include months that have data
                  if (groupedData[year]![month]!.isNotEmpty) {
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
                  } else {
                    return SizedBox(); // Skip empty months
                  }
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  DateTime _parseDate(String dateString) {
    try {
      List<String> parts = dateString.split('/');
      if (parts.length != 3) {
        throw FormatException("Invalid date format: $dateString");
      }
      String formattedDate = '${parts[2]}-${parts[1]}-${parts[0]}';
      return DateTime.parse(formattedDate);
    } catch (e) {
      print("Error parsing date: $dateString, Error: $e");
      return DateTime(2024, 1, 1);
    }
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }
}

class ChartData {
  final DateTime date;
  final double value;

  ChartData(this.date, this.value);
}

class ChartPage extends StatelessWidget {
  final String title;
  final List<dynamic> data;

  ChartPage({required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    // Filter data to only include items from 2024 and later
    List<ChartData> chartData = data.where((item) {
      DateTime date = _parseDate(item['Date']);
      // Only include data from 2024 and later
      return date.year >= 2024 && item[title] != null;
    }).map((item) {
      DateTime date = _parseDate(item['Date']);
      double value = double.tryParse(item[title].toString()) ?? 0.0;
      return ChartData(date, value);
    }).where((data) => data.value != 0.0).toList(); // Filter out zero values

    return Scaffold(
      appBar: AppBar(
        title: Text('$title Chart', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfCartesianChart(
          title: ChartTitle(text: '$title Over Time'),
          legend: Legend(isVisible: true),
          tooltipBehavior: TooltipBehavior(enable: true),
          primaryXAxis: DateTimeAxis(title: AxisTitle(text: 'Date')),
          primaryYAxis: NumericAxis(title: AxisTitle(text: title)),
          series: <CartesianSeries>[
            ColumnSeries<ChartData, DateTime>( // Changed to ColumnSeries
              name: title,
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.date,
              yValueMapper: (ChartData data, _) => data.value,
              color: Colors.teal, // Set the column color
              dataLabelSettings: DataLabelSettings(isVisible: true),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _parseDate(String dateString) {
    try {
      List<String> parts = dateString.split('/');
      if (parts.length != 3) {
        throw FormatException("Invalid date format: $dateString");
      }
      String formattedDate = '${parts[2]}-${parts[1]}-${parts[0]}';
      return DateTime.parse(formattedDate);
    } catch (e) {
      print("Error parsing date: $dateString, Error: $e");
      return DateTime(2024, 1, 1); // Default to 2024 if there's an error
    }
  }
}