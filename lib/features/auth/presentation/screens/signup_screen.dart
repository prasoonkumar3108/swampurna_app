import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/auth_service.dart';
import 'otp_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const Color primary = Color(0xFF1D2671);

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _dob = TextEditingController();
  final _password = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _dob.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onContinue() async {
    // Validate required fields
    if (_name.text.trim().isEmpty ||
        _dob.text.trim().isEmpty ||
        _phone.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Name, Date of Birth, and Phone are required';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Format birth date as YYYY-MM-DD
      String formattedBirthDate = _dob.text.trim();
      if (formattedBirthDate.isNotEmpty) {
        final parts = formattedBirthDate.split('/');
        if (parts.length == 3) {
          final day = parts[0].padLeft(2, '0');
          final month = parts[1].padLeft(2, '0');
          final year = parts[2];
          formattedBirthDate = '$year-$month-$day';
        }
      }

      // Add country code if missing
      String formattedPhone = _phone.text.trim();
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+91$formattedPhone'; // Default to India code
      }

      // Create registration request
      final registerRequest = RegisterRequest(
        fullName: _name.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        phoneNumber: formattedPhone,
        birthDate: formattedBirthDate,
        password: _password.text.trim().isEmpty
            ? 'defaultPassword123'
            : _password.text.trim(),
      );

      // Call auth service
      final authService = AuthService();
      final response = await authService.registerUser(registerRequest);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.success) {
          debugPrint('Registration successful: ${response.data?.userId}');

          // Extract email from the registration request
          String userEmail = _email.text.trim().isEmpty
              ? ''
              : _email.text.trim();

          // TODO: Save user token locally
          // await TokenManager.saveToken(response.data?.token ?? '');

          // Navigate to OTP Screen for email verification
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(phoneNumber: userEmail),
            ),
          );
        } else {
          setState(() {
            _errorMessage = response.error ?? 'Registration failed';
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
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
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
                      _fieldTitle("Birth of date"),
                      const SizedBox(height: 6),
                      _inputBox(
                        controller: _dob,
                        hint: "18/03/2024",
                        readOnly: true,
                        onTap: _pickDate,
                        suffix: const Icon(Icons.calendar_today, size: 18),
                      ),

                      const SizedBox(height: 18),

                      /// NAME
                      _fieldTitle("Full Name"),
                      const SizedBox(height: 6),
                      _inputBox(controller: _name, hint: "Lois Becket"),

                      const SizedBox(height: 18),

                      /// EMAIL
                      _fieldTitle("Email (optional)"),
                      const SizedBox(height: 6),
                      _inputBox(
                        controller: _email,
                        hint: "loisbecket@gmail.com",
                      ),

                      const SizedBox(height: 18),

                      /// PHONE
                      _fieldTitle("Phone Number"),
                      const SizedBox(height: 6),
                      _phoneField(),

                      const SizedBox(height: 18),

                      /// PASSWORD
                      _fieldTitle("Password"),
                      const SizedBox(height: 6),
                      _inputBox(
                        controller: _password,
                        hint: "Enter password",
                        obscureText: true,
                      ),

                      const SizedBox(height: 30),
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
                              style: TextStyle(
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

  /// ---------- WIDGETS ----------

  Widget _fieldTitle(String text) {
    return Text(
      text,
      style: const TextStyle(color: primary, fontWeight: FontWeight.w500),
    );
  }

  Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffix,
    bool obscureText = false,
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
              readOnly: readOnly,
              onTap: onTap,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
          if (suffix != null) suffix,
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
                Text(""),
                SizedBox(width: 6),
                Icon(Icons.keyboard_arrow_down),
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
