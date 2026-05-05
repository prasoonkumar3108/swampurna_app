import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/services/auth_service.dart';

// --- STEP 1: FIX THE IMPORT ---
// Agar TrackerScreen isi folder mein hai:
import 'tracker_screen.dart';
// Agar nahi mil rahi, toh is line ko delete karke 'TrackerScreen()' par light bulb click karke auto-import karein.

class MenstrualJourneyScreen extends StatefulWidget {
  const MenstrualJourneyScreen({super.key});

  @override
  State<MenstrualJourneyScreen> createState() => _MenstrualJourneyScreenState();
}

class _MenstrualJourneyScreenState extends State<MenstrualJourneyScreen> {
  // API Integration States
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Period Tracker Setup Data
  int _cycleLengthDays = 28; // Default
  int _periodLengthDays = 5; // Default
  int _ovulationStartDay = 14; // Default
  int _ovulationWindowDays = 5; // Default
  int _prePeriodDays = 2; // Default
  int _postPeriodDays = 2; // Default

  @override
  void initState() {
    super.initState();
    _fetchTrackerSetup();
  }

  // Fetch Tracker Setup from API
  Future<void> _fetchTrackerSetup() async {
    try {
      debugPrint('🔄 Fetching tracker setup from API...');

      final authService = AuthService();
      final response = await authService.fetchPeriodTrackerSetup();

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
            _ovulationWindowDays =
                _extractIntValue(setupData, 'ovulation_window_days') ?? 5;
            _prePeriodDays =
                _extractIntValue(setupData, 'pre_period_days') ?? 2;
            _postPeriodDays =
                _extractIntValue(setupData, 'post_period_days') ?? 2;

            debugPrint(
              '📊 API Data - Cycle: $_cycleLengthDays, Period: $_periodLengthDays, Ovulation: $_ovulationStartDay, Window: $_ovulationWindowDays, Pre: $_prePeriodDays, Post: $_postPeriodDays',
            );

            _isLoading = false;
            _hasError = false;
          });
        } else {
          throw Exception(response.error ?? 'Failed to load tracker setup');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load cycle data. Using default values.';
        });
        debugPrint('❌ Error fetching tracker setup: $e');
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

  @override
  Widget build(BuildContext context) {
    const primaryTextColor = Color(0xFF2E3192);
    const bgColor = Color(0xFFE8F4F8); // Light pastel blue

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // TOP SECTION - 22% height
            Expanded(
              flex: 22,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text(
                    "Let's begin our journey!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // MIDDLE WHITE STRIP - 32% height
            Expanded(
              flex: 32,
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: Center(
                  child: _isLoading
                      ? _buildLoadingIndicator()
                      : _buildCycleChartWithDecorations(),
                ),
              ),
            ),

            // BOTTOM SECTION - 46% height
            Expanded(
              flex: 46,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Next we'll look at your cycle\nand fertility",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  _buildNextButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Next Button - matches screenshot
  Widget _buildNextButton() {
    return SizedBox(
      width: 140,
      height: 42,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TrackerScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E3192),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(21),
          ),
          elevation: 3,
          padding: EdgeInsets.zero,
        ),
        child: const Text(
          "Next",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Cycle chart with decorations - matches expected.jpg
  Widget _buildCycleChartWithDecorations() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartSize = constraints.maxWidth * 0.65;
        return Stack(
          children: [
            // Decorative blobs around chart
            Positioned(
              top: 5,
              left: constraints.maxWidth * 0.15,
              child: _buildDecorativeBlob(Colors.pink.withOpacity(0.2)),
            ),
            Positioned(
              top: 8,
              right: constraints.maxWidth * 0.12,
              child: _buildDecorativeBlob(Colors.purple.withOpacity(0.2)),
            ),
            Positioned(
              top: chartSize * 0.6,
              right: constraints.maxWidth * 0.08,
              child: _buildDecorativeBlob(Colors.blue.withOpacity(0.15)),
            ),
            Positioned(
              bottom: 5,
              left: constraints.maxWidth * 0.18,
              child: _buildDecorativeBlob(Colors.yellow.withOpacity(0.2)),
            ),
            Positioned(
              bottom: 8,
              right: constraints.maxWidth * 0.15,
              child: _buildDecorativeBlob(Colors.green.withOpacity(0.15)),
            ),

            // Main cycle chart
            Center(
              child: Container(
                width: chartSize,
                height: chartSize,
                child: _buildRingCycleChart(chartSize),
              ),
            ),
          ],
        );
      },
    );
  }

  // Decorative blob widget - organic shapes
  Widget _buildDecorativeBlob(Color color) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  // Ring cycle chart - matches expected.jpg with proper ring and center text
  Widget _buildRingCycleChart(double chartSize) {
    return CustomPaint(
      size: Size(chartSize, chartSize),
      painter: RingCyclePainter(
        cycleLength: _cycleLengthDays,
        periodLength: _periodLengthDays,
        ovulationStartDay: _ovulationStartDay,
        ovulationWindowDays: _ovulationWindowDays,
        prePeriodDays: _prePeriodDays,
        postPeriodDays: _postPeriodDays,
      ),
    );
  }

  // Compact cycle chart - MUCH smaller than current
  Widget _buildCompactCycleChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartSize = constraints.maxWidth * 0.6; // Much smaller
        return Container(
          width: chartSize,
          height: chartSize,
          child: Stack(
            children: [
              // Background circle
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF0F8FF), // Soft cycle background
                  border: Border.all(color: const Color(0xFFE1E8ED), width: 2),
                ),
              ),
              // Compact cycle segments
              _buildCompactCycleSegments(chartSize),
              // Center text - simplified
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$_cycleLengthDays",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3192),
                      ),
                    ),
                    const Text(
                      "Day Cycle",
                      style: TextStyle(fontSize: 14, color: Color(0xFF2E3192)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Compact cycle segments
  Widget _buildCompactCycleSegments(double chartSize) {
    return CustomPaint(
      size: Size(chartSize, chartSize),
      painter: CompactCyclePainter(
        cycleLength: _cycleLengthDays,
        periodLength: _periodLengthDays,
        ovulationStartDay: _ovulationStartDay,
        ovulationWindowDays: _ovulationWindowDays,
        prePeriodDays: _prePeriodDays,
        postPeriodDays: _postPeriodDays,
      ),
    );
  }

  // Loading indicator widget
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E3192)),
      ),
    );
  }
}

// Ring Cycle Painter - Proper stroke-based ring rendering
class RingCyclePainter extends CustomPainter {
  final int cycleLength;
  final int periodLength;
  final int ovulationStartDay;
  final int ovulationWindowDays;
  final int prePeriodDays;
  final int postPeriodDays;

  RingCyclePainter({
    required this.cycleLength,
    required this.periodLength,
    required this.ovulationStartDay,
    required this.ovulationWindowDays,
    required this.prePeriodDays,
    required this.postPeriodDays,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 15;
    final innerRadius = outerRadius * 0.65; // Thinner ring
    final segmentAngle = 2 * math.pi / cycleLength;
    final strokeWidth = (outerRadius - innerRadius);

    // Draw ring segments with stroke style
    for (int day = 1; day <= cycleLength; day++) {
      final startAngle = (day - 1) * segmentAngle - math.pi / 2;
      final sweepAngle = segmentAngle;

      final Color segmentColor = _getRingSegmentColor(day);

      // Create stroke paint for ring segment
      final segmentPaint = Paint()
        ..color = segmentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Draw arc segment (stroke creates ring effect)
      final rect = Rect.fromCircle(
        center: center,
        radius: (outerRadius + innerRadius) / 2,
      );
      canvas.drawArc(rect, startAngle, sweepAngle, false, segmentPaint);

      // Draw day number
      _drawDayNumber(
        canvas,
        center,
        outerRadius,
        innerRadius,
        day,
        startAngle,
        sweepAngle,
      );
    }

    // Draw center text
    _drawCenterText(canvas, center, innerRadius);
  }

  Color _getRingSegmentColor(int day) {
    // Colors matching screenshot
    if (day <= periodLength) {
      return const Color(0xFFFF6B9D); // Pink/coral
    }
    if (day <= periodLength + postPeriodDays) {
      return const Color(0xFFDDA0DD); // Peach/light purple
    }
    if (day >= ovulationStartDay &&
        day < ovulationStartDay + ovulationWindowDays) {
      return const Color(0xFF9370DB); // Lavender
    }
    if (day > cycleLength - prePeriodDays) {
      return const Color(0xFFFFD700); // Yellow
    }
    return const Color(0xFF87CEEB); // Light blue
  }

  void _drawDayNumber(
    Canvas canvas,
    Offset center,
    double outerRadius,
    double innerRadius,
    int day,
    double startAngle,
    double sweepAngle,
  ) {
    final midRadius = (outerRadius + innerRadius) / 2;
    final midAngle = startAngle + sweepAngle / 2;
    final textX = center.dx + midRadius * math.cos(midAngle);
    final textY = center.dy + midRadius * math.sin(midAngle);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$day',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
    );
  }

  void _drawCenterText(Canvas canvas, Offset center, double innerRadius) {
    final textStyle = const TextStyle(
      color: Color(0xFFFF6B9D),
      fontSize: 14,
      fontWeight: FontWeight.bold,
      height: 1.2,
    );

    final lines = ["STAGES OF", "THE MENSTRUAL", "CYCLE"];
    final lineHeight = 16.0;
    final totalHeight = lines.length * lineHeight;

    for (int i = 0; i < lines.length; i++) {
      final textPainter = TextPainter(
        text: TextSpan(text: lines[i], style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: innerRadius * 1.5);

      final yOffset =
          center.dy - totalHeight / 2 + i * lineHeight + lineHeight / 2;
      final textX = center.dx - textPainter.width / 2;
      final textY = yOffset - textPainter.height / 2;

      textPainter.paint(canvas, Offset(textX, textY));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Compact Cycle Painter - Smaller version for expected.jpg
class CompactCyclePainter extends CustomPainter {
  final int cycleLength;
  final int periodLength;
  final int ovulationStartDay;
  final int ovulationWindowDays;
  final int prePeriodDays;
  final int postPeriodDays;

  CompactCyclePainter({
    required this.cycleLength,
    required this.periodLength,
    required this.ovulationStartDay,
    required this.ovulationWindowDays,
    required this.prePeriodDays,
    required this.postPeriodDays,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15; // Smaller padding
    final segmentAngle = 2 * math.pi / cycleLength;

    // Draw compact segments
    for (int day = 1; day <= cycleLength; day++) {
      final startAngle = (day - 1) * segmentAngle - math.pi / 2;
      final sweepAngle = segmentAngle;

      final Color segmentColor = _getCompactSegmentColor(day);

      final segmentPaint = Paint()
        ..color = segmentColor
        ..style = PaintingStyle.fill;

      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, startAngle, sweepAngle, true, segmentPaint);

      // Thin border
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawArc(rect, startAngle, sweepAngle, true, borderPaint);
    }
  }

  Color _getCompactSegmentColor(int day) {
    // Softer colors for expected.jpg
    if (day <= periodLength) {
      return const Color(0xFFFFB6C1); // Soft pink
    }
    if (day <= periodLength + postPeriodDays) {
      return const Color(0xFFE1BEE7); // Soft purple
    }
    if (day >= ovulationStartDay &&
        day < ovulationStartDay + ovulationWindowDays) {
      return const Color(0xFF9FA5D5); // Soft purple/blue
    }
    if (day > cycleLength - prePeriodDays) {
      return const Color(0xFFFFE082); // Soft yellow
    }
    return const Color(0xFFE3F2FD); // Soft blue
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Dynamic Cycle Painter - Exact Match to journey_2.jpg
class DynamicCyclePainter extends CustomPainter {
  final int cycleLength;
  final int periodLength;
  final int ovulationStartDay;
  final int ovulationWindowDays;
  final int prePeriodDays;
  final int postPeriodDays;

  DynamicCyclePainter({
    required this.cycleLength,
    required this.periodLength,
    required this.ovulationStartDay,
    required this.ovulationWindowDays,
    required this.prePeriodDays,
    required this.postPeriodDays,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 25; // Account for padding
    final segmentAngle = 2 * math.pi / cycleLength;

    // Draw numbered segments with exact colors from journey_2.jpg
    for (int day = 1; day <= cycleLength; day++) {
      final startAngle = (day - 1) * segmentAngle - math.pi / 2;
      final sweepAngle = segmentAngle;

      // Determine color based on API data
      final Color segmentColor = _getSegmentColor(day);

      // Draw segment
      final paint = Paint()
        ..color = segmentColor
        ..style = PaintingStyle.fill;

      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);

      // Draw segment border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawArc(rect, startAngle, sweepAngle, true, borderPaint);

      // Draw day number
      _drawDayNumber(canvas, center, radius, day, startAngle, sweepAngle);
    }
  }

  // Get segment color based on API data - Exact match to journey_2.jpg
  Color _getSegmentColor(int day) {
    // Period Phase: Days 1 to period_length_days - Orange/Pink gradient
    if (day <= periodLength) {
      return const Color(0xFFFF6B9D); // Pink from screenshot
    }

    // Post-Period Phase: Days period_length_days+1 to period_length_days+post_period_days - Light Purple
    if (day <= periodLength + postPeriodDays) {
      return const Color(0xFFB19CD9); // Light purple from screenshot
    }

    // Fertility Phase: ovulation_start_day to ovulation_start_day+ovulation_window_days-1 - Purple/Blue gradient
    if (day >= ovulationStartDay &&
        day < ovulationStartDay + ovulationWindowDays) {
      return const Color(0xFF6A5ACD); // Purple/Blue from screenshot
    }

    // Pre-Period Phase: Last pre_period_days days - Yellow
    if (day > cycleLength - prePeriodDays) {
      return const Color(0xFFFFD700); // Yellow from screenshot
    }

    // Default: Light Blue (rest of cycle)
    return const Color(0xFF87CEEB); // Light blue from screenshot
  }

  // Draw day number in segment
  void _drawDayNumber(
    Canvas canvas,
    Offset center,
    double radius,
    int day,
    double startAngle,
    double sweepAngle,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$day',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Calculate position for number (middle of segment)
    final angle = startAngle + sweepAngle / 2;
    final textRadius = radius * 0.7; // Position numbers at 70% of radius
    final textX = center.dx + textRadius * math.cos(angle);
    final textY = center.dy + textRadius * math.sin(angle);

    textPainter.paint(
      canvas,
      Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Helper functions for trigonometry
double cos(double angle) => math.cos(angle);
double sin(double angle) => math.sin(angle);
