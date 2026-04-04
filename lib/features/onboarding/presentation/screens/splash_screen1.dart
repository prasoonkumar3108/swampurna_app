import 'dart:async';
import 'package:flutter/material.dart';
import 'splash_screen2.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen1(),
    ),
  );
}

class AppColors {
  static const Color background = Color(0xFFD1F2F2);
  static const Color primaryText = Color(0xFF1A237E);
  static const Color secondaryText = Color(0xFF283593);
}

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({super.key});

  @override
  State<SplashScreen1> createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen2()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Use extendBodyBehindAppBar if you have a transparent status bar
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // Physics set to NeverScrollable so it feels like a splash screen
              // but allows content to exist without cutting off
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60), // Top padding
                        // --- Logo Section ---
                        Center(
                          child: SizedBox(
                            width: constraints.maxWidth * 0.45,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                                // Fallback icon while you're setting up assets
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.auto_awesome,
                                      size: 80,
                                      color: Color(0xFFB8860B),
                                    ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // --- Main Heading ---
                        Text(
                          'Empower Your Cycle\nEmpower Yourself',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: (constraints.maxWidth * 0.075).clamp(
                              24,
                              32,
                            ),
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // --- Subtitle ---
                        Text(
                          'Based on survey of 6000 people in India, who recommended apps for period and cycle tracking, SWAMPURNA 2025',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.secondaryText.withOpacity(0.85),
                            fontSize: (constraints.maxWidth * 0.038).clamp(
                              14,
                              16,
                            ),
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),

                        // This pushes the bottom text up slightly without
                        // causing an overflow error
                        const Spacer(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


