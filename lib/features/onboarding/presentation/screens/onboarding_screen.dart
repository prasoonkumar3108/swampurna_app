import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/services/auth_service.dart';
import '../../../auth/presentation/models/onboarding_data.dart';
import '../../../auth/presentation/screens/tracker_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final OnboardingData? onboardingData;

  const OnboardingScreen({super.key, this.onboardingData});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Map<String, dynamic>? _cycleData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCycleData();
  }

  Future<void> _fetchCycleData() async {
    try {
      final response = await AuthService().getPeriodTrackerSetup();

      if (response.success && response.data != null) {
        setState(() {
          _cycleData = response.data;
          _isLoading = false;
        });
      } else {
        // Use default values if API fails
        setState(() {
          _cycleData = {
            'cycle_length_days': 28,
            'period_length_days': 5,
            'ovulation_start_day': 14,
            'ovulation_window_days': 5,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      // Use default values on error
      setState(() {
        _cycleData = {
          'cycle_length_days': 28,
          'period_length_days': 5,
          'ovulation_start_day': 14,
          'ovulation_window_days': 5,
        };
        _isLoading = false;
      });
    }
  }

  void _navigateToNext() {
    if (!mounted) return;

    // Navigate to TrackerScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TrackerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4), // Soft mint/teal background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Header text
              const Text(
                "Let's begin our journey!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E), // Deep navy blue
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Menstrual Cycle Wheel with floating illustrations
              Expanded(
                flex: 3,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1A237E),
                          ),
                        ),
                      )
                    : _buildCycleWheelWithIllustrations(),
              ),

              const SizedBox(height: 30),

              // Description text
              const Text(
                "Next we'll look at your cycle and fertility",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1A237E), // Navy blue
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Next button - pill shaped
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _navigateToNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E), // Navy blue
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCycleWheelWithIllustrations() {
    if (_cycleData == null) return const SizedBox.shrink();

    final cycleLength = (_cycleData!['cycle_length_days'] as int?) ?? 28;
    final periodLength = (_cycleData!['period_length_days'] as int?) ?? 5;
    final ovulationStartDay =
        (_cycleData!['ovulation_start_day'] as int?) ?? 14;
    final ovulationWindowDays =
        (_cycleData!['ovulation_window_days'] as int?) ?? 5;

    return Stack(
      children: [
        // White horizontal band behind the circle
        Positioned(
          top: 0,
          left: -50,
          right: -50,
          child: Container(
            height: 320,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(160),
                bottom: Radius.circular(160),
              ),
            ),
          ),
        ),

        // Main cycle wheel
        Center(
          child: SizedBox(
            width: 280,
            height: 280,
            child: CustomPaint(
              painter: CycleWheelPainter(
                cycleLength: cycleLength,
                periodLength: periodLength,
                ovulationStartDay: ovulationStartDay,
                ovulationWindowDays: ovulationWindowDays,
              ),
            ),
          ),
        ),

        // Floating illustrations - ovum/cell like elements
        _buildFloatingIllustrations(),
      ],
    );
  }

  Widget _buildFloatingIllustrations() {
    return SizedBox(
      width: double.infinity,
      height: 320,
      child: Stack(
        children: [
          // Top left floating cell
          Positioned(
            top: 20,
            left: 40,
            child: _buildCellIllustration(
              size: 30,
              colors: [
                const Color(0xFFFFB6C1),
                const Color(0xFFFFC0CB),
              ], // Light pink gradient
            ),
          ),

          // Top right floating cell
          Positioned(
            top: 40,
            right: 50,
            child: _buildCellIllustration(
              size: 25,
              colors: [
                const Color(0xFFE6E6FA),
                const Color(0xFFD8BFD8),
              ], // Light purple gradient
            ),
          ),

          // Bottom left floating cell
          Positioned(
            bottom: 30,
            left: 60,
            child: _buildCellIllustration(
              size: 35,
              colors: [
                const Color(0xFFB0E0E6),
                const Color(0xFF87CEEB),
              ], // Sky blue gradient
            ),
          ),

          // Bottom right floating cell
          Positioned(
            bottom: 50,
            right: 40,
            child: _buildCellIllustration(
              size: 28,
              colors: [
                const Color(0xFFFFF0F5),
                const Color(0xFFF0E68C),
              ], // Light peach gradient
            ),
          ),

          // Middle left floating cell
          Positioned(
            top: 120,
            left: 20,
            child: _buildCellIllustration(
              size: 22,
              colors: [
                const Color(0xFFE0FFFF),
                const Color(0xFFB0E0E6),
              ], // Light cyan gradient
            ),
          ),

          // Middle right floating cell
          Positioned(
            top: 100,
            right: 25,
            child: _buildCellIllustration(
              size: 32,
              colors: [
                const Color(0xFFFFF5EE),
                const Color(0xFFFFE4B5),
              ], // Light orange gradient
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCellIllustration({
    required double size,
    required List<Color> colors,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: colors,
          center: Alignment(-0.3, -0.3),
          radius: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.3,
          height: size * 0.3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

class CycleWheelPainter extends CustomPainter {
  final int cycleLength;
  final int periodLength;
  final int ovulationStartDay;
  final int ovulationWindowDays;

  CycleWheelPainter({
    required this.cycleLength,
    required this.periodLength,
    required this.ovulationStartDay,
    required this.ovulationWindowDays,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    final segmentAngle = 2 * math.pi / cycleLength;

    // Draw cycle segments with numbers
    for (int i = 0; i < cycleLength; i++) {
      final startAngle = i * segmentAngle - math.pi / 2;
      final endAngle = (i + 1) * segmentAngle - math.pi / 2;

      Color segmentColor;

      if (i < periodLength) {
        // Period Days (Soft Red)
        segmentColor = const Color(0xFFFFB6C1); // Light pink/soft red
      } else if (i >= ovulationStartDay - 1 &&
          i < ovulationStartDay - 1 + ovulationWindowDays) {
        // Ovulation Window (Light Purple)
        segmentColor = const Color(0xFFE6E6FA); // Light purple
      } else if (i < ovulationStartDay - 1) {
        // Follicular Phase (Peach)
        segmentColor = const Color(0xFFFFF0F5); // Light peach
      } else {
        // Luteal Phase (Sky Blue)
        segmentColor = const Color(0xFFB0E0E6); // Sky blue
      }

      // Draw segment
      final paint = Paint()
        ..color = segmentColor
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      // Draw thin white border between segments
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        borderPaint,
      );

      // Draw number in segment
      final numberAngle = startAngle + segmentAngle / 2;
      final numberRadius = radius * 0.8;
      final numberX = center.dx + numberRadius * math.cos(numberAngle);
      final numberY = center.dy + numberRadius * math.sin(numberAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Color(0xFF1A237E), // Navy blue for numbers
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          numberX - textPainter.width / 2,
          numberY - textPainter.height / 2,
        ),
      );
    }

    // Draw inner circle (pure white background for text)
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.6, innerPaint);

    // Draw center text - smaller, elegant font
    final textPainter = TextPainter(
      text: const TextSpan(
        text: "STAGES OF THE\nMENSTRUAL CYCLE",
        style: TextStyle(
          color: Color(0xFFD81B60), // Dark pink
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.2,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
