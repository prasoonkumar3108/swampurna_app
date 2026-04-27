import 'package:flutter/material.dart';
// IMPORT: Ensure karein ki ye path aapke project folder structure se match kare
import 'pregnancy_selection_screen.dart';

class BirthYearPickerScreen extends StatefulWidget {
  final Map<String, dynamic> onboardingData;

  const BirthYearPickerScreen({super.key, required this.onboardingData});

  @override
  State<BirthYearPickerScreen> createState() => _BirthYearPickerScreenState();
}

class _BirthYearPickerScreenState extends State<BirthYearPickerScreen> {
  late FixedExtentScrollController _scrollController;
  int _selectedYear = 2000;
  bool _hasScrolledAtLeastOnce = false;

  static const Color _backgroundColor = Color(0xFFD9F2F2);
  static const Color _primaryText = Color(0xFF1A237E);
  static const Color _selectionOverlayColor = Color(0xFFF2EBEB);

  final List<int> _years = List.generate(101, (index) => 1950 + index);

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(
      initialItem: _years.indexOf(2000),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // REVISED: Method for cleaner navigation
  void _onNextPressed() {
    debugPrint("Navigating with year: $_selectedYear");

    // Update onboarding data with birth year
    final updatedData = Map<String, dynamic>.from(widget.onboardingData);
    updatedData['birthYear'] = _selectedYear;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PregnancySelectionScreen(onboardingData: updatedData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildHeaderSection(),
                    const Spacer(),
                    _buildYearPicker(),
                    const Spacer(),
                    _buildNextButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 8),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: const [
        Text(
          'When were you born?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _primaryText,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Your cycle can change with age.\nKnowing it helps make better\npredictions.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _primaryText, fontSize: 18, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildYearPicker() {
    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _selectionOverlayColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification &&
                  !_hasScrolledAtLeastOnce) {
                setState(() => _hasScrolledAtLeastOnce = true);
              }
              return true;
            },
            child: ListWheelScrollView.useDelegate(
              controller: _scrollController,
              itemExtent: 60,
              perspective: 0.005,
              diameterRatio: 1.4,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) =>
                  setState(() => _selectedYear = _years[index]),
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: _years.length,
                builder: (context, index) {
                  final year = _years[index];
                  final isSelected = year == _selectedYear;
                  return Center(
                    child: (isSelected && !_hasScrolledAtLeastOnce)
                        ? const Text(
                            'Select',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: _primaryText,
                            ),
                          )
                        : Text(
                            '$year',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isSelected
                                  ? _primaryText
                                  : _primaryText.withOpacity(0.2),
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: _onNextPressed, // Method call fix
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Next',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
