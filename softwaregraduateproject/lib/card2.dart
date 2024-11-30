import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Card2Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("8 Tips for Healthy Eating"),
        backgroundColor: Colors.indigoAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Image at the top
            Image.asset(
              'imgs/healthy-food-restaurants-640b5d1e9e8fc.png',
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '8 Tips for Healthy Eating',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigoAccent,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'These 8 practical tips cover the basics of healthy eating and can help you make healthier choices.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Main content
                  _buildTip(
                    '1. Base your meals on higher fibre starchy carbohydrates',
                    'Starchy carbohydrates should make up just over a third of the food you eat. They include potatoes, bread, rice, pasta, and cereals. Choose higher fibre or wholegrain varieties for extra health benefits.',
                    Icons.food_bank,
                  ),
                  _buildTip(
                    '2. Eat lots of fruit and veg',
                    'Eat at least 5 portions of a variety of fruit and veg every day. Fresh, frozen, canned, dried, or juiced all count towards your daily intake.',
                    Icons.local_florist,
                  ),
                  _buildTip(
                    '3. Eat more fish, including a portion of oily fish',
                    'Fish is a good source of protein and contains many vitamins and minerals. Aim for at least 2 portions of fish a week, including at least 1 portion of oily fish.',
                    Icons.restaurant,
                  ),
                  _buildTip(
                    '4. Cut down on saturated fat and sugar',
                    'Limit your intake of saturated fat to prevent health issues. Regularly consuming sugary foods increases the risk of obesity and tooth decay.',
                    Icons.local_pizza,
                  ),
                  _buildTip(
                    '5. Eat less salt: no more than 6g a day for adults',
                    'Consuming too much salt can raise blood pressure. Try reducing your salt intake to reduce the risk of heart disease or stroke.',
                    Icons.food_bank,
                  ),
                  _buildTip(
                    '6. Get active and be a healthy weight',
                    'Regular exercise helps reduce the risk of serious health conditions. Being active is key for your overall health and wellbeing.',
                    Icons.fitness_center,
                  ),
                  _buildTip(
                    '7. Do not get thirsty',
                    'Stay hydrated by drinking 6 to 8 glasses of water a day. This helps keep your body functioning at its best.',
                    Icons.local_drink,
                  ),
                  _buildTip(
                    '8. Do not skip breakfast',
                    'A healthy breakfast is important to start your day right. It provides the energy and nutrients needed for good health.',
                    Icons.breakfast_dining,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Follow these tips and make healthier choices every day!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create individual tip sections
  Widget _buildTip(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            size: 40,
            color: Colors.indigoAccent,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
