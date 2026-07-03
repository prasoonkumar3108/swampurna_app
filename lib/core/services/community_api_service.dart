import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';

class AppColors {
  static const Color background = Color(0xFFD6F2F7);
  static const Color primaryNavy = Color(0xFF1D2671);
  static const Color secondaryText = Color(0xFF4A4E8E);
  static const Color selectionPink = Colors.pinkAccent;
}

class TrackerOptionItem {
  final String key;
  final String label;

  TrackerOptionItem({
    required this.key,
    required this.label,
  });

  factory TrackerOptionItem.fromJson(Map<String, dynamic> json) {
    return TrackerOptionItem(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}

class TrackerSection {
  final String key;
  final String label;
  final String purpose;
  final String predictionEffect;
  final String confidenceImpact;
  final List<TrackerOptionItem> options;

  TrackerSection({
    required this.key,
    required this.label,
    required this.purpose,
    required this.predictionEffect,
    required this.confidenceImpact,
    required this.options,
  });

  factory TrackerSection.fromJson(Map<String, dynamic> json) {
    return TrackerSection(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      predictionEffect: json['prediction_effect']?.toString() ?? '',
      confidenceImpact: json['confidence_impact']?.toString() ?? '',
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => TrackerOptionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CustomizePeriod extends StatefulWidget {
  const CustomizePeriod({super.key});

  @override
  State<CustomizePeriod> createState() => _CustomizePeriodState();
}

class _CustomizePeriodState extends State<CustomizePeriod> {
  final Map<String, String> _userSelections = {};
  late Future<List<TrackerSection>> _sectionsFuture;

  @override
  void initState() {
    super.initState();
    _sectionsFuture = _fetchTrackerOptions();
  }

  Future<List<TrackerSection>> _fetchTrackerOptions() async {
    final response = await AuthService().getPeriodTrackerOptions();

     if (response.success && response.data != null) {
    return response.data! as List<TrackerSection>;   // ✅ explicit cast
  }

    throw Exception(response.error ?? 'Failed to fetch tracker options');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ✅ Fixed header (not scrollable)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "Customize and get\naccurate results",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<TrackerSection>>(
              future: _sectionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.primaryNavy),
                      ),
                    ),
                  );
                }

                final sections = snapshot.data ?? [];

                if (sections.isEmpty) {
                  return const Center(
                    child: Text(
                      'No options found',
                      style: TextStyle(color: AppColors.primaryNavy),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  children: sections.map((section) => _buildSection(section)).toList(),
                );
              },
            ),
          ),
        ],
      ),
      // ✅ Bottom button inside SafeArea so it never hides
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              debugPrint("Selections: $_userSelections");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              "Continue",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(TrackerSection section) {
    final displayOptions = section.options.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                section.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
              if (section.options.length > 3)
                TextButton(
                  onPressed: () => _showAllOptions(section),
                  child: const Text("See More >"),
                ),
            ],
          ),
        ),
        if (section.purpose.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              section.purpose,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
          ),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: displayOptions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemBuilder: (_, index) =>
                _buildOptionCircle(section.key, displayOptions[index]),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildOptionCircle(String sectionKey, TrackerOptionItem option) {
    final bool isSelected = _userSelections[sectionKey] == option.key;

    return GestureDetector(
      onTap: () => setState(() => _userSelections[sectionKey] = option.key),
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  // ✅ Blue border always, pink when selected
                  color: isSelected ? AppColors.selectionPink : Colors.blue,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.circle_outlined,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              option.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: AppColors.primaryNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllOptions(TrackerSection section) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              section.label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              section.confidenceImpact,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                ),
                itemCount: section.options.length,
                itemBuilder: (_, i) =>
                    _buildOptionCircle(section.key, section.options[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
