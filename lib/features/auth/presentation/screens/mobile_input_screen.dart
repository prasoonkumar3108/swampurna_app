import 'package:flutter/material.dart';
import 'otp_screen.dart';
import 'signup_screen.dart';
import '../../../../core/services/auth_service.dart';

class MobileInputScreen extends StatefulWidget {
  const MobileInputScreen({super.key});

  @override
  State<MobileInputScreen> createState() => _MobileInputScreenState();
}

class _MobileInputScreenState extends State<MobileInputScreen> {
  // Colors from screenshots
  static const Color _primaryColor = Color(0xFF2E3192);
  static const Color _bgColor = Color(0xFFD1EDF2);

  final TextEditingController _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmailMode = false;

  // Toggle between phone and email mode
  void _toggleInputMode() {
    setState(() {
      _isEmailMode = !_isEmailMode;
      _mobileController.clear();
      _errorMessage = null;
    });
  }

  // Validation Logic with API call
  void _validateAndContinue() async {
    String value = _mobileController.text.trim();

    // Reset error state
    setState(() {
      _errorMessage = null;
    });

    if (value.isEmpty) {
      setState(() {
        _errorMessage = _isEmailMode
            ? "Please enter your email address"
            : "Please enter your mobile number";
      });
      return;
    }

    if (_isEmailMode) {
      // Email validation
      if (!value.contains('@') || !value.contains('.')) {
        setState(() {
          _errorMessage = "Please enter a valid email address";
        });
        return;
      }
    } else {
      // Phone validation
      if (value.length < 10) {
        setState(() {
          _errorMessage = "Please enter a valid 10-digit number";
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isEmailMode) {
        debugPrint('Sending OTP to email: $value');

        // Call send-otp API with email
        final authService = AuthService();
        final response = await authService.loginUser(
          email: value,
          purpose: 'login',
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (response.success) {
            debugPrint('OTP sent successfully');
            // Navigate to OTP Screen with email
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpScreen(
                  phoneNumber: value,
                ), // Reuse phoneNumber field for email
              ),
            );
          } else {
            setState(() {
              _errorMessage = response.error ?? 'Failed to send OTP';
            });
          }
        }
      } else {
        // Phone mode - keep existing phone logic
        String formattedPhone = value.trim();
        if (!formattedPhone.startsWith('+')) {
          formattedPhone = '+91$formattedPhone'; // Default to India code
        }

        debugPrint('Sending OTP to phone: $formattedPhone');

        // Call send-otp API with phone
        final authService = AuthService();
        final response = await authService.sendOtp(phone: formattedPhone);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (response.success) {
            debugPrint('OTP sent successfully');
            // Navigate to OTP Screen with phone number
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpScreen(phoneNumber: formattedPhone),
              ),
            );
          } else {
            setState(() {
              _errorMessage = response.error ?? 'Failed to send OTP';
            });
          }
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
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
                    'Skip',
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
                  _isEmailMode
                      ? 'Enter your email'
                      : 'Enter your mobile number',
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
                          _isEmailMode
                              ? 'assets/images/mail.png'
                              : 'assets/images/phone.png',
                          width: 22,
                          height: 22,
                          color: _primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _mobileController,
                            keyboardType: _isEmailMode
                                ? TextInputType.emailAddress
                                : TextInputType.phone,
                            cursorColor: _primaryColor,
                            style: const TextStyle(
                              fontSize: 18,
                              color: _primaryColor,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              hintText: _isEmailMode
                                  ? 'Email Address'
                                  : 'Mobile Number',
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

              // 4. Toggle Input Mode Button
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: _toggleInputMode,
                  child: Text(
                    _isEmailMode ? 'Use Mobile Number' : 'Use Email-ID',
                    style: const TextStyle(
                      color: _primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Spacer(),

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
    );
  }
}
