import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'report_problem_screen.dart';
import 'jan_aushadhi_search_screen.dart';
import 'common_webview_screen.dart';
import 'mobile_input_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chat.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Fix 1: Variables ko yahan define karein taaki poori class mein use ho sakein
  final Color navyBlue = const Color(0xFF1E1E5F);
  final Color scaffoldBg = const Color(0xFFE1F5F3);
  final Color cardBg = const Color(0xFFD1EBEA);

  bool _isLoggingOut = false;
  bool _fabExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // Main Scrollable Content
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Settings Title
                Center(
                  child: Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color:
                          navyBlue, // Fix 2: const hata diya kyunki navyBlue variable hai
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Account Section
                _buildSectionCard(
                  title: "Account",
                  items: [
                    {
                      "icon": Icons.person_outline,
                      "text": "Edit profile",
                      "id": "edit",
                    },
                    {
                      "icon": Icons.notifications_none,
                      "text": "Notifications",
                      "id": "notify",
                    },
                    {
                      "icon": Icons.lock_outline,
                      "text": "Privacy",
                      "id": "privacy",
                    },
                  ],
                  navyBlue: navyBlue,
                  cardBg: cardBg,
                ),

                const SizedBox(height: 20),

                // Support & About Section
                _buildSectionCard(
                  title: "Support & About",
                  items: [
                    {
                      "icon": Icons.help_outline,
                      "text": "Help & Support",
                      "id": "help",
                    },
                    {
                      "icon": Icons.location_on_outlined,
                      "text": "Find Nearby Medical Stores",
                      "id": "stores",
                    },
                    {
                      "icon": Icons.description_outlined,
                      "text": "Terms and Policies",
                      "id": "terms",
                    },
                  ],
                  navyBlue: navyBlue,
                  cardBg: cardBg,
                ),

                const SizedBox(height: 20),

                // Actions Section
                _buildSectionCard(
                  title: "Actions",
                  items: [
                    {
                      "icon": Icons.flag_outlined,
                      "text": "Report a problem",
                      "id": "report",
                    },
                    {"icon": Icons.logout, "text": "Log out", "id": "logout"},
                    {
                      "icon": Icons.delete_outline,
                      "text": "Delete Account",
                      "id": "delete",
                    },
                  ],
                  navyBlue: navyBlue,
                  cardBg: cardBg,
                ),
                const SizedBox(height: 10), // Bottom breathing space
              ],
            ),
          ),
        ],
      ),
    floatingActionButton: buildFAB(context),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Map<String, dynamic>> items,
    required Color navyBlue,
    required Color cardBg,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: navyBlue,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: items.map((item) {
              return _buildMenuItem(
                icon: item["icon"],
                text: item["text"],
                actionId: item["id"],
                navyBlue: navyBlue,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required String actionId,
    required Color navyBlue,
  }) {
    return InkWell(
      onTap: () => _handleAction(actionId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: navyBlue, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: navyBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(String actionId) {
    switch (actionId) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
        );
        break;

      case 'notify':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationSettingsScreen(),
          ),
        );
        break;

      case 'privacy':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CommonWebViewScreen(
              url: 'https://swampurna-final.vercel.app/Privacypolicy',
              title: 'Privacy Policy',
            ),
          ),
        );
        break;

      case 'terms':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CommonWebViewScreen(
              url: 'https://swampurna-final.vercel.app/Termsconditions',
              title: 'Terms & Conditions',
            ),
          ),
        );
        break;

      case 'stores':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const JanAushadhiSearchScreen(),
          ),
        );
        break;

      case 'help':
      case 'delete':
        // Disable irrelevant clicks - no action
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coming Soon'),
            backgroundColor: Colors.grey,
          ),
        );
        break;

      case 'report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportProblemScreen()),
        );
        break;

      case 'logout':
        _showLogoutDialog();
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coming Soon'),
            backgroundColor: Colors.grey,
          ),
        );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_isLoggingOut) return; // Prevent multiple clicks

                Navigator.of(context).pop();
                await _performLogout();
              },
              child: const Text('Log Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    setState(() => _isLoggingOut = true);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Logging out...'),
            ],
          ),
        );
      },
    );

    try {
      await AuthService().logout();
      print("✅ Logout Success: Session cleared");
    } catch (e) {
      print("❌ Logout Error: $e");
    } finally {
      if (mounted) {
        // 1. Pehle loading dialog ko band karein
        if (Navigator.canPop(context)) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        setState(() => _isLoggingOut = false);
      }
      // 2. Clear stack and push to login
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  void _navigateToLogin() {
    // Clear stack and push to mobile_input screen directly
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MobileInputScreen()),
      (route) => false,
    );
  }

  Widget _circularButton(
    IconData icon,
    Color bg,
    Color iconColor, {
    bool isLarge = false,
  }) {
    return Container(
      width: isLarge ? 60 : 50,
      height: isLarge ? 60 : 50,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor, size: isLarge ? 30 : 22),
    );
  }

  Widget buildFAB(BuildContext context) {

  return Padding(
    padding: const EdgeInsets.only(bottom: 70),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Agar expanded hai to mini buttons dikhao
        if (_fabExpanded) ...[
          FloatingActionButton(
            heroTag: 'msg_fab',
            mini: true,
            backgroundColor: const Color(0xFF4A4F7C),
            onPressed: () => navigateTo(const ChatScreen()),
            child: const Icon(Icons.message, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'call_fab',
            mini: true,
            backgroundColor: Colors.blue,
            onPressed: () {
              // Example: call number 1
              //launchUrl(Uri.parse("tel:+919599801033"));
              _makePhoneCall("+919599801033");
            },
            child: const Icon(Icons.call, color: Colors.white),
          ),
          const SizedBox(height: 10),
        ],

        // Main FAB (add/cross toggle)
        FloatingActionButton(
          heroTag: 'main_fab',
          backgroundColor: const Color(0xFF3A4685),
          elevation: 6,
          onPressed: () {
            setState(() {
              _fabExpanded = !_fabExpanded;
            });
          },
          child: Icon(
            _fabExpanded ? Icons.close : Icons.add,
            color: Colors.white,
            size: 32,
          ),
        ),
      ],
    ),
  );
}
Future<void> _makePhoneCall(String number) async {
  final Uri callUri = Uri(scheme: 'tel', path: number);
  if (await canLaunchUrl(callUri)) {
    await launchUrl(callUri);
  } else {
    throw 'Could not launch $number';
  }
}
void navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}
