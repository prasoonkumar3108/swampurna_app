import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- STEP 1: FIX THE IMPORT ---
// Agar TrackerScreen isi folder mein hai:
import 'tracker_screen.dart';
// Agar nahi mil rahi, toh is line ko delete karke 'TrackerScreen()' par light bulb click karke auto-import karein.

class MenstrualJourneyScreen extends StatelessWidget {
  const MenstrualJourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFD1EDF2);
    const Color primaryTextColor = Color(0xFF2E3192);
    const Color buttonColor = Color(0xFF252876);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                const SizedBox(height: 40),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Let's begin our journey!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/images/stage.png',
                      width: constraints.maxWidth * 0.85,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Next we'll look at your cycle\nand fertility",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: SizedBox(
                    width: 220,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        // --- STEP 2: REMOVED CONST ---
                        // 'const' hata diya gaya hai navigation se
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrackerScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
