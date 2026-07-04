import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/auth_service.dart';
import 'period_calendar_screen.dart';
import 'package:my_app/features/auth/models/onboarding_data.dart';
import 'customize_period_screen.dart';
import 'community_screen.dart';
import 'dynamic_community_screen.dart';
import 'live_stream_screen.dart';
import 'settings_screen.dart';
import 'package:my_app/features/auth/models/article_model.dart';
import 'tracker_article_detail_screen.dart';

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

  final Color bgTop = const Color(0xFFDDEAF8);
  final Color bgBottom =  const Color(0xFFF7F8FB);
  final Color navyBlue = const Color(0xFF4A4F7C);
  final Color periodPink = const Color(0xFFE34B7E);
  final Color postPurple = const Color(0xFF5D2A86);
  final Color ovulationGreen = const Color(0xFF78B58E);
  final Color preYellow = const Color(0xFFF0A33A);

  final Color outerBlue = const Color(0xFFD7E6FB);
  final Color cardBg = const Color(0xFFF7F3ED);

  late TrackerData apiData;

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  int _cycleLengthDays = 28;
  int _periodLengthDays = 5;
  int _ovulationStartDay = 14;

  DateTime _currentMonth = DateTime.now();
 List<TrackerArticle> _articles = [];

  @override
  void initState() {
    super.initState();
    apiData = _generateDefaultCalendarData();
    _fetchPeriodTrackerSetup();
    _fetchArticles();
  }

Future<void> _fetchArticles() async {
  try {
    final authService = AuthService();
    final response = await authService.getPeriodTrackerArticles();
    if (mounted && response.success && response.data != null) {
      setState(() {
        _articles = response.data!;
      });
    }
  } catch (e) {
    debugPrint("❌ Error fetching articles: $e");
  }
}

  Future<void> _fetchPeriodTrackerSetup() async {
    try {
      final authService = AuthService();
      final response = await authService.getPeriodTrackerSetup();
      if (mounted) {
        if (response.success && response.data != null) {
          final data = response.data!;
          final setupData = data['data'] ?? data;
          setState(() {
            _cycleLengthDays = _extractIntValue(setupData, 'cycle_length_days') ?? 28;
            _periodLengthDays = _extractIntValue(setupData, 'period_length_days') ?? 5;
            _ovulationStartDay = _extractIntValue(setupData, 'ovulation_start_day') ?? 14;
          });
          await _fetchPeriodTrackerSummary();
        } else {
          throw Exception(response.error ?? 'Failed to load period tracker setup');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load period data. Using default values.';
          apiData = _generateDefaultCalendarData();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchPeriodTrackerSummary() async {
    try {
      final month =
          '${_currentMonth.year.toString().padLeft(4, '0')}-${_currentMonth.month.toString().padLeft(2, '0')}';
      final authService = AuthService();
      final response = await authService.getPeriodTrackerSummary(month);

      if (mounted) {
        if (response.success && response.data != null) {
          final data = response.data!;
          final summaryData = data['data'] ?? data;
          setState(() {
            apiData = _generateCalendarDataFromSummary(summaryData);
            _hasError = false;
            _isLoading = false;
          });
        } else {
          setState(() {
            apiData = _generateCalendarDataFromAPI();
            _hasError = false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          apiData = _generateCalendarDataFromAPI();
          _hasError = false;
          _isLoading = false;
        });
      }
    }
  }

  int? _extractIntValue(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  TrackerData _generateCalendarDataFromAPI() {
    final List<CalendarDay> days = [];
    for (int day = 1; day <= _cycleLengthDays; day++) {
      String type = 'none';
      if (day <= _periodLengthDays) {
        type = 'period';
      } else if (day <= _periodLengthDays + 2) {
        type = 'post_period';
      } else if (day >= _ovulationStartDay && day < _ovulationStartDay + 5) {
        type = 'peak_ovulation';
      } else if (day > _cycleLengthDays - 3) {
        type = 'pre_period';
      }
      days.add(CalendarDay(day: day, type: type));
    }

    return TrackerData(
      monthTitle: DateFormat('MMM yyyy').format(_currentMonth).toUpperCase(),
      days: days,
    );
  }

  TrackerData _generateCalendarDataFromSummary(Map<String, dynamic> summaryData) {
    final List<CalendarDay> days = [];
    final daysArray = summaryData['days'] as List<dynamic>? ?? [];
    final legend = summaryData['legend'] as List<Map<String, dynamic>>?;
    final adaptiveMetrics =
        summaryData['adaptive_metrics'] as Map<String, dynamic>?;

    for (final dayData in daysArray) {
      if (dayData is Map<String, dynamic>) {
        final dateStr = dayData['date'] as String? ?? '';
        final primaryStatus = dayData['primary_status'] as String? ?? 'none';
        final dayNumber = int.tryParse(dateStr.split('-').last) ?? 1;
        days.add(CalendarDay(day: dayNumber, type: primaryStatus));
      }
    }

    if (days.isEmpty) return _generateCalendarDataFromAPI();

    return TrackerData(
      monthTitle: DateFormat('MMM yyyy').format(_currentMonth).toUpperCase(),
      days: days,
      legend: legend,
      adaptiveMetrics: adaptiveMetrics,
    );
  }

  TrackerData _generateDefaultCalendarData() {
    final now = DateTime.now();
    return TrackerData(
      monthTitle: DateFormat('MMM yyyy').format(now).toUpperCase(),
      days: List.generate(31, (i) => CalendarDay(day: i + 1, type: 'none')),
    );
  }

  void _navigateToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _fetchPeriodTrackerSummary();
  }

  void _navigateToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _fetchPeriodTrackerSummary();
  }

  void navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgTop, bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _mainTrackerView(),
              const CommunityScreen(),
              const DynamicCommunityScreen(),
              const LiveStreamScreen(),
              SettingsScreen(),
            ],
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: FloatingActionButton(
                heroTag: 'tracker_fab',
                onPressed: () => navigateTo(const CustomizePeriod()),
                backgroundColor: const Color(0xFF3A4685),
                elevation: 6,
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _mainTrackerView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
        // 🔹 Top message with styled Edit button
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          "Your predictions are based on limited data.\nAdd a few details to improve accuracy.",
          style: TextStyle(
            color: navyBlue,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomizePeriod(),
            ),
          ).then((_) => _fetchPeriodTrackerSetup());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, // ✅ Blue background
          foregroundColor: Colors.white, // ✅ White text
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // ✅ Rounded corners
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        ),
        child: const Text(
          "Edit",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    ],
  ),
),

          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: outerBlue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _headerRow(),
                    ),
                    const SizedBox(height: 10),
                    _calendarCard(),
                    const SizedBox(height: 18),
                    _legendBelowCard(),
                    // यहाँ से पुराने बटन और Transform.translate को हटाकर नीचे Stack में Positioned किया है
                    const SizedBox(height: 48), // बटन के स्पेस के लिए पैडिंग बढ़ाई गई है
                  ],
                ),
              ),
              // बटन को बिल्कुल सेंटर-बॉटम बॉर्डर पर रखने के लिए Positioned विजेट
              Positioned(
                bottom: -28, // बटन की ऊंचाई (56) का ठीक आधा, जिससे यह वर्टिकली सेंटर अलाइन होगा
                left: 0,
                right: 0,
                child: Center(
                  child: _editButtonOnBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30), // बटन के ओवरफ्लो होने के कारण नीचे के सेक्शन से स्पेस को एडजस्ट किया गया
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _tipsSectionOutside(),
          ),
          const SizedBox(height: 0),
        ],
      ),
    );
  }

  Widget _headerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _navigateToPreviousMonth,
          icon: Icon(Icons.chevron_left, color: navyBlue, size: 32),
        ),
        Text(
          'Your Tracker',
          style: TextStyle(
            color: navyBlue,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: _navigateToNextMonth,
          icon: Icon(Icons.chevron_right, color: navyBlue, size: 32),
        ),
      ],
    );
  }

  Widget _calendarCard() {
    final width = MediaQuery.of(context).size.width - 32;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
        child: Column(
          children: [
            Text(
              DateFormat('MMM yyyy').format(_currentMonth).toUpperCase(),
              style: TextStyle(
                color: navyBlue,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 18),
            _weekdayRow(),
            const SizedBox(height: 12),
            Container(height: 1, color: Colors.black.withOpacity(0.08)),
            const SizedBox(height: 18),
            _calendarAlignedGrid(width - 36),
          ],
        ),
      ),
    );
  }

  Widget _weekdayRow() {
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map(
            (l) => Expanded(
              child: Center(
                child: Text(
                  l,
                  style: TextStyle(
                    color: navyBlue.withOpacity(0.75),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _calendarAlignedGrid(double availableWidth) {
    final firstOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final startWeekday = firstOfMonth.weekday % 7;
    final daysInMonth =
        DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);

    final List<CalendarDay?> slots = [];
    for (int i = 0; i < startWeekday; i++) slots.add(null);

    final Map<int, CalendarDay> byDay = {for (var d in apiData.days) d.day: d};
    for (int d = 1; d <= daysInMonth; d++) {
      slots.add(byDay[d] ?? CalendarDay(day: d, type: 'none'));
    }

    while (slots.length % 7 != 0) slots.add(null);

    const double spacing = 10;
    final double cellSize = (availableWidth - (6 * spacing)) / 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, idx) {
        final CalendarDay? slot = slots[idx];
        if (slot == null) return const SizedBox();
        return _calendarDayCircle(slot, cellSize);
      },
    );
  }

  Widget _calendarDayCircle(CalendarDay info, double size) {
    final bool isNone = info.type == 'none';
    final Color bg = isNone ? const Color(0xFFCDCDCD) : _getColorForStatus(info.type);
    final Color txt = isNone ? const Color(0xFF424242) : Colors.white;

    return Center(
      child: Container(
        height: size * 0.8,
        width: size * 0.8,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '${info.day}',
          style: TextStyle(
            color: txt,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _legendBelowCard() {
    final legendItems = apiData.legend ??
        [
          {'color': 'pre_period', 'label': 'Pre-Period'},
          {'color': 'period', 'label': 'Period Days'},
          {'color': 'post_period', 'label': 'Post-Period'},
          {'color': 'peak_ovulation', 'label': 'Peak Ovulation'},
        ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 18,
        runSpacing: 12,
        children: legendItems.map((item) {
          final colorKey = item['color'] as String? ?? 'none';
          final label = item['label'] as String? ?? 'Unknown';
          final color = _getColorForStatus(colorKey);

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 14,
                width: 14,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: navyBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _editButtonOnBorder() {
    // बटन की जटिलता और अलाइनमेंट को क्लीन रखने के लिए LayoutBuilder को हटाकर सीधे साफ-सुथरा साइज्ड विजेट दिया गया है
    return SizedBox(
      width: 220,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PeriodCalendarScreen(
                onboardingData: OnboardingData(
                  email: '',
                  otp: '',
                  lastPeriodDate: DateTime.now(),
                  periodDuration: _periodLengthDays,
                  cycleLength: _cycleLengthDays,
                ),
                isEditMode: true,
              ),
            ),
          ).then((_) => _fetchPeriodTrackerSetup());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF7F3ED),
          foregroundColor: navyBlue,
          elevation: 8,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Edit period dates',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _tipsSectionOutside() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(8, 18, 8, 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menstrual Health Tips (Daily Insights)',
          style: TextStyle(
            color: navyBlue,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),

  SizedBox(
    height: 170,
    child: _articles.isEmpty
        ? const Center(child: Text("No tips available"))
        : ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _articles.length,
            itemBuilder: (context, index) {
              final article = _articles[index];
              return _insightCard(Icons.lightbulb, const Color(0xFFF4C05A), article.title,article.slug);
            },
          ),
  ),
      ],
    ),
  );
}

Widget _insightCard(IconData icon, Color iconColor, String title, String slug) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrackerArticleDetailScreen(slug: slug),
        ),
      );
    },
    child: Container(
      width: 140,
      margin: const EdgeInsets.only(right: 0,left: 0),
      child: Column(
        children: [
          Container(
            height: 104,
            width: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: Colors.blue, // border color
                width: 2,           // border width
              ),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 38),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 50, // fixed height for text area
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: navyBlue,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
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
        color: navyBlue,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
            top: 8,
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
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Image.asset(
          assetPath,
          height: 26,
          width: 26,
          color: isActive ? const Color(0xFFF0A63A) : Colors.grey,
        ),
      ),
    );
  }

  Color _getColorForStatus(String status) {
    switch (status) {
      case 'period':
        return periodPink;
      case 'pre_period':
        return preYellow;
      case 'post_period':
        return postPurple;
      case 'peak_ovulation':
        return ovulationGreen;
      default:
        return Colors.grey.shade300;
    }
  }
}