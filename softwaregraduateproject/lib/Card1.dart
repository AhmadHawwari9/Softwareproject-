import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Card1Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Keep Your Heart Healthy"),
        backgroundColor: Colors.indigoAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Display the image
            Center(
              child: Image.asset(
                'imgs/istockphoto-1266230179-612x612.jpg',
                height: 250, // Adjust image height as needed
                fit: BoxFit.cover, // Fit the image nicely
              ),
            ),
            SizedBox(height: 20),
            // Title for the article
            Text(
              "Overview",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),

            // Article content
            Text(
              "Heart disease is the leading cause of death for both men and women in the United States. Take steps today to lower your risk of heart disease.\n\n"
                  "To help prevent heart disease, you can:\n\n"
                  "• Eat a heart-healthy diet\n"
                  "• Get active\n"
                  "• Stay at a healthy weight\n"
                  "• Quit smoking and stay away from secondhand smoke\n"
                  "• Control your cholesterol, blood glucose (sugar), and blood pressure\n"
                  "• Drink alcohol only in moderation\n"
                  "• Manage stress\n"
                  "• Get enough sleep\n\n"
                  "Am I at risk for heart disease?\n\n"
                  "Anyone can get heart disease, but you’re at higher risk if you:\n\n"
                  "• Have high cholesterol, high blood pressure, or diabetes\n"
                  "• Smoke\n"
                  "• Have overweight or obesity\n"
                  "• Don't get enough physical activity\n"
                  "• Don't eat a healthy diet\n"
                  "• Had a condition called preeclampsia during pregnancy\n\n"
                  "Your age and family history also affect your risk for heart disease. Your risk is higher if:\n\n"
                  "• You’re a woman over age 55\n"
                  "• You’re a man over age 45\n"
                  "• Your father or brother had heart disease before age 55\n"
                  "• Your mother or sister had heart disease before age 65\n\n"
                  "But the good news is there's a lot you can do to prevent heart disease.\n\n"
                  "What Is Heart Disease?\n\n"
                  "When people talk about heart disease, they’re usually talking about coronary heart disease (CHD). It’s also sometimes called coronary artery disease (CAD). This is the most common type of heart disease.\n\n"
                  "When someone has CHD, the coronary arteries (tubes) that take blood to the heart are narrow or blocked, which makes it hard for oxygen-rich blood to get to the heart. This happens when cholesterol and fatty material, called plaque, build up inside the arteries.\n\n"
                  "Several things can lead to plaque building up inside your arteries, including:\n\n"
                  "• Too much cholesterol in the blood\n"
                  "• High blood pressure\n"
                  "• Smoking\n"
                  "• Too much sugar in the blood because of diabetes\n\n"
                  "When plaque blocks an artery, it’s hard for blood to flow to the heart. A blocked artery can cause chest pain or a heart attack. Learn more about CHD.",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
