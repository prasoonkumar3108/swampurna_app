import 'package:flutter/material.dart';
// IMPORT CHECK: Ensure this file exists in your project
import 'period_calendar_screen.dart';

class PregnancySelectionScreen extends StatelessWidget {
  final Map<String, dynamic> onboardingData;

  const PregnancySelectionScreen({super.key, required this.onboardingData});

  @override
  Widget build(BuildContext context) {
    // Media query to handle dynamic padding based on screen size
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFD9F2F2), // Light teal background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
          children: [
            // Top Back Button
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                padding: const EdgeInsets.all(20),
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1F71)),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(height: 20),

            // Main Titles
            const Text(
              'Welcome to',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Color(0xFF1A1F71), // Deep Navy
              ),
            ),
            const Text(
              'SWAMPURNA!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Color(0xFF1A1F71),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Are you pregnant?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, color: Color(0xFF1A1F71)),
            ),

            const Spacer(flex: 1), // Flexible space
            // Selection Buttons
            _buildOption(context, "No, but I want to be", screenWidth),
            _buildOption(
              context,
              "No, I am here to understand my body",
              screenWidth,
            ),
            _buildOption(context, "Yes, I am", screenWidth),

            const Spacer(flex: 2), // Keeps buttons in the upper-middle area
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String text, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: SizedBox(
        width: double.infinity, // Ensures button takes full available width
        height: 60, // Fixed height for consistency
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEFE7E7), // Matching button color
            foregroundColor: const Color(0xFF1A1F71), // Text color
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            // Determine pregnancy status based on selection
            bool? isPregnant;
            if (text == "Yes, I am") {
              isPregnant = true;
            } else if (text.contains("No")) {
              isPregnant = false;
            } else {
              isPregnant = null; // For other options
            }

            // Update onboarding data with pregnancy status
            final updatedData = Map<String, dynamic>.from(onboardingData);
            updatedData['isPregnant'] = isPregnant;

            // Navigation with proper Context
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PeriodCalendarScreen(onboardingData: updatedData),
              ),
            );
          },
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
