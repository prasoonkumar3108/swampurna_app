import 'package:flutter/material.dart';
// IMPORTANT: Replace 'my_app' with your actual project name from pubspec.yaml
import 'package:my_app/features/auth/presentation/screens/menstrual_journey_screen.dart';

class TestimonialScreen extends StatelessWidget {
  const TestimonialScreen({super.key});

  final List<Map<String, String>> reviews = const [
    {
      "name": "Annie",
      "text":
          "Best period tracker ever, with help of this tracker, I am pregnant",
    },
    {
      "name": "Annie",
      "text":
          "Best period tracker ever, with help of this tracker, I am pregnant",
    },
    {
      "name": "Annie",
      "text":
          "Best period tracker ever, with help of this tracker, I am pregnant",
    },
    {
      "name": "Annie",
      "text":
          "Best period tracker ever, with help of this tracker, I am pregnant",
    },
  ];

  @override
  Widget build(BuildContext context) {
    const Color _bgColor = Color(0xFFD1EDF2);

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              "After a long survey, What\nour user say !",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2E3192),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  bool isRightAligned = index % 2 != 0;
                  if (index == 2) {
                    return Column(
                      children: [
                        _buildStarRating(context),
                        _buildReviewBubble(reviews[index], isRightAligned),
                      ],
                    );
                  }
                  return _buildReviewBubble(reviews[index], isRightAligned);
                },
              ),
            ),
            _buildNextButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewBubble(Map<String, String> review, bool isRight) {
    return Align(
      alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        constraints: const BoxConstraints(maxWidth: 270),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/whiteCircle.png'),
            fit: BoxFit.fill,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(35, 45, 35, 45),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "“${review['text']}”",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF2E3192),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              review['name']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3192),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/twigr.png', width: 40),
          const SizedBox(width: 10),
          Row(
            children: List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Image.asset('assets/images/star.png', width: 22),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Image.asset('assets/images/twigl.png', width: 40),
        ],
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: SizedBox(
        width: 250,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF252876),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {
            // FIXED: Using MaterialPageRoute without 'const' if issues persist,
            // but the import fix is the real key here.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MenstrualJourneyScreen(),
              ),
            );
          },
          child: const Text(
            "Next",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
