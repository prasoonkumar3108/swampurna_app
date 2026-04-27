import 'package:flutter/material.dart';
import 'birth_year_picker_screen.dart';
import '../models/onboarding_data.dart';

/// ---------------- CONSTANTS ----------------
class AppColors {
  static const Color background = Color(0xFFD1F2F2);
  static const Color primaryText = Color(0xFF1D2E79);
  static const Color optionBackground = Color(0xFFF2EBEB);
  static const Color optionText = Color(0xFF333D7C);
}

class AppSpacing {
  static const double horizontalPadding = 24.0;
  static const double itemSpacing = 14.0;
}

/// ---------------- MOCK API ----------------
class SurveyService {
  static Future<List<String>> fetchOptions() async {
    await Future.delayed(const Duration(seconds: 2));

    return [
      'Google play or Google search',
      'Friends or Family',
      'Instagram or Facebook',
      'TikTok',
      'Youtube or TV',
      'Influencer or Celebrity',
      'Medical or professional',
      'Other',
    ];
  }
}

/// ---------------- SCREEN ----------------
class SourceSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> onboardingData;

  const SourceSelectionScreen({super.key, required this.onboardingData});

  @override
  State<SourceSelectionScreen> createState() => _SourceSelectionScreenState();
}

class _SourceSelectionScreenState extends State<SourceSelectionScreen> {
  late Future<List<String>> _optionsFuture;

  @override
  void initState() {
    super.initState();
    _optionsFuture = SurveyService.fetchOptions();
  }

  void _onOptionSelected(String option) {
    debugPrint("Tapped option: $option");

    // Update onboarding data with source selection
    final updatedData = Map<String, dynamic>.from(widget.onboardingData);
    updatedData['source'] = option;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            BirthYearPickerScreen(onboardingData: updatedData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: FutureBuilder<List<String>>(
                future: _optionsFuture,
                builder: (context, snapshot) {
                  /// 🔄 Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  /// ❌ Error
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading data"));
                  }

                  /// ✅ Data
                  final options = snapshot.data ?? [];

                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontalPadding,
                      vertical: 20,
                    ),
                    children: [
                      Text(
                        'How did you find out\nabout us?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.075,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),

                      const SizedBox(height: 40),

                      ...options.map(
                        (option) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.itemSpacing,
                          ),
                          child: SelectionOptionTile(
                            title: option,
                            onTap: () => _onOptionSelected(option),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
    );
  }
}

/// ---------------- OPTION TILE ----------------
class SelectionOptionTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const SelectionOptionTile({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          debugPrint("Tile clicked: $title");
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.optionBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, color: AppColors.optionText),
          ),
        ),
      ),
    );
  }
}
