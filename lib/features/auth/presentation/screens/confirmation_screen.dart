import 'package:flutter/material.dart';
import 'source_selection_screen.dart';

class ConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> onboardingData;

  const ConfirmationScreen({super.key, required this.onboardingData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFE0F7F9,
      ), // Light cyan/pale blue background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Header text
              const Text(
                'Are you using SWAMPURNA for yourself?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2671), // Dark navy blue
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // Options cards
              Column(
                children: [
                  // Yes option
                  _buildOptionCard(
                    text: 'Yes, It\'s for myself.',
                    onTap: () {
                      print('Selected: Yes - Using for myself');
                      // Update onboarding data with source
                      final updatedData = Map<String, dynamic>.from(
                        onboardingData,
                      );
                      updatedData['source'] = 'self';

                      // Navigate to SourceSelectionScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SourceSelectionScreen(
                            onboardingData: updatedData,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // No option
                  _buildOptionCard(
                    text: 'No, It\'s for my partner.',
                    onTap: () {
                      print('Selected: No - Using for partner');
                      // Update onboarding data with source
                      final updatedData = Map<String, dynamic>.from(
                        onboardingData,
                      );
                      updatedData['source'] = 'partner';

                      // Navigate to SourceSelectionScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SourceSelectionScreen(
                            onboardingData: updatedData,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F1F1), // Very light pink/off-white
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Align(
          alignment: Alignment.centerLeft, // Left-aligned text
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1D2671), // Dark navy blue text
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
