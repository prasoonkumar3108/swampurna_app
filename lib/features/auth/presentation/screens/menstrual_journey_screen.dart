import 'package:flutter/material.dart';
import 'tracker_screen.dart';

class MenstrualJourneyScreen extends StatefulWidget {
  const MenstrualJourneyScreen({super.key});

  @override
  State<MenstrualJourneyScreen> createState() => _MenstrualJourneyScreenState();
}

class _MenstrualJourneyScreenState extends State<MenstrualJourneyScreen> {
  void _navigateToNext() {
    if (!mounted) return;

    // Navigate to TrackerScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TrackerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5F3), // Light mint/cyan background
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Top padding
          const SizedBox(height: 60),

          // Top Text
          const Center(
            child: Text(
              "Let's begin our journey!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A4B), // Navy Blue
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 40),

          // The Core Image - White container with image
          Container(
            width: double.infinity,
            color: Colors.white,
            child: Image.asset(
              'assets/images/smc.png',
              height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 40),

          // Sub-text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Next we'll look at your cycle and fertility",
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF1A1A4B), // Navy Blue
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(),

          // Next Button - Fixed width, centered
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Center(
              child: SizedBox(
                width: 220, // Fixed width as requested
                child: ElevatedButton(
                  onPressed: _navigateToNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A4B), // Navy Blue
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
