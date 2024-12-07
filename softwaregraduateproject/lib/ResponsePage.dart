import 'package:flutter/material.dart';
import 'dart:convert';

class ResponsePage extends StatelessWidget {
  final String responseText;

  ResponsePage({required this.responseText});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> responseMap = {};

    try {
      // Attempt to parse the response text as JSON
      responseMap = json.decode(responseText);
    } catch (e) {
      // If JSON parsing fails, show the raw response as plain text
      responseMap = {};
    }

    // Prepare the formatted response
    List<Widget> healthCards;

    if (responseMap.isNotEmpty && responseMap.containsKey('data')) {
      // Extract the 'data' field and generate health cards
      var data = responseMap['data'];
      healthCards = _buildHealthCards(data);
    } else {
      // If response is not in the expected format, show the raw text
      healthCards = [
        _buildHealthCard('Error', responseText, '❌', '😞', 'Unable to parse the response'),
      ];
    }

    // Adding the styled General Tips section
    healthCards.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Card(
          color: Colors.lightBlueAccent.shade100,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tips_and_updates, color: Colors.blueAccent, size: 30),
                    SizedBox(width: 8),
                    Text(
                      'General Health Tips',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.blueAccent),
                SizedBox(height: 8),
                _buildTipRow('💧', 'Drink plenty of water to stay hydrated.'),
                _buildTipRow('🏃', 'Exercise regularly to maintain health.'),
                _buildTipRow('🥗', 'Eat a balanced diet rich in fruits and veggies.'),
                _buildTipRow('🛌', 'Get 7-8 hours of quality sleep.'),
                _buildTipRow('🚭', 'Avoid smoking and limit alcohol intake.'),
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis Result'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: healthCards,
        ),
      ),
    );
  }

  // Helper method to build rows for tips
  Widget _buildTipRow(String emoji, String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // Function to dynamically build health cards with tips
  List<Widget> _buildHealthCards(Map<String, dynamic> data) {
    // Define the health parameters with their labels, emojis, evaluation functions, and tips
    List<Map<String, dynamic>> healthParameters = [
      {
        'label': 'Heart Rate',
        'key': 'heartRate',
        'emoji': '❤️',
        'evaluation': (dynamic value) =>
        value != null && value.toString().toLowerCase() == 'normal' ? '😊' : '😞',
        'tip': (dynamic value) =>
        value != null && value.toString().toLowerCase() == 'normal'
            ? 'Keep a healthy lifestyle to maintain a normal heart rate.'
            : 'A high or low heart rate may require medical attention.',
      },
      {
        'label': 'Fasting Blood Sugar',
        'key': 'fastingBloodSugar',
        'emoji': '🍭',
        'evaluation': (dynamic value) =>
        value != null && value.toString().toLowerCase() == 'normal' ? '😊' : '😞',
        'tip': (dynamic value) =>
        value != null && value.toString().toLowerCase() == 'normal'
            ? 'Maintaining a balanced diet can help keep your blood sugar levels normal.'
            : 'High fasting blood sugar could indicate diabetes. Please consult a doctor.',
      },
      {
        'label': 'Haemoglobin',
        'key': 'haemoglobin',
        'emoji': '🩸',
        'evaluation': (dynamic value) =>
        value != null && value.toString().toLowerCase() == 'normal' ? '😊' : '😞',
        'tip': (dynamic value) =>
        value != null && value.toString().toLowerCase() == 'normal'
            ? 'Good haemoglobin levels are important for oxygen transport in your body.'
            : 'Low haemoglobin may signal iron or vitamin deficiency. Consult your Healthcare for guidance.',
      },
      {
        'label': 'White Blood Cells',
        'key': 'whiteBloodCells',
        'emoji': '🧬',
        'evaluation': (dynamic value) =>
        value != null && value.toString().toLowerCase() == 'normal' ? '😊' : '😞',
        'tip': (dynamic value) =>
        value != null && value.toString().toLowerCase() == 'normal'
            ? 'Normal white blood cell count is essential for immune function.'
            : 'An abnormal white blood cell count could indicate infection or immune issues.',
      },
      {
        'label': 'Blood Pressure',
        'key': 'bloodPressure',
        'emoji': '🩺',
        'evaluation': (dynamic value) =>
        value != null && value.toString().toLowerCase() == 'normal' ? '😊' : '😞',
        'tip': (dynamic value) =>
        value != null && value.toString().toLowerCase() == 'normal'
            ? 'Maintain a healthy blood pressure by staying active and reducing stress.'
            : 'High blood pressure can lead to serious health conditions. Consult your doctor.',
      },
      {
        'label': 'HDL',
        'key': 'hdl',
        'emoji': '💪',
        'evaluation': (dynamic value) =>
        value != null && value.toString().toLowerCase() == 'normal' ? '😊' : '😞',
        'tip': (dynamic value) =>
        value != null && value.toString().toLowerCase() == 'normal'
            ? 'HDL is known as "good" cholesterol. Keep it high by eating healthy fats.'
            : 'Low HDL levels may increase the risk of heart disease.',
      },
      {
        'label': 'LDL',
        'key': 'ldl',
        'emoji': '⚖️',
        'evaluation': (dynamic value) =>
        value != null && value.toString().toLowerCase() == 'normal' ? '😊' : '😞',
        'tip': (dynamic value) =>
        value != null && value.toString().toLowerCase() == 'normal'
            ? 'Low LDL ("bad" cholesterol) is beneficial for heart health.'
            : 'High LDL levels may lead to plaque buildup in arteries. Consider reducing saturated fats in your diet.',
      },
    ];

    // Generate the cards dynamically based on the health parameters
    return healthParameters.map((param) {
      String label = param['label'];
      String key = param['key'];
      String emoji = param['emoji'];
      Function evaluation = param['evaluation'];
      Function tip = param['tip'];

      dynamic value = data[key];
      String resultEmoji = evaluation(value);
      String resultTip = tip(value);

      return _buildHealthCard(label, value, emoji, resultEmoji, resultTip);
    }).toList();
  }

  // Helper method to build a card for each health parameter with an emoji and tip
  Widget _buildHealthCard(
      String label,
      dynamic value,
      String emoji,
      String resultEmoji,
      String tip,
      ) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value != null ? value.toString() : 'N/A',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    tip,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              resultEmoji,
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
