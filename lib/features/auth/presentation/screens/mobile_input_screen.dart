import 'dart:async';
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
  // 100% Match Saturated Dynamic Light Theme Palette
  static const Color _screenBgColor = Color(0xFFE2F4FF);    // Icy soft blue page background
  static const Color _cardBgColor = Color(0xFFFFFFFF);      // Clean stark white card
  static const Color _brandBlue = Color(0xFF4FA3DC);        // Precise blueprint sky-blue color
  static const Color _textColorDark = Color(0xFF2C6B93);    // Muted deep blue text
  static const Color _textHintColor = Color(0xFF638FA9);    // Subtle grayed out label hint
  static const Color _inputFillColor = Color(0xFFD3EDFC);   // Saturated background tone inside input box

  final TextEditingController _mobileController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Widget _buildLoginMethodPopupContent(String email) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: _textColorDark.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Choose Login Method',
                style: TextStyle(
                  color: _textColorDark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: _textColorDark),
                style: IconButton.styleFrom(
                  backgroundColor: _textColorDark.withOpacity(0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                color: _brandBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _sendOtpAndNavigate(email);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.message_rounded, size: 22),
                    SizedBox(width: 12),
                    Text(
                      'Login with OTP',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showLoginMethodPopup(String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, 
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(bc).viewInsets.bottom), 
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: _buildLoginMethodPopupContent(email),
          ),
        );
      },
    );
  }

  Future<void> _sendOtpAndNavigate(String email) async {
    setState(() { _isLoading = true; });
    try {
      final authService = AuthService();
      final response = await authService.sendOtp(email: email, purpose: 'login');
      if (mounted) {
        setState(() { _isLoading = false; });
        if (response.success) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => OtpScreen(email: email, isFromSignup: false)));
        } else {
          setState(() { _errorMessage = response.error ?? 'Failed to send OTP'; });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to send OTP. Please check your connection and try again.';
        });
      }
    }
  }

  void _validateAndContinue() async {
    String value = _mobileController.text.trim();
    setState(() { _errorMessage = null; });
    if (value.isEmpty) {
      setState(() { _errorMessage = "Please enter your email address"; });
      return;
    }
    if (!value.contains('@') || !value.contains('.')) {
      setState(() { _errorMessage = "Please enter a valid email address"; });
      return;
    }
    _showLoginMethodPopup(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBgColor, 
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Vertically center the layout group
                  children: [
                    const Spacer(flex: 3), // Perfectly balanced top flex spacing

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none, 
                        children: [
                          
                          // 1. White Content Card Box
                          Container(
                            margin: const EdgeInsets.only(top: 50), // Standard overhang offset
                            padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 74.0, bottom: 34.0),
                            decoration: BoxDecoration(
                              color: _cardBgColor,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: _brandBlue.withOpacity(0.16),
                                  blurRadius: 30,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Welcome Back',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30, 
                                    fontWeight: FontWeight.bold,
                                    color: _textColorDark,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Good to see you again!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    color: _textHintColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 36),

                                // Label
                                const Text(
                                  'Email Address',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _textColorDark,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Textfield Structure
                                TextField(
                                  controller: _mobileController,
                                  keyboardType: TextInputType.emailAddress,
                                  cursorColor: _brandBlue,
                                  style: const TextStyle(fontSize: 14, color: _textColorDark, fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    hintText: 'example@domain.com',
                                    hintStyle: TextStyle(color: _textHintColor.withOpacity(0.6), fontSize: 14),
                                    prefixIcon: const Icon(
                                      Icons.mail_outline_rounded,
                                      color: _textColorDark,
                                      size: 20,
                                    ),
                                    filled: true,
                                    fillColor: _inputFillColor,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: _brandBlue.withOpacity(0.3), width: 1.2),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: _brandBlue, width: 1.6),
                                    ),
                                  ),
                                ),
                                
                                if (_errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      _errorMessage!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                                    ),
                                  ),
                                    
                                const SizedBox(height: 36),

                                // Continue Button
                                SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _validateAndContinue,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _brandBlue,
                                      foregroundColor: Colors.white,
                                      elevation: 1,
                                      shadowColor: _brandBlue.withOpacity(0.3),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                          )
                                        : const Text(
                                            'Continue',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Footer Sign Up Link
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
                                    },
                                    child: RichText(
                                      text: const TextSpan(
                                        style: TextStyle(fontSize: 13, color: _textColorDark),
                                        children: [
                                          TextSpan(text: "Don't have an account? "),
                                          TextSpan(
                                            text: "Sign Up",
                                            style: TextStyle(color: _brandBlue, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 2. Overlapping Shield Element
                          Positioned(
                            top: 0, 
                            child: Container(
                              width: 106,
                              height: 106,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _screenBgColor, 
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 88,
                                    height: 88,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _brandBlue.withOpacity(0.12),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.shield_outlined,
                                    size: 84,
                                    color: _brandBlue,
                                  ),
                                  const Positioned(
                                    top: 28,
                                    child: Icon(
                                      Icons.lock_rounded,
                                      size: 26,
                                      color: _brandBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 4), // Added a 4-ratio bottom spacer block to counter-balance top notches and shift card down into optical center
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }
}