import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'signup_screen.dart';
import 'source_selection_screen.dart';
import '../../../../core/services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // Dittoo Matching Colors from Screenshot
  static const Color _primaryDark = Color(0xFF1D2671);
  static const Color _bgColor = Color(
    0xFFD1F0F3,
  ); // Screenshot background matching
  static const Color _accentWhite = Colors.white;

  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  Timer? _timer;
  int _remainingSeconds = 120;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    for (var c in _otpControllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  void _onOTPChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _onLogin() async {
    final otp = _otpControllers.map((c) => c.text).join();

    // Validate OTP
    if (otp.length != 4) {
      setState(() {
        _errorMessage = 'Please enter a 4-digit OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('🔐 Verifying OTP for: ${widget.phoneNumber}');

      // Check if this is email (registration) or phone (login) flow
      final bool isEmailFlow = widget.phoneNumber.contains('@');

      final authService = AuthService();
      final response = isEmailFlow
          ? await authService.verifyRegistrationOtp(
              email: widget.phoneNumber,
              otp: otp,
            )
          : await authService.verifyOtp(phone: widget.phoneNumber, otp: otp);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.success) {
          debugPrint('✅ OTP verification successful');

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate to Home screen on success
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const SourceSelectionScreen()),
            (route) => false,
          );
        } else {
          setState(() {
            _errorMessage = response.error ?? 'Invalid OTP. Please try again.';
          });
        }
      }
    } catch (e) {
      debugPrint('❌ OTP verification error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Network error. Please try again.';
        });
      }
    }
  }

  void _onResend() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('Resending OTP to: ${widget.phoneNumber}');

      // Call send-otp API again
      final authService = AuthService();
      final response = await authService.sendOtp(phone: widget.phoneNumber);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.success) {
          debugPrint('OTP resent successfully');
          setState(() => _remainingSeconds = 120);
          _startTimer();
        } else {
          setState(() {
            _errorMessage = response.error ?? 'Failed to resend OTP';
          });
        }
      }
    } catch (e) {
      debugPrint('Resend OTP error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Network error. Please try again.';
        });
      }
    }
  }

  void _onBack() => Navigator.pop(context);

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs Sec';
  }

  @override
  Widget build(BuildContext context) {
    // Screen size for responsiveness
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Back Button
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            alignment: Alignment.topLeft,
                            onPressed: _onBack,
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: 28,
                            ),
                          ),
                        ),

                        // Image - Using your directory path
                        const SizedBox(height: 20),
                        Image.asset(
                          'assets/images/undraw_completing.png',
                          height:
                              size.height *
                              0.35, // Proper ratio for all screens
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 30),

                        // Title
                        const Text(
                          'OTP VERIFICATION',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subtitle - Text from your attachment/screenshot
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            children: [
                              TextSpan(text: 'Enter the OTP sent to - '),
                              TextSpan(
                                text: '+91-8976500001',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // OTP Boxes Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            4,
                            (index) => _buildOTPBox(index),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Timer
                        Text(
                          _formatTime(_remainingSeconds),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Resend Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't receive code? ",
                              style: TextStyle(color: Colors.black54),
                            ),
                            GestureDetector(
                              onTap: _onResend,
                              child: const Text(
                                'Re-send',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _onLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
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
          },
        ),
      ),
    );
  }

  // OTP Box Design Dittoo matching screenshot
  Widget _buildOTPBox(int index) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: _accentWhite,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: (v) => _onOTPChanged(v, index),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
