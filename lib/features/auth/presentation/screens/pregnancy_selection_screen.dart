import 'package:flutter/material.dart';
import 'period_calendar_screen.dart';
import '../models/onboarding_data.dart';
import '../../../../core/services/auth_service.dart';

class PregnancySelectionScreen extends StatefulWidget {
  final int selectedBirthYear;
  final String onboardingSource;
  final String usingFor;

  const PregnancySelectionScreen({
    super.key,
    required this.selectedBirthYear,
    required this.onboardingSource,
    required this.usingFor,
  });

  @override
  State<PregnancySelectionScreen> createState() =>
      _PregnancySelectionScreenState();
}

class _PregnancySelectionScreenState extends State<PregnancySelectionScreen> {
  String? _selectedStatus;
  bool _isLoading = false;

  // Map button text to backend values
  String _mapPregnancyStatus(String buttonText) {
    if (buttonText == "Yes, I am") {
      return "yes_i_am"; // Keep existing working logic for this case
    } else {
      // Convert to lowercase and replace spaces/commas with underscores
      return buttonText
          .toLowerCase()
          .replaceAll(', ', '_')
          .replaceAll(' ', '_');
    }
  }

  // Handle option selection
  void _selectOption(String option) {
    setState(() {
      _selectedStatus = option;
    });
    print("SELECTED OPTION: $option");
  }

  // Skip onboarding - direct navigation without API
  void _skipOnboarding() {
    final updatedData = OnboardingData(
      email: "",
      otp: "",
      source: widget.onboardingSource,
      birthYear: widget.selectedBirthYear,
      isPregnant: false,
    );

    // Use pushReplacement to prevent back navigation
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PeriodCalendarScreen(onboardingData: updatedData),
      ),
    );
  }

  // Submit onboarding data
  Future<void> _submitOnboarding() async {
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an option to continue.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Map pregnancy status
      final pregnancyStatus = _mapPregnancyStatus(_selectedStatus!);

      // Fix onboarding source - default to valid backend value
      final fixedOnboardingSource =
          (widget.onboardingSource.isNotEmpty &&
              widget.onboardingSource != "unknown")
          ? widget.onboardingSource
          : "friends_or_family";

      // Create API payload
      final apiBody = {
        "onboarding_source": fixedOnboardingSource,
        "birth_year": widget.selectedBirthYear,
        "pregnancy_status": pregnancyStatus,
        "using_for": widget.usingFor,
      };

      print("FINAL API BODY: $apiBody");

      // Call API
      final response = await AuthService().submitOnboardingData(apiBody);

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE DATA: ${response.data}");
      print("RESPONSE ERROR: ${response.error}");
      print("RESPONSE SUCCESS: ${response.success}");

      // SUCCESS CONDITION
      // Backend returns:
      // {
      //   "message": "Onboarding details saved",
      //   "data": {...}
      // }

      final bool isApiSuccess =
          response.success == true ||
          response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.data != null;

      if (isApiSuccess) {
        print("ONBOARDING API SUCCESS");

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        final updatedData = OnboardingData(
          email: "",
          otp: "",
          source: fixedOnboardingSource,
          birthYear: widget.selectedBirthYear,
          isPregnant: pregnancyStatus == "yes_i_am",
        );

        // FORCE NAVIGATION
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PeriodCalendarScreen(onboardingData: updatedData),
          ),
          (route) => false,
        );

        return;
      }

      // ERROR CASE ONLY
      String errorMessage = "Request failed";

      if (response.error != null &&
          response.error.toString().trim().isNotEmpty) {
        errorMessage = response.error.toString();
      }

      print("ONBOARDING API FAILED: $errorMessage");

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      if (!mounted) return;
      // Clean error logging
      print("API Error: ${e.toString()}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));

      // Reset loading state for catch case
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFD9F2F2),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Back Button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    padding: const EdgeInsets.all(20),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF1A1F71),
                    ),
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
                    color: Color(0xFF1A1F71),
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

                const Spacer(flex: 1),

                // Selection Buttons
                _buildOption(context, "Yes, I am", screenWidth),
                _buildOption(context, "No, but I want to be", screenWidth),
                _buildOption(
                  context,
                  "No, I am here to understand my body",
                  screenWidth,
                ),

                const Spacer(flex: 2), // Space for fixed bottom buttons
              ],
            ),

            // Fixed bottom buttons
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Color(0xFFD9F2F2)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1F71),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Submitting...'),
                                ],
                              )
                            : const Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Skip button - less prominent
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: TextButton(
                        onPressed: _isLoading ? null : _skipOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor: _isLoading
                              ? Colors.grey
                              : const Color(0xFF1A1F71),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String text, double screenWidth) {
    final isSelected = _selectedStatus == text;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? const Color(0xFFD0D0E0)
                : const Color(0xFFEFE7E7),
            foregroundColor: const Color(0xFF1A1F71),
            elevation: 0,
            side: isSelected
                ? const BorderSide(color: Color(0xFF1A1F71), width: 2)
                : BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _selectOption(text),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
