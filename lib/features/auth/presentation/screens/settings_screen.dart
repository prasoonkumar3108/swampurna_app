import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Exact colors from the attachment
    const Color navyBlue = Color(0xFF1E1E5F);
    const Color scaffoldBg = Color(0xFFC5EBEA);
    const Color cardBg = Color(0xFFB9E5E4); // Soft teal card color

    // This list simulates API data
    final List<Map<String, dynamic>> menuGroups = [
      {
        "title": "Account",
        "items": [
          {"icon": Icons.person_outline, "text": "Edit profile", "id": "edit"},
          {"icon": Icons.notifications_none, "text": "Notifications", "id": "notify"},
          {"icon": Icons.lock_outline, "text": "Privacy", "id": "privacy"},
        ]
      },
      {
        "title": "Support & About",
        "items": [
          {"icon": Icons.help_outline, "text": "Help & Support", "id": "help"},
          {"icon": Icons.info_outline, "text": "Find Nearby Medical Stores", "id": "stores"},
          {"icon": Icons.info_outline, "text": "Terms and Policies", "id": "terms"},
        ]
      },
      {
        "title": "Actions",
        "items": [
          {"icon": Icons.outlined_flag, "text": "Report a problem", "id": "report"},
          {"icon": Icons.logout, "text": "Log out", "id": "logout"},
          {"icon": Icons.delete_outline, "text": "Delete Account", "id": "delete"},
        ]
      },
    ];

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // Main Scrollable List
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
            children: [
              const Center(
                child: Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ...menuGroups.map((group) => _buildGroup(group, navyBlue, cardBg)).toList(),
            ],
          ),

          // Right-side Action Stack (Ditto like attachment)
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                _circularButton(Icons.phone_outlined, Colors.white, navyBlue),
                const SizedBox(height: 12),
                _circularButton(Icons.chat_bubble_outline, Colors.white, navyBlue),
                const SizedBox(height: 12),
                _circularButton(Icons.close, navyBlue, Colors.white, isLarge: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(Map<String, dynamic> group, Color textColor, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            group["title"],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3), // Glassy effect matching image
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: (group["items"] as List).map((item) {
              return _menuTile(item["icon"], item["text"], textColor, item["id"]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _menuTile(IconData icon, String text, Color color, String actionId) {
    return ListTile(
      onTap: () {
        // Trigger API Action based on actionId
        debugPrint("Action: $actionId triggered");
      },
      leading: Icon(icon, color: color, size: 26),
      title: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _circularButton(IconData icon, Color bg, Color iconColor, {bool isLarge = false}) {
    return Container(
      width: isLarge ? 60 : 50,
      height: isLarge ? 60 : 50,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Icon(icon, color: iconColor, size: isLarge ? 30 : 22),
    );
  }
}