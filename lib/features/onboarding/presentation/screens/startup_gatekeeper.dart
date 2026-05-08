import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/presentation/screens/tracker_screen.dart';
import 'splash_screen.dart';

/// Lightweight Startup Gatekeeper
/// Checks auth session immediately and routes to appropriate screen
/// without showing unnecessary splash/onboarding for logged-in users
class StartupGatekeeper extends StatefulWidget {
  const StartupGatekeeper({super.key});

  @override
  State<StartupGatekeeper> createState() => _StartupGatekeeperState();
}

class _StartupGatekeeperState extends State<StartupGatekeeper> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Immediate auth check - no delays
    final authService = AuthService();
    final bool isLoggedIn = await authService.isLoggedIn();

    debugPrint('🚀 [STARTUP] Immediate auth check: $isLoggedIn');

    if (!mounted) return;

    setState(() => _isChecking = false);

    if (isLoggedIn) {
      debugPrint('✅ [STARTUP] User logged in - Direct to Tracker');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TrackerScreen()),
        (route) => false, // Clear entire stack
      );
    } else {
      debugPrint(
        'ℹ️ [STARTUP] User not logged in - Start original splash flow',
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SplashScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show minimal loading while checking auth
    if (_isChecking) {
      return Scaffold(
        backgroundColor: const Color(0xFFD1F2F2),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF1A237E)),
        ),
      );
    }

    // This should never be visible as navigation happens immediately
    return const SizedBox.shrink();
  }
}
