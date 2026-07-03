
import 'dart:convert';

import 'package:flutter/material.dart';
import 'testimonial_screen.dart';
import 'package:my_app/features/auth/models/onboarding_data.dart';
import '../../../../core/services/auth_service.dart';
import '../../models/period_setup_request.dart';
import '../../../auth/presentation/screens/tracker_screen.dart';

class CycleLengthPickerScreen extends StatefulWidget {
  final OnboardingData onboardingData;
  final bool isEditMode;

  const CycleLengthPickerScreen({
    super.key,
    required this.onboardingData,
    this.isEditMode = false,
  });

  @override
  State<CycleLengthPickerScreen> createState() =>
      _CycleLengthPickerScreenState();
}

class _CycleLengthPickerScreenState
    extends State<CycleLengthPickerScreen> {
  late FixedExtentScrollController _controller;

  int selectedValue = 28;

  final List<int> cycleOptions =
      List.generate(20, (index) => index + 21);

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    debugPrint(
      'EDIT FLOW: CycleLengthPickerScreen | isEditMode = ${widget.isEditMode}',
    );

    selectedValue =
        widget.onboardingData.cycleLength ?? 28;

    final initialIndex =
        cycleOptions.indexOf(selectedValue);

    _controller = FixedExtentScrollController(
      initialItem:
          initialIndex >= 0 ? initialIndex : 7,
    );

    Future.delayed(const Duration(seconds: 1), () {
    if (mounted) {
      _controller.animateToItem(
        9, // for example index 9 = value 10
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  });
  Future.delayed(const Duration(seconds: 2), () {
  if (mounted) {
    _controller.animateToItem(
      7, // back to default index = value 8
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }
});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();

      final updatedData =
          widget.onboardingData.copyWith(
        cycleLength: selectedValue,
      );

      if (widget.isEditMode) {
        // ==========================
        // EDIT FLOW
        // ==========================

        debugPrint(
          'EDIT FLOW: Updating period tracker',
        );

        final response =
            await authService.updatePeriodTracker(
          cycleLength: selectedValue,
          periodLength:
              updatedData.periodDuration ?? 8,
        );

        if (!mounted) return;

        if (response.success) {
          debugPrint(
            'EDIT FLOW SUCCESS',
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TrackerScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                response.error ??
                    'Failed to update tracker',
              ),
            ),
          );
        }
      } else {
        // ==========================
        // ONBOARDING FLOW
        // ==========================

        final request =
            PeriodSetupRequest(
          lastPeriodStartDate:
              updatedData.lastPeriodDate,
          hasNoIdea:
              updatedData.hasNoIdea ?? false,
          periodLengthDays:
              updatedData.periodDuration ?? 8,
          cycleLengthDays: selectedValue,
        );

        debugPrint(
          'REQUEST PAYLOAD => ${jsonEncode(request.toJson())}',
        );

        final response =
            await authService
                .setupPeriodTracker(
          request,
        );

        if (!mounted) return;

        if (response.success) {
          debugPrint(
            'ONBOARDING FLOW SUCCESS',
          );

          Navigator.of(
            context,
            rootNavigator: true,
          ).push(
            MaterialPageRoute(
              builder: (_) =>
                  TestimonialScreen(
                onboardingData:
                    updatedData,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                response.error ??
                    'Setup failed. Please try again.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint(
        'Cycle Length Screen Error: $e',
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'Something went wrong: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(
          () => _isLoading = false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFDDF3F5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),

            const Text(
              "What is your usual cycle\nlength?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFF2B3A8F),
              ),
            ),

            const Spacer(),

            SizedBox(
              height: 350,
              child: Stack(
                alignment:
                    Alignment.center,
                children: [
                  Container(
                    height: 70,
                    width:
                        double.infinity,
                    decoration:
                        BoxDecoration(
                      color: const Color(
                        0xFFF0EAEB,
                      ).withOpacity(
                        0.6,
                      ),
                    ),
                  ),

                  ListWheelScrollView
                      .useDelegate(
                    controller:
                        _controller,
                    itemExtent: 70,
                    perspective:
                        0.006,
                    diameterRatio:
                        2.0,
                    physics:
                        const FixedExtentScrollPhysics(),
                    onSelectedItemChanged:
                        (index) {
                      setState(() {
                        selectedValue =
                            cycleOptions[
                                index];
                      });
                    },
                    childDelegate:
                        ListWheelChildBuilderDelegate(
                      childCount:
                          cycleOptions
                              .length,
                      builder:
                          (context,
                              index) {
                        final isSelected =
                            selectedValue ==
                                cycleOptions[
                                    index];

                        return Center(
                          child: Text(
                            cycleOptions[
                                    index]
                                .toString(),
                            style:
                                TextStyle(
                              fontSize:
                                  34,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              color: isSelected
                                  ? const Color(
                                      0xFF2B3A8F,
                                    )
                                  : const Color(
                                      0xFF2B3A8F,
                                    ).withOpacity(
                                      0.3,
                                    ),
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

            Padding(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 40,
                vertical: 30,
              ),
              child: ElevatedButton(
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF2B3A8F,
                  ),
                  minimumSize:
                      const Size(
                    double.infinity,
                    60,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      30,
                    ),
                  ),
                  elevation: 0,
                ),
                onPressed:
                    _isLoading
                        ? null
                        : _handleContinue,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth:
                              2,
                          color: Colors
                              .white,
                        ),
                      )
                    : Text(
                        widget.isEditMode
                            ? "Update Tracker"
                            : "Set Tracker",
                        style:
                            const TextStyle(
                          fontSize: 18,
                          color: Colors
                              .white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
