import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'otp_screen.dart';
import 'signup_screen.dart';
import 'login_with_pin_screen.dart';
import 'pin_screen.dart';
import '../../../../core/services/auth_service.dart';

class MobileInputScreen extends StatefulWidget {
  const MobileInputScreen({super.key});

  @override
  State<MobileInputScreen> createState() => _MobileInputScreenState();
}

class _MobileInputScreenState extends State<MobileInputScreen> {
  static const Color _primaryColor = Color(0xFF2E3192);
  static const Color _bgColor = Color(0xFFD1EDF2);

  final TextEditingController _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  // Build popup content widget for better isolation
  Widget _buildLoginMethodPopupContent(String email) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with close button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Choose Login Method',
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: _primaryColor),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Login with OTP button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close popup first
                await _sendOtpAndNavigate(email); // Then navigate
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Login with OTP',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Login with PIN button (TEMPORARILY COMMENTED OUT)
        /*
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton(
              onPressed: () async {
                Navigator.pop(context); // Close popup first

                // Check user PIN status before navigation
                setState(() {
                  _isLoading = true;
                });

                try {
                  final pinStatusResponse = await AuthService()
                      .checkUserPinStatus();

                  if (!mounted) return;

                  setState(() {
                    _isLoading = false;
                  });

                  // Extract pin_enabled from response
                  bool pinEnabled = true; // Safe fallback
                  if (pinStatusResponse.success &&
                      pinStatusResponse.data != null &&
                      pinStatusResponse.data?['user'] != null) {
                    pinEnabled =
                        pinStatusResponse.data?['user']?['pin_enabled'] ?? true;
                  }

                  debugPrint(
                    '🔐 PIN Status: ${pinEnabled ? "Enabled" : "Not Enabled"}',
                  );

                  if (pinEnabled) {
                    // CASE B: User has PIN - Navigate to LoginWithPinScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoginWithPinScreen(email: email),
                      ),
                    );
                  } else {
                    // CASE A: User hasn't set PIN - Navigate to Set PIN screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PinScreen(
                          email: email,
                          initialMode: PinMode.SET_PIN,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;

                  setState(() {
                    _isLoading = false;
                  });

                  // Fallback: Assume PIN is enabled (safe login path)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginWithPinScreen(email: email),
                    ),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _primaryColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Login with PIN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ),
          ),
          ),
        */
        const SizedBox(height: 80),
      ],
    );
  }

  // Show selection popup for login methods
  void _showLoginMethodPopup(String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Zaroori - Foolproof height control
      backgroundColor: Colors.transparent, // For rounded corners of child
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bc).viewInsets.bottom,
          ), // Dynamic padding
          child: Container(
            decoration: const BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: _buildLoginMethodPopupContent(email), // Isolated content
          ),
        );
      },
    );
  }

  // Send OTP and navigate to OTP screen
  Future<void> _sendOtpAndNavigate(String email) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final response = await authService.sendOtp(
        email: email,
        purpose: 'login',
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.success) {
          debugPrint('OTP sent successfully');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(email: email, isFromSignup: false),
            ),
          );
        } else {
          setState(() {
            _errorMessage = response.error ?? 'Failed to send OTP';
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Send OTP error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Unable to send OTP. Please check your connection and try again.';
        });
      }
    }
  }

  // Validation Logic - Show selection popup
  void _validateAndContinue() async {
    String value = _mobileController.text.trim();

    setState(() {
      _errorMessage = null;
    });

    if (value.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your email address";
      });
      return;
    }

    if (!value.contains('@') || !value.contains('.')) {
      setState(() {
        _errorMessage = "Please enter a valid email address";
      });
      return;
    }

    _showLoginMethodPopup(value);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 25.0,
              right: 25.0,
              top: 25.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 25.0,
            ),
            child: Column(
              children: [
                // 1. Skip Button
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () {
                      // Handle Skip logic
                    },
                    child: const Text(
                      '',
                      style: TextStyle(
                        color: _primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                // 2. Dynamic Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Enter your email',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 3. Input Section (Aligned to Line)
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    // The Underline (Fixed at bottom)
                    Container(
                      height: 1.2,
                      width: double.infinity,
                      color: _primaryColor,
                    ),

                    // Icon and Text Row
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 2.0,
                      ), // 1-2 pixel above line
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Image.asset(
                            'assets/images/mail.png',
                            width: 22,
                            height: 22,
                            color: _primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _mobileController,
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: _primaryColor,
                              style: const TextStyle(
                                fontSize: 18,
                                color: _primaryColor,
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Email Address',
                                hintStyle: const TextStyle(
                                  color: _primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                const SizedBox(height: 40),

                // Error Message Display
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 4. Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _validateAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF252876),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // 5. Signup Flow (Clickable)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                  child: const Text(
                    "I don't have an account",
                    style: TextStyle(
                      color: _primaryColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }
}
