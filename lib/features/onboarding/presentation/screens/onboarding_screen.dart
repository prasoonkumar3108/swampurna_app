import 'package:flutter/material.dart';
import '../../../auth/models/onboarding_data.dart';
import '../../../../core/services/auth_service.dart';

class OnboardingScreen extends StatefulWidget {
  final OnboardingData? onboardingData;

  const OnboardingScreen({super.key, this.onboardingData});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _selectedUsingFor;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Handle using_for selection
  void _onUsingForSelected(String value) {
    print("OPTION SELECTED: $value");

    setState(() {
      _selectedUsingFor = value;
    });
  }

  // Submit onboarding data
  void _submitOnboarding() async {
    print("SUBMIT BUTTON CLICKED");
    print("SELECTED OPTION: $_selectedUsingFor");

    // Validate selection
    if (_selectedUsingFor == null) {
      _showErrorSnackBar('Please select an option');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create complete onboarding data
      final completeOnboardingData = widget.onboardingData?.copyWith(
        usingFor: _selectedUsingFor,
      );

      if (completeOnboardingData == null) {
        print("ONBOARDING ERROR: No onboarding data available");
        _showErrorSnackBar('Missing onboarding data');
        return;
      }

      // Convert to API format
      final apiBody = completeOnboardingData.toApiMap();
      print("FINAL PAYLOAD: $apiBody");

      // Call existing API service
      final authService = AuthService();
      final response = await authService.submitOnboardingData(apiBody);

      print("ONBOARDING API RESPONSE: ${response.data}");

      if (response.success) {
        print("ONBOARDING API SUCCESS");
        _showSuccessSnackBar('Onboarding completed successfully!');

        // Navigate to next screen (existing behavior)
        _navigateToNextScreen();
      } else {
        print("ONBOARDING API ERROR: ${response.error}");
        _showErrorSnackBar(response.error ?? 'Onboarding failed');
      }
    } catch (e) {
      print("ONBOARDING API ERROR: $e");
      _showErrorSnackBar('An error occurred during onboarding');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _skipOnboarding() {
    print("SKIP BUTTON CLICKED");
    _navigateToNextScreen();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _navigateToNextScreen() {
    _showSuccessSnackBar('Onboarding completed! Ready for next step.');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header section
            const SizedBox(height: 40),
            Image.asset(
              'assets/images/onboarding3.png',
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),

            const Text(
              'How will you use SWAMPURNA?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            const Text(
              'Select your primary use case',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF5C6BC0),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            // Options list in scrollable area
            const SizedBox(height: 30),
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Options list only
                    ...[
                      'Personal cycle tracking',
                      'Planning pregnancy',
                      'Monitoring existing pregnancy',
                      'Postpartum care',
                      'Menopause management',
                      'Medical/research purposes',
                    ].map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              print("OPTION TAPPED: $option");
                              _onUsingForSelected(option);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _selectedUsingFor == option
                                    ? const Color(0xFFE3F2FD)
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedUsingFor == option
                                      ? const Color(0xFF1976D2)
                                      : const Color(0xFFE0E0E0),
                                  width: _selectedUsingFor == option ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Selection indicator
                                  if (_selectedUsingFor == option)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF1976D2),
                                      size: 20,
                                    ),
                                  if (_selectedUsingFor == option)
                                    const SizedBox(width: 8),

                                  // Option text
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _selectedUsingFor == option
                                            ? const Color(0xFF1976D2)
                                            : const Color(0xFF1A237E),
                                        fontWeight: _selectedUsingFor == option
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Submit and Skip buttons - OUTSIDE Expanded widget
            const SizedBox(height: 20),
            if (_isSubmitting) ...[
              // Loading state
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Submitting...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Skip button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _skipOnboarding,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1976D2),
                    side: const BorderSide(color: Color(0xFF1976D2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
