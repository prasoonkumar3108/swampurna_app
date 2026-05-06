import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final Color navyBlue = const Color(0xFF1E1E5F);
  final Color scaffoldBg = const Color(0xFFE1F5F3);
  final Color labelColor = const Color(0xFF5A6B8A);
  final Color switchOnColor = const Color(0xFF8E9AAF);

  bool _isLoading = true;
  bool _isUpdating = false;
  bool _periodReminderEnabled = false;
  bool _ovulationReminderEnabled = false;
  bool _dailyInsightsEnabled = false;
  bool _appUpdatesEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchNotificationSettings();
  }

  // Strict type-safe boolean parsing function
  bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  Future<void> _fetchNotificationSettings() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authService = AuthService();
      final response = await authService.getNotificationSettings();

      debugPrint(
        "URL: https://swampurna-final-production.up.railway.app/api/v1/notifications/settings",
      );
      debugPrint("Method: GET");
      debugPrint("Response: ${response.data}");

      if (response.success && response.data != null) {
        // Force print raw API response for deep trace
        debugPrint("RAW API RESPONSE: $response");

        // Extract data object - handle different response structures
        Map<String, dynamic>? responseData;
        if (response.data is Map &&
            response.data?.containsKey('data') == true) {
          responseData = response.data!['data'] as Map<String, dynamic>;
        } else if (response.data is Map) {
          responseData = response.data as Map<String, dynamic>;
        } else {
          debugPrint("ERROR: Unexpected response structure");
          setState(() {
            _isLoading = false;
          });
          return;
        }

        debugPrint("EXTRACTED DATA: $responseData");

        setState(() {
          // Strict type-safe boolean parsing
          _periodReminderEnabled = _parseBool(
            responseData?['period_reminder_enabled'],
          );
          _ovulationReminderEnabled = _parseBool(
            responseData?['ovulation_reminder_enabled'],
          );
          _dailyInsightsEnabled = _parseBool(
            responseData?['daily_insights_enabled'],
          );
          _appUpdatesEnabled = _parseBool(responseData?['app_updates_enabled']);
          _isLoading = false;

          // Debug logs for parsed values
          debugPrint("Parsed Period Reminder: $_periodReminderEnabled");
          debugPrint("Parsed Ovulation Reminder: $_ovulationReminderEnabled");
          debugPrint("Parsed Daily Insights: $_dailyInsightsEnabled");
          debugPrint("Parsed App Updates: $_appUpdatesEnabled");
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Failed to load settings'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleSetting(String settingType, bool value) {
    // Immediate state update for smooth UX
    setState(() {
      switch (settingType) {
        case 'period_reminder':
          _periodReminderEnabled = value;
          debugPrint("Toggled period_reminder_enabled to: $value");
          break;
        case 'ovulation_reminder':
          _ovulationReminderEnabled = value;
          debugPrint("Toggled ovulation_reminder_enabled to: $value");
          break;
        case 'daily_insights':
          _dailyInsightsEnabled = value;
          debugPrint("Toggled daily_insights_enabled to: $value");
          break;
        case 'app_updates':
          _appUpdatesEnabled = value;
          debugPrint("Toggled app_updates_enabled to: $value");
          break;
      }
    });
  }

  Future<void> _updateSettings() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final settings = {
        'period_reminder_enabled': _periodReminderEnabled,
        'ovulation_reminder_enabled': _ovulationReminderEnabled,
        'daily_insights_enabled': _dailyInsightsEnabled,
        'app_updates_enabled': _appUpdatesEnabled,
      };

      debugPrint(
        "URL: https://swampurna-final-production.up.railway.app/api/v1/notifications/settings",
      );
      debugPrint("Method: PUT");
      debugPrint("Updating API with: ${jsonEncode(settings)}");

      final authService = AuthService();
      final response = await authService.updateNotificationSettings(
        periodReminderEnabled: _periodReminderEnabled,
        ovulationReminderEnabled: _ovulationReminderEnabled,
        dailyInsightsEnabled: _dailyInsightsEnabled,
        dailyPeriodReminderEnabled:
            false, // Default value since we removed this field
        appUpdatesEnabled: _appUpdatesEnabled,
      );

      debugPrint("Response: ${response.data}");

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to SettingsScreen
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (context.mounted) {
              Navigator.pop(context);
            }
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Failed to update settings'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Simple header with back arrow
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: navyBlue, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF1E1E5F),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cycle Notifications section
                          _buildSectionHeader('Cycle Notifications'),
                          const SizedBox(height: 12),
                          _buildCustomSwitchTile(
                            title: 'Period reminder', // period_reminder_enabled
                            value: _periodReminderEnabled,
                            onChanged: (value) =>
                                _toggleSetting('period_reminder', value),
                          ),
                          _buildCustomSwitchTile(
                            title:
                                'Ovulation reminder', // ovulation_reminder_enabled
                            value: _ovulationReminderEnabled,
                            onChanged: (value) =>
                                _toggleSetting('ovulation_reminder', value),
                          ),

                          const SizedBox(height: 24),

                          // Daily Insights section
                          _buildSectionHeader('Daily Insights'),
                          const SizedBox(height: 12),
                          _buildCustomSwitchTile(
                            title:
                                'Daily insights reminder', // daily_insights_enabled
                            value: _dailyInsightsEnabled,
                            onChanged: (value) =>
                                _toggleSetting('daily_insights', value),
                          ),

                          const SizedBox(height: 24),

                          // General section
                          _buildSectionHeader('General'),
                          const SizedBox(height: 12),
                          _buildCustomSwitchTile(
                            title: 'App updates', // app_updates_enabled
                            value: _appUpdatesEnabled,
                            onChanged: (value) =>
                                _toggleSetting('app_updates', value),
                          ),

                          const SizedBox(height: 40),

                          // Update Button
                          if (_isUpdating)
                            const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF1E1E5F),
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _updateSettings,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: navyBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Update',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                          // Bottom padding
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: navyBlue, // Navy blue/purplish color for headers
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _buildCustomSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    // Verification logging - track state during build
    if (title == 'Period reminder') {
      debugPrint("BUILD: Period Reminder is currently $_periodReminderEnabled");
    } else if (title == 'Ovulation reminder') {
      debugPrint(
        "BUILD: Ovulation Reminder is currently $_ovulationReminderEnabled",
      );
    } else if (title == 'Daily insights reminder') {
      debugPrint("BUILD: Daily Insights is currently $_dailyInsightsEnabled");
    } else if (title == 'App updates') {
      debugPrint("BUILD: App Updates is currently $_appUpdatesEnabled");
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: labelColor, // Light desaturated blue for switch labels
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Touch-friendly switch with larger hit area
          Transform.scale(
            scale: 1.2, // Make switch 20% larger for better touch
            child: GestureDetector(
              onTap: () => onChanged(!value),
              child: Container(
                width: 48,
                height: 24,
                decoration: BoxDecoration(
                  color: value
                      ? switchOnColor
                      : const Color(
                          0xFF9E9E9E,
                        ), // Light blue/grey when ON, grey when OFF
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Align(
                  alignment: value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white, // White thumb
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
