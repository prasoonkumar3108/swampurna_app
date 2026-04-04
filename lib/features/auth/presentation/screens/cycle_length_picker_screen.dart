import 'package:flutter/material.dart';
import 'testimonial_screen.dart';

class CycleLengthPickerScreen extends StatefulWidget {
  const CycleLengthPickerScreen({super.key});

  @override
  State<CycleLengthPickerScreen> createState() =>
      _CycleLengthPickerScreenState();
}

class _CycleLengthPickerScreenState extends State<CycleLengthPickerScreen> {
  // Use a controller to set initial value and manage the "snap"
  late FixedExtentScrollController _controller;

  // Starting value (28 is index 7 in a list starting at 21)
  int selectedValue = 28;
  final List<int> cycleOptions = List.generate(
    20,
    (index) => index + 21,
  ); // 21 to 40

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: 7);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDF3F5), // Light blue background
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text(
              "What is your usual cycle\nlength?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B3A8F), // Deep navy
              ),
            ),
            const Spacer(),

            // Picker Section
            SizedBox(
              height: 350,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // The subtle selection overlay bar
                  Container(
                    height: 70,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EAEB).withOpacity(0.6),
                    ),
                  ),

                  // The actual Wheel Picker
                  ListWheelScrollView.useDelegate(
                    controller: _controller,
                    itemExtent: 70, // Matches container height
                    perspective: 0.006,
                    diameterRatio: 2.0,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedValue = cycleOptions[index];
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: cycleOptions.length,
                      builder: (context, index) {
                        final isSelected = selectedValue == cycleOptions[index];
                        return Center(
                          child: Text(
                            cycleOptions[index].toString(),
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? const Color(0xFF2B3A8F)
                                  : const Color(0xFF2B3A8F).withOpacity(0.3),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // "Continue" Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B3A8F),
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  // Example navigation logic
                  debugPrint("Moving forward with: $selectedValue days");
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => TestimonialScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
