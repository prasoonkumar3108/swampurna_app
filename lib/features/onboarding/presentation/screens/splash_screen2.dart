import 'package:flutter/material.dart';
import 'package:my_app/features/onboarding/presentation/screens/privacy_policy_screen.dart';

class SplashScreen2 extends StatelessWidget {
  const SplashScreen2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFB9E5E8),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.02),
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
                            SizedBox(height: screenHeight * 0.02),
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

                      SizedBox(height: screenHeight * 0.04),

                      // Dynamic Grid Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // Calculate responsive dimensions
                            double availableWidth = constraints.maxWidth;
                            double crossAxisSpacing = 15;
                            double cardWidth =
                                (availableWidth - crossAxisSpacing) / 2;
                            double iconSize =
                                cardWidth * 0.8; // 80% of card width for icon

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 4,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: crossAxisSpacing,
                                    mainAxisSpacing: 20,
                                    childAspectRatio:
                                        cardWidth /
                                        (iconSize + 80), // Dynamic aspect ratio
                                  ),
                              itemBuilder: (context, index) {
                                return _buildFeatureCard(index, iconSize);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Fixed Bottom Button
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: screenHeight * 0.04,
                  top: screenHeight * 0.01,
                ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(int index, double iconSize) {
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
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon Container - Responsive sizing
        Flexible(
          child: Container(
            height: iconSize,
            width: iconSize,
            decoration: BoxDecoration(
              color: features[index]['color'],
              borderRadius: BorderRadius.circular(18),
            ),
            padding: EdgeInsets.all(iconSize * 0.15), // Responsive padding
            child: Image.asset(features[index]['img'], fit: BoxFit.contain),
          ),
        ),

        SizedBox(height: iconSize * 0.1), // Responsive spacing
        // Text with overflow handling
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              features[index]['text'],
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.2,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
