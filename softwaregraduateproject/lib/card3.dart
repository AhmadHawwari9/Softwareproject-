import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Card3Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Brain Health Tips"),
        backgroundColor: Colors.indigoAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Image
            Image.asset('imgs/how-the-human-brain-decides-what-to-remember.jpg'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '8 Brain Health Tips for a Healthier You\n',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigoAccent,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'The brain controls thought, movement, and emotion. Use the following brain health tips to help protect it.\n\n'
                    'At 3 pounds, the brain isn’t very large, but it is a powerhouse. Those 3 pounds hold your personality and all your memories. '
                    'The brain coordinates your thoughts, emotions, and movements.\n\n'
                    'Billions of nerve cells in your brain make it all possible. Called neurons, these brain cells send information to the rest of your body. '
                    'If they aren’t working properly, your muscles may not move smoothly, and you might lose feeling in parts of your body. Your thinking could slow.\n\n'
                    'The brain doesn’t replace neurons that are damaged or destroyed. So it’s important to take care of them. Head injuries, drug use, and health conditions '
                    'like Alzheimer’s and Parkinson’s disease can cause brain cell damage or loss.\n\n'
                    'Developing brain health habits is a key way to keep your brain healthy. That includes following safety measures and keeping your brain active and engaged. '
                    'Try these brain health tips:\n\n'
                    '1. **Work up a sweat**\n'
                    'People who are physically active are more likely to keep their minds sharp. Regular physical activity also helps improve balance, flexibility, strength, energy, and mood. '
                    'Research suggests that exercise may lower the risk of developing Alzheimer’s disease.\n\n'
                    '2. **Protect your head**\n'
                    'A brain injury can have a significant long-term impact on a person’s life. To protect your brain, always wear a helmet when doing an activity where there’s a risk of head injuries.\n\n'
                    '3. **Take care of your health**\n'
                    'Some medical conditions like diabetes, heart disease, and high blood pressure can increase the risk of brain problems. Follow your healthcare professional’s directions to manage them.\n\n'
                    '4. **Meet up with friends**\n'
                    'Social interaction helps ward off depression and stress, which can worsen memory loss. Social isolation has been linked to a higher risk of cognitive decline.\n\n'
                    '5. **Get a good night’s rest**\n'
                    'Sleep is essential for brain function and memory. Aim for 7 to 9 hours of sleep each night to improve cognitive function and prevent mental decline.\n\n'
                    '6. **Make a salad**\n'
                    'Eating a healthy diet, such as the MIND diet, can help improve mental focus and slow cognitive decline. This diet includes leafy greens, berries, nuts, and fish, while limiting butter and sweets.\n\n'
                    '7. **Challenge your brain**\n'
                    'Just like physical exercise, mental activities such as crossword puzzles, reading, or learning an instrument help keep your brain sharp.\n\n'
                    '8. **Be careful with medicines and limit alcohol**\n'
                    'Substances like alcohol and drugs can interfere with brain function. Limit alcohol intake to up to one drink a day for women and two for men, and always follow medicine directions carefully.\n\n',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
