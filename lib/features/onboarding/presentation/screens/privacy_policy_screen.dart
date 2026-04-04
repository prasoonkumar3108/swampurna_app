import 'package:flutter/material.dart';
import '../../../auth/presentation/screens/mobile_input_screen.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  // Individual states for each checkbox requirement
  bool _termsAgreed = false;
  bool _healthAgreed = false;
  bool _trackingAgreed = false;

  // Exact brand colors sampled from your screenshot
  static const Color _brandBg = Color(0xFFD7F2F4);
  static const Color _brandNavy = Color(0xFF1D2671);

  // High-level action to select everything at once
  void _onAcceptAll() {
    setState(() {
      _termsAgreed = true;
      _healthAgreed = true;
      _trackingAgreed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _brandBg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Header
            const Text(
              'Privacy first',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _brandNavy,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 40),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildConsentRow(
                      text: 'I agree to Privacy Policy and Terms of Use.',
                      value: _termsAgreed,
                      onChanged: (val) => setState(() => _termsAgreed = val!),
                    ),
                    const SizedBox(height: 24),
                    _buildConsentRow(
                      text:
                          'I agree to processing of my personal health data for providing me Flo app functions.\nSee more in Privacy Policy.',
                      value: _healthAgreed,
                      onChanged: (val) => setState(() => _healthAgreed = val!),
                    ),
                    const SizedBox(height: 24),
                    _buildConsentRow(
                      text:
                          'I agree to allow SWAMPURNA to track across apps and websites owned by other companies and that AppsFlyer and its integrated partners may recieve information about my age-group, subscription status, fact of application launch and technical identifiers all as more detailed in the Privacy Policy. This helps Flo to reach me and people like me to spread the word about the app as well as analyze whether we do that effectively.',
                      value: _trackingAgreed,
                      onChanged: (val) =>
                          setState(() => _trackingAgreed = val!),
                    ),
                  ],
                ),
              ),
            ),

            // Footer Section
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, top: 10),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _onAcceptAll,
                    child: const Text(
                      'Accept all',
                      style: TextStyle(
                        fontSize: 18,
                        color: _brandNavy,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 180, // Specific width for the pill button
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _termsAgreed
                          ? () {
                              // Navigate to MobileInputScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MobileInputScreen(),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brandNavy,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _brandNavy.withOpacity(0.3),
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modular helper to ensure consistent UI across all consent items
  Widget _buildConsentRow({
    required String text,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: _brandNavy,
            side: const BorderSide(color: _brandNavy, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: _brandNavy,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
