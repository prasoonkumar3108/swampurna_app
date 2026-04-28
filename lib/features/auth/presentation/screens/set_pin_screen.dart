import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/auth_service.dart';

enum SetPinPhase { GENERATE, VERIFY }

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  // PIN Input Controllers (4 digits)
  final List<TextEditingController> _pinControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _pinFocusNodes = List.generate(4, (index) => FocusNode());

  // UI State
  bool _isLoading = false;
  String? _errorMessage;
  SetPinPhase _currentPhase = SetPinPhase.GENERATE;

  // Colors matching the OTP screen design
  static const Color _primaryDark = Color(0xFF1D2671);
  static const Color _bgColor = Color(0xFFD1F0F3);
  static const Color _accentWhite = Colors.white;

  @override
  void initState() {
    super.initState();
    debugPrint('🔐 SetPinScreen initialized');
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

  // Clear PIN input
  void _clearPIN() {
    for (var controller in _pinControllers) {
      controller.clear();
    }
  }

  // Show success message
  void _showSuccessToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Handle button press based on current phase
  Future<void> _handleButtonPress() async {
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
      final authService = AuthService();
      
      if (_currentPhase == SetPinPhase.GENERATE) {
        // Phase 1: Set PIN
        debugPrint('🔐 Setting new PIN');
        final response = await authService.setPIN(pin: _getCompletePIN());

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (response.success) {
            debugPrint('✅ PIN set successful');
            _showSuccessToast('PIN set successfully! Please verify it.');
            
            // Move to verification phase
            setState(() {
              _currentPhase = SetPinPhase.VERIFY;
              _clearPIN();
            });
          } else {
            setState(() {
              _errorMessage = response.error ?? 'Failed to set PIN';
            });
          }
        }
      } else {
        // Phase 2: Verify PIN
        debugPrint('🔐 Verifying PIN');
        final response = await authService.verifyPIN(pin: _getCompletePIN());

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (response.success) {
            debugPrint('✅ PIN verification successful');
            _showSuccessToast('PIN verified successfully!');
            
            // Pop back to LoginWithPinScreen
            Navigator.of(context).pop();
          } else {
            setState(() {
              _errorMessage = response.error ?? 'PIN verification failed';
            });
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
      debugPrint('❌ PIN action error: $e');
    }
  }

  // Get button text based on current phase
  String _getButtonText() {
    switch (_currentPhase) {
      case SetPinPhase.GENERATE:
        return 'Generate Pin';
      case SetPinPhase.VERIFY:
        return 'Verify Pin';
    }
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
                child: const Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 30),

              // Title
              const Text(
                'Set PIN',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _primaryDark,
                ),
              ),

              // No subtitle for Set PIN screen

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
                          borderSide: const BorderSide(color: _primaryDark, width: 2),
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

              // Phase indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _primaryDark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _currentPhase == SetPinPhase.GENERATE 
                      ? 'Step 1: Create your PIN'
                      : 'Step 2: Confirm your PIN',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _primaryDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20),

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

              // Action Button
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
