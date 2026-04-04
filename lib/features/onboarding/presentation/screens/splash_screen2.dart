import 'package:flutter/material.dart';
import 'package:my_app/features/onboarding/presentation/screens/privacy_policy_screen.dart';

class SplashScreen2 extends StatelessWidget {
  const SplashScreen2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // FIGMA PROPORTIONS:
    // Icon boxes are roughly 38% of screen width.
    // Total card height (Icon + Text) should be fixed to avoid gaps.
    double boxSize = screenWidth * 0.38;
    double cardHeight = boxSize + 65; // Icon box + spacing + 3-4 lines of text

    return Scaffold(
      backgroundColor: const Color(0xFFB9E5E8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.05),

                    // Header Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const Text(
                            "Your Health, Your Control",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "The more you track,\nthe more you know",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1A237E).withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // GRID SECTION - Using mainAxisExtent to KILL the extra gap
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing:
                              0, // No extra spacing, managed by card height
                          mainAxisExtent:
                              cardHeight, // Fixes the row height perfectly
                        ),
                        itemBuilder: (context, index) {
                          return _getFeatureData(index, boxSize);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Next Button
            Padding(
              padding: const EdgeInsets.only(bottom: 30, top: 10),
              child: SizedBox(
                width: 120,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
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
          ],
        ),
      ),
    );
  }

  Widget _getFeatureData(int index, double boxSize) {
    final List<Map<String, dynamic>> features = [
      {
        'img': 'assets/images/guide.png',
        'color': const Color(0xFFF27121),
        'text': "Welcome to SWAMPURNA, your guide to a healthier cycle.",
      },
      {
        'img': 'assets/images/cal.png',
        'color': const Color(0xFF00897B),
        'text': "Easily log your symptoms and track your cycle phases.",
      },
      {
        'img': 'assets/images/insight.png',
        'color': const Color(0xFF5C6BC0),
        'text': "Receive personalized insights and predictions.",
      },
      {
        'img': 'assets/images/secure.png',
        'color': const Color(0xFFFFD54F),
        'text': "Your data is secure and personalized just for you.",
      },
    ];

    return Column(
      children: [
        Container(
          height: boxSize,
          width: boxSize,
          decoration: BoxDecoration(
            color: features[index]['color'],
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(18),
          child: Image.asset(features[index]['img'], fit: BoxFit.contain),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            features[index]['text'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5, // Balanced font size
              height: 1.2,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
        ),
      ],
    );
  }
}
