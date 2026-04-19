import 'package:flutter/material.dart';
import 'confirmation_screen.dart';
import '../../../core/network/simple_api_client.dart';

class SignupWithApiScreen extends StatefulWidget {
  const SignupWithApiScreen({super.key});

  @override
  State<SignupWithApiScreen> createState() => _SignupWithApiScreenState();
}

class _SignupWithApiScreenState extends State<SignupWithApiScreen> {
  static const Color primary = Color(0xFF1D2671);

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _dob = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _dob.dispose();
    super.dispose();
  }

  void _onContinue() async {
    if (_name.text.trim().isEmpty || _dob.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Name and Date of Birth are required';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Example API call using our new client
      // TODO: Replace with actual API call when ready
      // final response = await ApiEndpoints.registerUser(
      //   name: _name.text.trim(),
      //   email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      //   phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      //   dob: _dob.text.trim(),
      //   password: 'tempPassword123',
      // );

      // Mock successful response for demonstration
      await Future.delayed(const Duration(seconds: 2));
      final mockResponse = ApiResponse.success({
        'user_id': '12345',
        'token': 'mock_jwt_token',
        'name': _name.text.trim(),
      });

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (mockResponse.success) {
          debugPrint('Registration successful: ${mockResponse.data}');

          // Navigate to confirmation screen on success
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ConfirmationScreen()),
          );
        } else {
          setState(() {
            _errorMessage = mockResponse.error ?? 'Registration failed';
          });
        }
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Network error. Please try again.';
        });
      }
    }
  }

  void _onLogin() {
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      _dob.text = "${date.day}/${date.month}/${date.year}";
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF6FA), Color(0xFFD7F1F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              /// TOP CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// BACK
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: primary),
                      ),

                      const SizedBox(height: 10),

                      /// TITLE
                      const Text(
                        "Sign up",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "Create an account to continue!",
                        style: TextStyle(fontSize: 16, color: primary),
                      ),

                      const SizedBox(height: 25),

                      /// DOB
                      const Text(
                        "Birth of date",
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _inputBox(
                        controller: _dob,
                        hint: "18/03/2024",
                        onTap: _pickDate,
                        suffix: const Icon(Icons.calendar_today, size: 18),
                      ),

                      const SizedBox(height: 18),

                      /// NAME
                      const Text(
                        "Full Name",
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _inputBox(controller: _name, hint: "Lois Becket"),

                      const SizedBox(height: 18),

                      /// EMAIL
                      const Text(
                        "Email (optional)",
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _inputBox(
                        controller: _email,
                        hint: "loisbecket@gmail.com",
                      ),

                      const SizedBox(height: 18),

                      /// PHONE
                      const Text(
                        "Phone Number",
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _phoneField(),
                    ],
                  ),
                ),
              ),

              /// ERROR MESSAGE
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
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

              /// BOTTOM BUTTON SECTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    /// BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                                "Continue",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// LOGIN TEXT
                    GestureDetector(
                      onTap: _onLogin,
                      child: RichText(
                        text: const TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: Colors.black54),
                          children: [
                            TextSpan(
                              text: "Login",
                              style: const TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    VoidCallback? onTap,
    Widget? suffix,
  }) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onTap: onTap,
              readOnly: onTap != null,
              decoration: const InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }

  Widget _phoneField() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          /// FLAG + CODE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: const Row(
              children: [
                Text("🇩🇰"), // placeholder flag
                const SizedBox(width: 6),
                Icon(Icons.keyboard_arrow_down, color: primary, size: 20),
              ],
            ),
          ),

          Container(width: 1, color: Colors.grey.shade300),

          /// PHONE INPUT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: "(454) 726-0592",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
