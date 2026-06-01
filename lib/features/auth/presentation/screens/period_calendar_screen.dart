import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'period_duration_picker_screen.dart';
import 'package:my_app/features/auth/models/onboarding_data.dart';

class PeriodCalendarScreen extends StatefulWidget {
  final OnboardingData onboardingData;

  const PeriodCalendarScreen({super.key, required this.onboardingData});

  @override
  State<PeriodCalendarScreen> createState() => _PeriodCalendarScreenState();
}

class _PeriodCalendarScreenState extends State<PeriodCalendarScreen> {
  static const Color _bgColor = Color(0xFFD9F2F2);
  static const Color _navyBlue = Color(0xFF1A237E);
  static const Color _pinkBox = Color(0xFFF3A0CE);

  final List<DateTime> _selectedDates = [];
  late ScrollController _scrollController;

  bool _isNoIdeaSelected = false;
  final List<DateTime> _months = [];

  @override
  void initState() {
    super.initState();
    // Estimated height of one month section (~380px) to center index 6 (current month)
    _scrollController = ScrollController(initialScrollOffset: 6 * 380.0);
    _generate12Months();
  }

  void _generate12Months() {
    DateTime now = DateTime.now();
    for (int i = -6; i <= 6; i++) {
      _months.add(DateTime(now.year, now.month + i, 1));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  // Common Navigation Helper
  void _navigateToDurationPicker(DateTime? date) {
    final updatedData = widget.onboardingData.copyWith(
      lastPeriodDate: date,
      hasNoIdea: _isNoIdeaSelected,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PeriodDurationPickerScreen(onboardingData: updatedData),
      ),
    );
  }

  void _onDateClicked(DateTime date) {
    setState(() {
      _isNoIdeaSelected = false;
      final existingIndex = _selectedDates.indexWhere((d) => isSameDay(d, date));
      if (existingIndex >= 0) {
        _selectedDates.removeAt(existingIndex);
      } else {
        _selectedDates.add(date);
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _onContinue() {
    if (_selectedDates.isEmpty) {
      _showSnackBar("At least 1 date must be selected.");
      return;
    }
    // Pass the earliest selected date to maintain compatibility with single-date model logic
    final earliestDate = _selectedDates.reduce((a, b) => a.isBefore(b) ? a : b);
    _navigateToDurationPicker(earliestDate);
  }

  // FIX: handleNoIdea added and implemented
  void _handleNoIdea() {
    setState(() {
      _isNoIdeaSelected = true;
      _selectedDates.clear();
    });
    // Navigation for 'No Idea' - passing null as date
    _navigateToDurationPicker(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            const Text(
              'You can select your last period',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _navyBlue,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Calendar',
              style: TextStyle(color: _navyBlue, fontSize: 16),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _months.length,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: _buildMonthSection(_months[index]),
                  );
                },
              ),
            ),
            _buildContinueButton(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildMonthSection(DateTime monthDate) {
    String monthLabel = DateFormat('MMMM yyyy').format(monthDate);
    int daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    int firstDayOffset = monthDate.weekday % 7;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: _navyBlue, width: 1.2),
            ),
          ),
          child: Text(
            monthLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _navyBlue,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        _buildWeekdayHeader(),
        _buildDateGrid(daysInMonth, firstDayOffset, monthDate),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      children: days
          .map(
            (d) => Expanded(
              child: Container(
                height: 35,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: _navyBlue.withOpacity(0.1)),
                ),
                child: Text(
                  d,
                  style: const TextStyle(
                    color: _navyBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDateGrid(int totalDays, int offset, DateTime monthDate) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: totalDays + offset,
      itemBuilder: (context, index) {
        if (index < offset) return const SizedBox.shrink();
        int dayValue = index - offset + 1;
        final date = DateTime(monthDate.year, monthDate.month, dayValue);
        final isSelected = _selectedDates.any((d) => isSameDay(d, date));

        return InkResponse(
          onTap: () => _onDateClicked(date),
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isSelected ? _navyBlue : _pinkBox,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _navyBlue.withOpacity(0.1)),
            ),
            alignment: Alignment.center,
            child: Text(
              '$dayValue',
              style: TextStyle(
                color: isSelected ? Colors.white : _navyBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContinueButton() {
    final bool isValid = _selectedDates.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isValid ? _onContinue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _navyBlue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _navyBlue.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _navyBlue)),
      ),
      child: InkWell(
        // Implementation: Direct call to handleNoIdea
        onTap: _handleNoIdea,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isNoIdeaSelected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: _navyBlue,
            ),
            const SizedBox(width: 10),
            const Text(
              'I have no idea',
              style: TextStyle(
                color: _navyBlue,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
