import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'onboarding_screen.dart'; // Aapki next screen
import 'splash_screen2.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _butterflyController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Butterfly animation controller (for screen 3)
    _butterflyController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Logic to change page every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < 3) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } else {
        _timer?.cancel();
        _navigateToNext();
      }
    });
  }

  void _navigateToNext() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SplashScreen2(),
        ), // Change to your next screen
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _butterflyController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(
        0xFFD1EDF2,
      ), // Light blue background from screenshots
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable manual swipe
        children: [
          _buildScreen1(),
          _buildScreen2(),
          _buildScreen3(),
          _buildScreen4(),
        ],
      ),
    );
  }

  // 1. Mask Screen
  Widget _buildScreen1() {
    return Center(
      child: Image.asset(
        'assets/images/mask.png',
        width: 250,
        fit: BoxFit.contain,
      ),
    );
  }

  // 2. Logo + SWAMPURNA Text
  Widget _buildScreen2() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/splogo.png', width: 80),
          const SizedBox(width: 10),
          const Text(
            'SWAMPURNA',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2E3192), // Dark blue text
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Animated Butterfly
  Widget _buildScreen3() {
    return Center(
      child: AnimatedBuilder(
        animation: _butterflyController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_butterflyController.value * 0.1), // Subtle pulsing
            child: child,
          );
        },
        child: Image.asset(
          'assets/images/butterfly.png',
          width: 300,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // 4. Final Text Screen
  Widget _buildScreen4() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/splogo.png', width: 100),
          const SizedBox(height: 50),
          const Text(
            'Empower Your Cycle\nEmpower Yourself',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3192),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 60),
          const Text(
            'Based on survey of 6000 people in India, who recommended apps for period and cycle tracking, SWAMPURNA 2025',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF2E3192),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
