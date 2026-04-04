import 'package:flutter/material.dart';
import 'confirmation_screen.dart';

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

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _dob.dispose();
    super.dispose();
  }

  void _onContinue() {
    debugPrint("Signup Data → ${_name.text}, ${_email.text}, ${_phone.text}");

    // Navigate to ConfirmationScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ConfirmationScreen()),
    );
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

                      const SizedBox(height: 30),
                    ],
                  ),
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
                        onPressed: _onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(fontSize: 18),
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
                Text("🇩🇰"), // placeholder flag
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
