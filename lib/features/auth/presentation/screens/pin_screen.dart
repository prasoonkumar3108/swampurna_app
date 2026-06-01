import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../../auth/presentation/screens/tracker_screen.dart';
import '../../../auth/presentation/screens/confirmation_screen.dart';
import 'package:my_app/features/auth/models/onboarding_data.dart';
import 'mobile_input_screen.dart';

enum PinMode { LOGIN_PIN, SET_PIN, VERIFY_PIN }

class PinScreen extends StatefulWidget {
  final String email;
  final PinMode initialMode;

  const PinScreen({
    super.key,
    required this.email,
    this.initialMode = PinMode.LOGIN_PIN,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  // OTP/PIN Input Controllers (4 digits)
  final List<TextEditingController> _pinControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  // UI State
  bool _isLoading = false;
  String? _errorMessage;
  late PinMode _currentMode;

  // Colors matching the OTP screen design
  static const Color _primaryDark = Color(0xFF1D2671);
  static const Color _bgColor = Color(0xFFD1F0F3);
  static const Color _accentWhite = Colors.white;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
    debugPrint(
      '🔐 PinScreen initialized for email: ${widget.email}, mode: $_currentMode',
    );
  }

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
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

  // API Calls
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

          // Navigate to Home/Tracker Screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const TrackerScreen()),
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

  Future<void> _setPIN() async {
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
      debugPrint('🔐 Setting PIN for email: ${widget.email}');

      final authService = AuthService();
      final response = await authService.setPIN(pin: _getCompletePIN());

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.success) {
          debugPrint('✅ PIN set successful');
          _showSuccessToast('PIN set successfully!');

          // Navigate to ConfirmationScreen for new users
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ConfirmationScreen(
                  onboardingData: OnboardingData(
                    email: widget.email,
                    otp: '', // PIN setup completed
                  ),
                ),
              ),
            );
          }
        } else {
          setState(() {
            _errorMessage = response.error ?? 'Failed to set PIN';
          });

          // Check for authentication errors and redirect to login
          if (response.statusCode == 401 ||
              (response.error?.toLowerCase().contains('authentication') ==
                  true)) {
            debugPrint('🚫 Authentication error, redirecting to login');
            _redirectToLogin();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Network error. Please try again.';
        });
      }
      debugPrint('❌ Set PIN error: $e');
    }
  }

  Future<void> _verifyPIN() async {
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
      debugPrint('🔐 Verifying PIN for email: ${widget.email}');

      final authService = AuthService();
      final response = await authService.verifyPIN(pin: _getCompletePIN());

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.success) {
          debugPrint('✅ PIN verification successful');
          _showSuccessToast('PIN verified successfully!');

          // Navigate to Tracker/Home screen
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const TrackerScreen()),
              (route) => false,
            );
          }
        } else {
          setState(() {
            _errorMessage = response.error ?? 'PIN verification failed';
          });

          // Check for authentication errors and redirect to login
          if (response.statusCode == 401 ||
              (response.error?.toLowerCase().contains('authentication') ==
                  true)) {
            debugPrint('🚫 Authentication error, redirecting to login');
            _redirectToLogin();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Network error. Please try again.';
        });
      }
      debugPrint('❌ Verify PIN error: $e');
    }
  }

  // Clear PIN input
  void _clearPIN() {
    for (var controller in _pinControllers) {
      controller.clear();
    }
  }

  // Show success toast
  void _showSuccessToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Redirect to login screen on authentication error
  void _redirectToLogin() {
    // Clear any stored tokens
    TokenStorageService.instance.clearAll();

    // Navigate back to login screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MobileInputScreen()),
      (route) => false,
    );

    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session expired. Please login again.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Get title based on current mode
  String _getScreenTitle() {
    switch (_currentMode) {
      case PinMode.LOGIN_PIN:
        return 'ENTER PIN';
      case PinMode.SET_PIN:
      case PinMode.VERIFY_PIN:
        return 'Set PIN';
    }
  }

  // Get subtitle based on current mode
  Widget _getSubtitle() {
    switch (_currentMode) {
      case PinMode.LOGIN_PIN:
        return RichText(
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
        );
      case PinMode.SET_PIN:
      case PinMode.VERIFY_PIN:
        return const SizedBox.shrink(); // No subtitle
    }
  }

  // Get button text based on current mode
  String _getButtonText() {
    switch (_currentMode) {
      case PinMode.LOGIN_PIN:
        return 'Login';
      case PinMode.SET_PIN:
        return 'Generate Pin';
      case PinMode.VERIFY_PIN:
        return 'Verify Pin';
    }
  }

  // Handle button press based on current mode
  void _handleButtonPress() {
    switch (_currentMode) {
      case PinMode.LOGIN_PIN:
        _loginWithPIN();
        break;
      case PinMode.SET_PIN:
        _setPIN();
        break;
      case PinMode.VERIFY_PIN:
        _verifyPIN();
        break;
    }
  }

  // Handle Set PIN button press (only in LOGIN_PIN mode)
  void _handleSetPinPress() {
    setState(() {
      _currentMode = PinMode.SET_PIN;
      _clearPIN();
    });
  }

  // Skip to ConfirmationScreen for new users
  void _onSkipToTracker() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmationScreen(
          onboardingData: OnboardingData(
            email: widget.email,
            otp: '', // PIN setup skipped
          ),
        ),
      ),
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
          onPressed: () {
            if (_currentMode == PinMode.LOGIN_PIN) {
              Navigator.of(context).pop();
            } else {
              // Go back to LOGIN_PIN mode
              setState(() {
                _currentMode = PinMode.LOGIN_PIN;
                _clearPIN();
              });
            }
          },
        ),
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
              Text(
                _getScreenTitle(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _primaryDark,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle (only for LOGIN_PIN mode)
              _getSubtitle(),

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

              // Main Action Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleButtonPress,
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
                      : Text(
                          _getButtonText(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              // Skip Button (only in LOGIN_PIN mode for existing users)
              if (_currentMode == PinMode.LOGIN_PIN) ...[
                const SizedBox(height: 15),
                TextButton(
                  onPressed: _isLoading ? null : _onSkipToTracker,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],

              // Set PIN Button (only in LOGIN_PIN mode)
              if (_currentMode == PinMode.LOGIN_PIN) ...[
                const SizedBox(height: 15),
                TextButton(
                  onPressed: _isLoading ? null : _handleSetPinPress,
                  child: const Text(
                    'Set Pin',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _primaryDark,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
