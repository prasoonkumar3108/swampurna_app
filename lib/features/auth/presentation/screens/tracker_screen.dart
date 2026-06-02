import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/auth_service.dart';
import 'period_calendar_screen.dart';
import 'package:my_app/features/auth/models/onboarding_data.dart';

// Keep these only if the files exist, otherwise the consolidated classes below take over
import 'customize_period_screen.dart';
import 'community_screen.dart';
import 'dynamic_community_screen.dart';
import 'live_stream_screen.dart';
import 'settings_screen.dart';
// (Yahan apni settings file ka sahi path likhein)

// --- Models ---
class CalendarDay {
  final int day;
  final String type;
  CalendarDay({required this.day, required this.type});
}

class TrackerData {
  final String monthTitle;
  final List<CalendarDay> days;
  final List<Map<String, dynamic>>? legend;
  final Map<String, dynamic>? adaptiveMetrics;

  TrackerData({
    required this.monthTitle,
    required this.days,
    this.legend,
    this.adaptiveMetrics,
  });
}

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  int _currentIndex = 0;

  final Color bgColor = const Color(0xFFC5EBEA);
  final Color navyBlue = const Color(0xFF1E1E5F);
  final Color periodPink = const Color(0xFFE91E63);
  final Color postPurple = const Color(0xFF4A148C);
  final Color ovulationGreen = const Color(0xFF388E3C);
  final Color preYellow = const Color(0xFFFFA000);

  late TrackerData apiData;

  // API Integration States
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Period Tracker Setup Data
  int _cycleLengthDays = 28; // Default
  int _periodLengthDays = 5; // Default
  int _ovulationStartDay = 14; // Default

  // Calendar Navigation
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Initialize with default data so UI is never empty
    apiData = _generateDefaultCalendarData();
    _fetchPeriodTrackerSetup();
  }

  // Fetch Period Tracker Setup from API
  Future<void> _fetchPeriodTrackerSetup() async {
    try {
      debugPrint('🔄 Fetching period tracker setup from API...');

      final authService = AuthService();
      final response = await authService.getPeriodTrackerSetup();

      if (mounted) {
        if (response.success && response.data != null) {
          final data = response.data!;
          final setupData = data['data'] ?? data; // Handle nested data

          setState(() {
            // Extract values from API response with fallbacks
            _cycleLengthDays =
                _extractIntValue(setupData, 'cycle_length_days') ?? 28;
            _periodLengthDays =
                _extractIntValue(setupData, 'period_length_days') ?? 5;
            _ovulationStartDay =
                _extractIntValue(setupData, 'ovulation_start_day') ?? 14;

            debugPrint(
              '📊 API Data - Cycle: $_cycleLengthDays, Period: $_periodLengthDays, Ovulation: $_ovulationStartDay',
            );

            // Now fetch calendar data for current month
            _fetchPeriodTrackerSummary();
          });
        } else {
          throw Exception(
            response.error ?? 'Failed to load period tracker setup',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load period data. Using default values.';
          apiData = _generateDefaultCalendarData(); // Fallback to default
          _isLoading = false; // Stop loading on error
        });
        debugPrint('❌ Error fetching period tracker setup: $e');
      }
    }
  }

  // Fetch Period Tracker Summary for current month
  Future<void> _fetchPeriodTrackerSummary() async {
    try {
      final month =
          '${_currentMonth.year.toString().padLeft(4, '0')}-${_currentMonth.month.toString().padLeft(2, '0')}';
      debugPrint('🔄 Fetching period tracker summary for month: $month');

      final authService = AuthService();
      final response = await authService.getPeriodTrackerSummary(month);

      debugPrint('📊 API Response: ${response.data}'); // Debugging log

      if (mounted) {
        if (response.success && response.data != null) {
          final data = response.data!;
          final summaryData = data['data'] ?? data;

          debugPrint('📋 Summary Data: $summaryData'); // Debugging log

          setState(() {
            // Generate calendar data from API summary
            apiData = _generateCalendarDataFromSummary(summaryData);
            _hasError = false;
            _isLoading = false; // Stop loading on success
          });
        } else {
          // If summary API fails, fall back to setup-based generation
          setState(() {
            apiData = _generateCalendarDataFromAPI();
            _hasError = false;
            _isLoading = false; // Stop loading on fallback
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          apiData = _generateCalendarDataFromAPI();
          _hasError = false;
          _isLoading = false; // Stop loading on catch
        });
        debugPrint('❌ Error fetching period tracker summary: $e');
      }
    }
  }

  // Helper method to safely extract integer values
  int? _extractIntValue(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  // Generate calendar data based on API values (fallback)
  TrackerData _generateCalendarDataFromAPI() {
    final List<CalendarDay> days = [];

    // Generate cycle based on API data
    for (int day = 1; day <= _cycleLengthDays; day++) {
      String type = 'none';

      if (day <= _periodLengthDays) {
        type = 'period'; // Period days
      } else if (day <= _periodLengthDays + 2) {
        type = 'post_period'; // Post-period (2 days)
      } else if (day >= _ovulationStartDay && day < _ovulationStartDay + 5) {
        type = 'peak_ovulation'; // Ovulation phase (5 days)
      } else if (day > _cycleLengthDays - 3) {
        type = 'pre_period'; // Pre-period (3 days)
      }

      days.add(CalendarDay(day: day, type: type));
    }

    return TrackerData(
      monthTitle: DateFormat('MMM yyyy').format(_currentMonth).toUpperCase(),
      days: days,
    );
  }

  // Generate calendar data from API summary response
  TrackerData _generateCalendarDataFromSummary(
    Map<String, dynamic> summaryData,
  ) {
    final List<CalendarDay> days = [];

    // Debugging: Check the structure
    debugPrint('📝 SummaryData keys: ${summaryData.keys}');

    // Try to access days array correctly
    final daysArray = summaryData['days'] as List<dynamic>? ?? [];
    final legend = summaryData['legend'] as List<Map<String, dynamic>>?;
    final adaptiveMetrics =
        summaryData['adaptive_metrics'] as Map<String, dynamic>?;

    debugPrint('📅 Days array length: ${daysArray.length}');

    // Map API days to calendar days
    for (final dayData in daysArray) {
      if (dayData is Map<String, dynamic>) {
        final dateStr = dayData['date'] as String? ?? '';
        final primaryStatus = dayData['primary_status'] as String? ?? 'none';

        debugPrint('🔍 Day data: $dayData');

        // Extract day number from date (assuming format YYYY-MM-DD)
        final dayNumber = int.tryParse(dateStr.split('-').last) ?? 1;

        days.add(CalendarDay(day: dayNumber, type: primaryStatus));
      }
    }

    // If no days from API, use fallback
    if (days.isEmpty) {
      debugPrint('⚠️ No days from API, using fallback');
      return _generateCalendarDataFromAPI();
    }

    return TrackerData(
      monthTitle: DateFormat('MMM yyyy').format(_currentMonth).toUpperCase(),
      days: days,
      legend: legend,
      adaptiveMetrics: adaptiveMetrics,
    );
  }

  // Generate default calendar data (fallback)
  TrackerData _generateDefaultCalendarData() {
    final now = DateTime.now();
    final monthNames = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];

    return TrackerData(
      monthTitle: DateFormat('MMM yyyy').format(now).toUpperCase(),
      days: [
        // All days in neutral gray state when API fails
        ...List.generate(31, (i) => CalendarDay(day: i + 1, type: 'none')),
      ],
    );
  }

  // Month navigation methods
  void _navigateToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _fetchPeriodTrackerSummary(); // Fetch data for new month
    });
  }

  void _navigateToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _fetchPeriodTrackerSummary(); // Fetch data for new month
    });
  }

  void navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style to prevent system navigation bar interference
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor:
            Colors.transparent, // Make system nav bar transparent
        systemNavigationBarDividerColor: Colors.transparent, // Remove divider
        systemNavigationBarIconBrightness:
            Brightness.dark, // Dark icons for light theme
      ),
    );

    // Enable edge-to-edge mode to ensure app draws behind system bars correctly
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      backgroundColor: _currentIndex == 3 ? const Color(0xFF121212) : bgColor,
      extendBody:
          true, // Allow body to extend behind bottom nav bar with rounded corners
      resizeToAvoidBottomInset:
          false, // Prevent keyboard/system bars from pushing UI up
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildTrackerUI(), // Index 0
          const CommunityScreen(), // Index 1
          const DynamicCommunityScreen(), // Index 2
          const LiveStreamScreen(), // Index 3
          SettingsScreen(), // Index 4
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 70.0),
              child: FloatingActionButton(
                heroTag: "tracker_fab",
                onPressed: () => navigateTo(const CustomizePeriod()),
                backgroundColor: navyBlue,
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            )
          : null,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- INDEX 0: MAIN TRACKER UI ---
  Widget _buildTrackerUI() {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Show loading state while API data is being fetched
    if (_isLoading) {
      return SafeArea(
        child: Center(
          child: CircularProgressIndicator(color: navyBlue, strokeWidth: 3),
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Column(
            children: [
              _buildTopWarningBar(),
              _buildMainHeader(),
              _buildCalendarCard(screenWidth),
              if (_hasError) _buildErrorBanner(),
              _buildLegendSection(),
              const SizedBox(height: 10),
              _buildActionBtn("Edit period dates"),
              _buildInsightsSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // Error banner for API failures
  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopWarningBar() {
    // Show limited data banner based on adaptive_metrics
    final samplesUsedForCycle =
        apiData.adaptiveMetrics?['samples_used_for_cycle'] ?? 1;
    final shouldShowBanner = samplesUsedForCycle == 0;

    if (!shouldShowBanner) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Your predictions are based on limited data...",
              style: TextStyle(
                fontSize: 11,
                color: navyBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => navigateTo(const CustomizePeriod()),
            style: ElevatedButton.styleFrom(
              backgroundColor: navyBlue,
              minimumSize: const Size(60, 30),
            ),
            child: const Text(
              "Edit",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _navigateToPreviousMonth,
            icon: Icon(Icons.chevron_left, color: navyBlue, size: 30),
          ),
          Text(
            'Your Tracker',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: navyBlue,
            ),
          ),
          IconButton(
            onPressed: _navigateToNextMonth,
            icon: Icon(Icons.chevron_right, color: navyBlue, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(double width) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            apiData.monthTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: navyBlue,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          _buildWeekdayLabels(),
          const Divider(thickness: 1, indent: 10, endIndent: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: apiData.days.length,
            itemBuilder: (context, index) => _calendarCell(apiData.days[index]),
          ),
          Container(
            height: 30,
            width: double.infinity,
            color: navyBlue.withOpacity(0.9),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: labels
          .map(
            (l) => Text(
              l,
              style: TextStyle(fontWeight: FontWeight.bold, color: navyBlue),
            ),
          )
          .toList(),
    );
  }

  Widget _calendarCell(CalendarDay info) {
    Color circleColor = _getColorForStatus(info.type);

    return Center(
      child: Container(
        decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
        padding: const EdgeInsets.all(8),
        child: Text(
          "${info.day}",
          style: TextStyle(
            color: info.type == 'none' ? Colors.black87 : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendSection() {
    // Use API legend if available, otherwise use default
    final legendItems =
        apiData.legend ??
        [
          {'color': 'pre_period', 'label': 'Pre-Period'},
          {'color': 'period', 'label': 'Period Days'},
          {'color': 'post_period', 'label': 'Post-Period'},
          {'color': 'peak_ovulation', 'label': 'Peak Ovulation'},
        ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 20,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: legendItems.map((item) {
          final colorKey = item['color'] as String? ?? 'none';
          final label = item['label'] as String? ?? 'Unknown';
          final color = _getColorForStatus(colorKey);
          return _legendItem(color, label);
        }).toList(),
      ),
    );
  }

  // Helper method to map status to color
  Color _getColorForStatus(String status) {
    switch (status) {
      case 'period':
        return periodPink; // Magenta/Pink
      case 'pre_period':
        return preYellow; // Yellow/Orange
      case 'post_period':
        return postPurple; // Purple
      case 'peak_ovulation':
        return ovulationGreen; // Green
      default:
        return Colors.grey;
    }
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 7, backgroundColor: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: navyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn(String text) {
    return ElevatedButton(
      onPressed: () {
        if (text == "Edit period dates") {
          debugPrint('STEP 1: Tracker -> Calendar');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PeriodCalendarScreen(
                onboardingData: OnboardingData(
                  email: '', // Not required for the setup endpoint
                  otp: '',   // Not required for the setup endpoint
                  lastPeriodDate: DateTime.now(),
                  periodDuration: _periodLengthDays,
                  cycleLength: _cycleLengthDays,
                ),
                isEditMode: true,
              ),
            ),
          ).then((_) {
            // Refresh data when returning from the edit flow
            _fetchPeriodTrackerSetup();
          });
        } else {
          navigateTo(const CustomizePeriod());
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: navyBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Menstrual Health Tips",
            style: TextStyle(
              color: navyBlue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _insightCard(
                "Flow Types &\nHydration",
                Icons.water_drop_outlined,
              ),
              _insightCard("Period-Friendly\nNutrition", Icons.restaurant_menu),
              _insightCard("Exercise &\nMovement", Icons.fitness_center),
            ],
          ),
        ),
      ],
    );
  }

  Widget _insightCard(String title, IconData icon) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: navyBlue, width: 2),
            ),
            child: Icon(icon, size: 40, color: Colors.orangeAccent),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: navyBlue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: navyBlue,
          boxShadow: [], // Remove any shadow
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navIcon('assets/images/ftab.png', 0),
              _navIcon('assets/images/stab.png', 1),
              _navIcon('assets/images/ttab.png', 2),
              _navIcon('assets/images/frtab.png', 3),
              _navIcon('assets/images/fftab.png', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navIcon(String assetPath, int index) {
    bool isActive = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Image.asset(
          assetPath,
          height: 24,
          width: 24,
          color: isActive ? const Color(0xFFE67E22) : Colors.grey[400],
        ),
      ),
    );
  }
}

// =============================================================================
// RESTORED SUB-SCREENS (Consolidated to avoid "Not Defined" errors)
// =============================================================================

class CommunityContentScreen extends StatelessWidget {
  const CommunityContentScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final Color navyBlue = const Color(0xFF1E1E5F);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Trending Now", navyBlue),
          _buildRow(["Cycle Phases", "Blood Color", "Cramps"]),
          _buildHeader("Guides", navyBlue),
          _buildRow(["Late Period", "Flow Types", "PMS vs PMDD"]),
        ],
      ),
    );
  }

  Widget _buildHeader(String t, Color c) => Padding(
    padding: const EdgeInsets.all(20),
    child: Text(
      t,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c),
    ),
  );

  Widget _buildRow(List<String> items) => SizedBox(
    height: 200,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemCount: items.length,
      itemBuilder: (context, i) => Container(
        width: 150,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          image: const DecorationImage(
            image: NetworkImage('https://via.placeholder.com/150x200'),
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            items[i],
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}

class LiveStreamScreen extends StatelessWidget {
  const LiveStreamScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121212),
      child: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            color: Colors.grey[900],
            child: const Icon(
              Icons.play_circle_fill,
              size: 80,
              color: Colors.white,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "Live Events",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
