import 'package:flutter/material.dart';
import 'otp_screen.dart';
import 'signup_screen.dart';

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

  // Validation Logic
  void _validateAndContinue() {
    String value = _mobileController.text.trim();
    if (value.isEmpty) {
      _showSnackBar("Please enter your mobile number");
    } else if (value.length < 10) {
      _showSnackBar("Please enter a valid 10-digit number");
    } else {
      // Navigate to OTP Screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OtpScreen()),
      );
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

              // 2. Input Section (Aligned to Line)
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
                            keyboardType: TextInputType.phone,
                            cursorColor: _primaryColor,
                            style: const TextStyle(
                              fontSize: 18,
                              color: _primaryColor,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Mobile Number',
                              hintStyle: TextStyle(
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

              // 3. Use Email-ID
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    // Logic for Email Login
                  },
                  child: const Text(
                    'Use Email-ID',
                    style: TextStyle(
                      color: _primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // 4. Continue Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _validateAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF252876),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
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
