import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/token_storage_service.dart';
import 'set_pin_screen.dart';
import 'confirmation_screen.dart';

class LoginWithPinScreen extends StatefulWidget {
  final String email;
  final String? token;

  const LoginWithPinScreen({super.key, required this.email, this.token});

  @override
  State<LoginWithPinScreen> createState() => _LoginWithPinScreenState();
}

class _LoginWithPinScreenState extends State<LoginWithPinScreen> {
  // PIN Input Controllers (4 digits)
  final List<TextEditingController> _pinControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _pinFocusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  // UI State
  bool _isLoading = false;
  String? _errorMessage;

  // Colors matching the OTP screen design
  static const Color _primaryDark = Color(0xFF1D2671);
  static const Color _bgColor = Color(0xFFD1F0F3);
  static const Color _accentWhite = Colors.white;

  @override
  void initState() {
    super.initState();
    debugPrint('🔐 LoginWithPinScreen initialized for email: ${widget.email}');

    // Save token if provided
    if (widget.token != null && widget.token!.isNotEmpty) {
      TokenStorageService.instance.saveToken(widget.token!);
      debugPrint('🔑 Token saved successfully');
    }
  }

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var focusNode in _pinFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // Handle PIN input changes
  void _onPINChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      FocusScope.of(context).nextFocus();
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).previousFocus();
    }
  }

  // Get complete PIN
  String _getCompletePIN() {
    return _pinControllers.map((c) => c.text).join();
  }

  // Validate PIN input
  bool _isPINValid() {
    String pin = _getCompletePIN();
    return pin.length == 4 && pin.contains(RegExp(r'^[0-9]{4}$'));
  }

  // Login with PIN
  Future<void> _loginWithPIN() async {
    if (!_isPINValid()) {
      setState(() {
        _errorMessage = 'Please enter a valid 4-digit PIN';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('🔐 Logging in with PIN for email: ${widget.email}');

      final authService = AuthService();
      final response = await authService.loginWithPIN(
        email: widget.email,
        pin: _getCompletePIN(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.success) {
          debugPrint('✅ PIN login successful');

          // Initialize onboarding data
          final onboardingData = <String, dynamic>{
            'email': widget.email,
            'login_method': 'pin',
          };

          // Navigate to ConfirmationScreen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) =>
                  ConfirmationScreen(onboardingData: onboardingData),
            ),
            (route) => false,
          );
        } else {
          setState(() {
            _errorMessage = response.error ?? 'PIN login failed';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Network error. Please try again.';
        });
      }
      debugPrint('❌ PIN login error: $e');
    }
  }

  // Navigate to Set PIN Screen
  void _navigateToSetPin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SetPinScreen()),
    );
  }

  // Skip PIN flow and go to ConfirmationScreen
  void _skipToHome() {
    debugPrint('⏭️ Skipping PIN flow, going to ConfirmationScreen');

    // Initialize onboarding data
    final onboardingData = <String, dynamic>{
      'email': widget.email,
      'login_method': 'skip',
    };

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => ConfirmationScreen(onboardingData: onboardingData),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Skip Button
          TextButton(
            onPressed: _isLoading ? null : _skipToHome,
            child: const Text(
              'Skip',
              style: TextStyle(
                color: _primaryDark,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _primaryDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.lock, color: Colors.white, size: 40),
              ),

              const SizedBox(height: 30),

              // Title
              const Text(
                'ENTER PIN',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _primaryDark,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  children: [
                    const TextSpan(text: 'Email: '),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // PIN Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 50,
                    height: 50,
                    child: TextField(
                      controller: _pinControllers[index],
                      focusNode: _pinFocusNodes[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _primaryDark,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _primaryDark),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: _primaryDark,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: _accentWhite,
                      ),
                      onChanged: (value) => _onPINChanged(index, value),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 30),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginWithPIN,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 15),

              // Set PIN Button
              TextButton(
                onPressed: _isLoading ? null : _navigateToSetPin,
                child: const Text(
                  'Set Pin',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _primaryDark,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
