import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/models/period_setup_request.dart';
import 'package:my_app/features/auth/models/onboarding_data.dart';
import '../../../auth/presentation/screens/tracker_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final OnboardingData? onboardingData;

  const OnboardingScreen({super.key, this.onboardingData});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isLoading = false;

  Future<void> _navigateToNext() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();

      // Prepare the request with data (demonstrating safe defaults for journey completion)
      final request = PeriodSetupRequest(
        lastPeriodStartDate: widget.onboardingData?.lastPeriodDate,
        hasNoIdea: widget.onboardingData?.hasNoIdea ?? false,
        periodLengthDays: widget.onboardingData?.periodDuration ?? 8,
        cycleLengthDays: widget.onboardingData?.cycleLength ?? 28,
      );

      // Debug log the exact payload being sent
      final payload = request.toJson();
      debugPrint('FINAL PERIOD SETUP PAYLOAD');
      debugPrint(jsonEncode(payload));

      final response = await authService.setupPeriodTracker(request);

      if (mounted) {
        if (response.success) {
          // Navigate to TrackerScreen on success
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TrackerScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.error ?? 'Setup failed. Please try again.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Onboarding setup error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5F3), // Mint/Cyan background
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Section
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: const Center(
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
                ),

                // Middle Section - Center content with constrained height
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image in White Full-Width Container (Strip)
                        Container(
                          width: double.infinity,
                          color: Colors.white,
                          child: Image.asset(
                            'assets/images/smc.png',
                            height:
                                MediaQuery.of(context).size.height *
                                0.4, // Back to 40% for proper visibility
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Image asset error: $error');
                              return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                color: Colors.white,
                                child: const Center(
                                  child: Text(
                                    "Stages of\nMenstrual Cycle",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A4B),
                                    ),
                                  ),
                                ),
                              );
                            },
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
                      ],
                    ),
                  ),
                ),

                // Bottom Section - Fixed width button
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 40,
                  ), // Proper bottom padding
                  child: Center(
                    child: SizedBox(
                      width: 200, // Fixed width as requested
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _navigateToNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A4B), // Navy Blue
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
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
            );
          },
        ),
      ),
    );
  }
}
