import 'package:flutter/material.dart';
import 'cycle_length_picker_screen.dart';

class PeriodDurationPickerScreen extends StatefulWidget {
  final DateTime? selectedDate;

  const PeriodDurationPickerScreen({super.key, this.selectedDate});

  @override
  State<PeriodDurationPickerScreen> createState() =>
      _PeriodDurationPickerScreenState();
}

class _PeriodDurationPickerScreenState
    extends State<PeriodDurationPickerScreen> {
  // Styling constants as per screenshot
  static const Color _bgColor = Color(0xFFD9F2F2);
  static const Color _navyBlue = Color(0xFF1A237E);
  static const Color _highlightBar = Color(0xFFEFEBEB);

  int _selectedDays = 8; // Default selected value
  final FixedExtentScrollController _scrollController =
      FixedExtentScrollController(initialItem: 7); // Index 7 is value 8

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Back Button
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(height: 40),

            // Header Text
            const Text(
              'how long did it last?',
              style: TextStyle(
                color: _navyBlue,
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),

            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Center Highlight Bar
                  Container(
                    height: 60,
                    width: double.infinity,
                    color: _highlightBar.withOpacity(0.6),
                  ),

                  // Wheel Picker Logic
                  GestureDetector(
                    onTap: () => _handleNavigation(), // Middle click navigation
                    child: ListWheelScrollView.useDelegate(
                      controller: _scrollController,
                      itemExtent: 60,
                      perspective: 0.005,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedDays = index + 1;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          int value = index + 1;
                          bool isSelected = _selectedDays == value;

                          return Center(
                            child: Text(
                              '$value',
                              style: TextStyle(
                                fontSize: isSelected ? 34 : 26,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w400,
                                color: isSelected
                                    ? _navyBlue
                                    : _navyBlue.withOpacity(
                                        0.3,
                                      ), // Faded effect
                              ),
                            ),
                          );
                        },
                        childCount: 20, // Max 20 days duration
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Confirm Button (Optional but good for UX)
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: TextButton(
                onPressed: _handleNavigation,
                child: const Text(
                  'Confirm Selection',
                  style: TextStyle(color: _navyBlue, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation() {
    debugPrint(
      "Navigating with: Date: ${widget.selectedDate}, Duration: $_selectedDays days",
    );

    // Replace 'NextScreen' with your actual next screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CycleLengthPickerScreen()),
    );
  }
}
