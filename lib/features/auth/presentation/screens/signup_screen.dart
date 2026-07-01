import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../../../core/models/register_request.dart';
import 'otp_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // 100% Precision Reference Matching Theme Palette
  static const Color _screenBgColor = Color(0xFFE2F4FF);    
  static const Color _cardBgColor = Color(0xFFFFFFFF);      
  static const Color _brandBlue = Color(0xFF4FA3DC);        
  static const Color _textColorDark = Color(0xFF2C6B93);    
  static const Color _textHintColor = Color(0xFF638FA9);    
  static const Color _inputFillColor = Color(0xFFD3EDFC);   

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

  @override
  void initState() {
    super.initState();
    if (_dob.text.isNotEmpty) {
      _dob.clear();
    }
  }

  void _onContinue() async {
    // Keyboard close on continue trigger
    FocusScope.of(context).unfocus();

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

      String formattedPhone = _phone.text.trim();
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+91$formattedPhone';
      }

      final registerRequest = RegisterRequest(
        fullName: _name.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        phoneNumber: formattedPhone,
        birthDate: formattedBirthDate,
        password: _password.text.trim().isEmpty
            ? 'defaultPassword123'
            : _password.text.trim(),
      );

      final authService = AuthService();
      final response = await authService.registerUser(registerRequest);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.success) {
          debugPrint(
            'Registration successful: ${response.data?['user_id'] ?? response.data?['id'] ?? response.data?['uid']}',
          );

          String userEmail = _email.text.trim().isEmpty
              ? ''
              : _email.text.trim();

          if (_dob.text.trim().isNotEmpty) {
            await TokenStorageService.instance.saveDob(_dob.text.trim());
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(email: userEmail, isFromSignup: true),
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
    FocusScope.of(context).unfocus(); // Dismiss active keyboards before picker opens
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
    return GestureDetector(
      // 1. Kahi bhi bahar tap karne par keyboard close hoga
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _screenBgColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, 
                      children: [
                        const Spacer(flex: 2),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          child: Stack(
                            alignment: Alignment.topCenter,
                            clipBehavior: Clip.none, 
                            children: [
                              
                              // (Wire lines custom painter completely removed from here)

                              // Content Panel White Card Box
                              Container(
                                margin: const EdgeInsets.only(top: 55),
                                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 70.0, bottom: 28.0),
                                decoration: BoxDecoration(
                                  color: _cardBgColor,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _brandBlue.withOpacity(0.14),
                                      blurRadius: 35,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 12), 
                                    )
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'Sign Up',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: _textColorDark,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                        'Create an account to continue!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        color: _textHintColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    /// DOB INPUT FIELD
                                    _fieldTitle("Birth of date"),
                                    const SizedBox(height: 8),
                                    _inputBox(
                                      controller: _dob,
                                      hint: "Select DOB",
                                      readOnly: true,
                                      onTap: _pickDate,
                                      prefixIcon: Icons.calendar_today_outlined,
                                    ),
                                    const SizedBox(height: 18),

                                    /// FULL NAME INPUT FIELD
                                    _fieldTitle("Full Name"),
                                    const SizedBox(height: 8),
                                    _inputBox(
                                      controller: _name, 
                                      hint: "Enter your name",
                                      prefixIcon: Icons.person_outline_rounded,
                                    ),
                                    const SizedBox(height: 18),

                                    /// EMAIL INPUT FIELD
                                    _fieldTitle("Email"),
                                    const SizedBox(height: 8),
                                    _inputBox(
                                      controller: _email, 
                                      hint: "Enter your email",
                                      prefixIcon: Icons.mail_outline_rounded,
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 18),

                                    /// PHONE NUMBER INPUT FIELD
                                    _fieldTitle("Phone Number"),
                                    const SizedBox(height: 8),
                                    _phoneField(),
                                    
                                    /// ERROR WRAPPER
                                    if (_errorMessage != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16.0),
                                        child: Text(
                                          _errorMessage!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.redAccent, 
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),

                                    const SizedBox(height: 36),

                                    /// PRIMARY ACTION INTERFACE BUTTON BLOCK
                                    SizedBox(
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _onContinue,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _brandBlue,
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor: _brandBlue.withOpacity(0.6),
                                          elevation: 1,
                                          shadowColor: _brandBlue.withOpacity(0.3),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5, 
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
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

                                    /// BACK TO AUTH LOGIN LINK HYPERLINK
                                    Center(
                                      child: GestureDetector(
                                        onTap: _onLogin,
                                        child: RichText(
                                          text: const TextSpan(
                                            style: TextStyle(fontSize: 13, color: _textColorDark),
                                            children: [
                                              TextSpan(text: "Already have an account? "),
                                              TextSpan(
                                                text: "Login",
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

                              // Symmetric Overlapping Custom Shield Brand Icon
                              Positioned(
                                top: 0,
                                child: Container(
                                  width: 108,
                                  height: 108,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _screenBgColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _brandBlue.withOpacity(0.12),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.shield_outlined,
                                        size: 86,
                                        color: _brandBlue,
                                      ),
                                      const Positioned(
                                        top: 28,
                                        child: Icon(
                                          Icons.person_add_alt_1_rounded,
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

                        const Spacer(flex: 3),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// ---------- FLAT UI BLUEPRINT COMPONENTS ----------

  Widget _fieldTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13.5, 
        fontWeight: FontWeight.w600, 
        color: _textColorDark,
      ),
    );
  }

  Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next, // Shift automatically to next box
      cursorColor: _brandBlue,
      style: const TextStyle(fontSize: 14, color: _textColorDark, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _textHintColor.withOpacity(0.55), fontSize: 14),
        prefixIcon: Icon(
          prefixIcon,
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
    );
  }

  Widget _phoneField() {
    return TextFormField(
      controller: _phone,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done, // 2. Done action key instead of normal wrap
      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(), // Done click handler to dismiss keyboard
      cursorColor: _brandBlue,
      style: const TextStyle(fontSize: 14, color: _textColorDark, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: "Enter your phone number",
        hintStyle: TextStyle(color: _textHintColor.withOpacity(0.55), fontSize: 14),
        prefixIcon: const Icon(
          Icons.phone_android_rounded,
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
    );
  }
}