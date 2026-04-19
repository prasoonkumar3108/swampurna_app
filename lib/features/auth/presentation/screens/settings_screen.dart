import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors matching your screenshot exactly
    const Color navyBlue = Color(0xFF1E1E5F);
    const Color cardBackground = Color(
      0xFFD1F0EF,
    ); // Light teal/blue from image
    const Color scaffoldBg = Color(0xFFC5EBEA);

    // Simulated API Data Structure
    final List<Map<String, dynamic>> settingsData = [
      {
        "category": "Account",
        "items": [
          {
            "icon": Icons.person_outline,
            "label": "Edit profile",
            "action": "edit",
          },
          {
            "icon": Icons.notifications_none,
            "label": "Notifications",
            "action": "notify",
          },
          {"icon": Icons.lock_outline, "label": "Privacy", "action": "privacy"},
        ],
      },
      {
        "category": "Support & About",
        "items": [
          {
            "icon": Icons.help_outline,
            "label": "Help & Support",
            "action": "help",
          },
          {
            "icon": Icons.info_outline,
            "label": "Find Nearby Medical Stores",
            "action": "stores",
          },
          {
            "icon": Icons.info_outline,
            "label": "Terms and Policies",
            "action": "terms",
          },
        ],
      },
      {
        "category": "Actions",
        "items": [
          {
            "icon": Icons.outlined_flag,
            "label": "Report a problem",
            "action": "report",
          },
          {"icon": Icons.logout, "label": "Log out", "action": "logout"},
          {
            "icon": Icons.delete_outline,
            "label": "Delete Account",
            "action": "delete",
          },
        ],
      },
    ];

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // Main Scrollable Content
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
            children: [
              const Center(
                child: Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Dark text like screenshot
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ...settingsData
                  .map((group) => _buildGroup(group, navyBlue, cardBackground))
                  .toList(),
            ],
          ),

          // Floating Action Buttons (Bottom Right Stack)
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _circularActionBtn(
                  Icons.phone_outlined,
                  Colors.white,
                  navyBlue,
                ),
                const SizedBox(height: 15),
                _circularActionBtn(
                  Icons.chat_bubble_outline,
                  Colors.white,
                  navyBlue,
                ),
                const SizedBox(height: 15),
                _circularActionBtn(
                  Icons.close,
                  navyBlue,
                  Colors.white,
                  isLarge: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(
    Map<String, dynamic> group,
    Color textColor,
    Color cardColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 8),
          child: Text(
            group["category"],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.bottom(25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(
              0.3,
            ), // Glass effect from screenshot
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: (group["items"] as List).map((item) {
              return _settingsItem(
                item["icon"],
                item["label"],
                item["label"] == "Delete Account" ? Colors.red : textColor,
                item["action"],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _settingsItem(
    IconData icon,
    String title,
    Color color,
    String action,
  ) {
    return ListTile(
      onTap: () {
        print("Executing action: $action"); // API Action placeholder
      },
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }

  Widget _circularActionBtn(
    IconData icon,
    Color bgColor,
    Color iconColor, {
    bool isLarge = false,
  }) {
    return Container(
      height: isLarge ? 65 : 55,
      width: isLarge ? 65 : 55,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor, size: isLarge ? 35 : 25),
    );
  }
}
