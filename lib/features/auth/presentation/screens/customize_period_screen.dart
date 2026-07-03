import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import 'package:my_app/features/auth/models/period_tracker_section.dart';

class AppColors {
  static const Color background = Color(0xFFD6F2F7);
  static const Color primaryNavy = Color(0xFF1D2671);
  static const Color secondaryText = Color(0xFF4A4E8E);
  static const Color selectionPink = Colors.pinkAccent;
}


class CustomizePeriod extends StatefulWidget {
  const CustomizePeriod({super.key});

  @override
  State<CustomizePeriod> createState() => _CustomizePeriodState();
}

class _CustomizePeriodState extends State<CustomizePeriod> {
  bool _isSubmitting = false;
   Map<String, String> _userSelections = {};
  late Future<List<PeriodTrackerSection>> _sectionsFuture;
  

  @override
  void initState() {
    super.initState();
    _sectionsFuture = _fetchTrackerOptions();
    _fetchUserSelections(); // ✅ fetch saved selections
  }



late Map<String, String> _savedSelections = {};

Future<void> _fetchUserSelections() async {
  try {
    final response = await AuthService().getUserPeriodOptions();
    if (response.success && response.data != null) {
      setState(() {
        _savedSelections = response.data!.selections;
        _userSelections = Map.from(_savedSelections); // initialize current selections
      });
    }
  } catch (e) {
    debugPrint("❌ Error fetching user selections: $e");
  }
}


  Future<List<PeriodTrackerSection>> _fetchTrackerOptions() async {
    final response = await AuthService().getPeriodTrackerOptions();

    if (response.success) {
      return response.data ?? <PeriodTrackerSection>[]; // ✅ safe fallback
    }

    throw Exception(response.error ?? 'Failed to fetch tracker options');
  }

  Future<void> _submitSelections() async {
  setState(() => _isSubmitting = true); // ✅ loader start
  try {
    final payload = {
      "selections": _userSelections, // ✅ matches API format
    };
   print(payload);
    final response = await AuthService().updatePeriodOptions(
      '/period-tracker/user-options',
      payload,
      requiresAuth: true,
    );

    if (response.success) {
      if (mounted) Navigator.pop(context); // ✅ go back on success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.error ?? 'Failed to update options')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error submitting selections: $e')),
    );
  }finally {
    if (mounted) setState(() => _isSubmitting = false); // ✅ loader stop
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true, // ✅ title center
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Customize and get\naccurate results",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryNavy,
          ),
        ),
      ),
      body: FutureBuilder<List<PeriodTrackerSection>>(
        future: _sectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            children: sections.map((section) => _buildSection(section)).toList(),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed:_submitSelections,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: _isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              "Continue",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(PeriodTrackerSection section) {
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
        // ❌ Purpose text removed (hidden)
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

  // Widget _buildOptionCircle(String sectionKey, PeriodTrackerOptionItem option) {
  //   final bool isSelected = _userSelections[sectionKey] == option.key;

  //   return GestureDetector(
  //     onTap: () => setState(() => _userSelections[sectionKey] = option.key),
  //     child: SizedBox(
  //       width: 80,
  //       child: Column(
  //         children: [
  //           Container(
  //             width: 70,
  //             height: 70,
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               color: Colors.white,
  //               border: Border.all(
  //                 // ✅ Blue border always, pink when selected
  //                 color: isSelected ? AppColors.selectionPink : Colors.blue,
  //                 width: 2,
  //               ),
  //             ),
  //             child: const Icon(
  //               Icons.circle_outlined,
  //               color: AppColors.primaryNavy,
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             option.label,
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //               fontSize: 11,
  //               fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
  //               color: AppColors.primaryNavy,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  
Widget _buildOptionCircle(String sectionKey, PeriodTrackerOptionItem option) {
  final bool isSelected = _userSelections[sectionKey] == option.key;
  final bool isSaved = _savedSelections[sectionKey] == option.key;

  return GestureDetector(
    onTap: () => setState(() => _userSelections[sectionKey] = option.key),
    child: SizedBox(
      width: 80,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.selectionPink : Colors.blue,
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.circle_outlined, color: AppColors.primaryNavy),
              ),
              if (isSaved)
                const Icon(Icons.check, color: Colors.green, size: 28), // ✅ tick mark
            ],
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


  void _showAllOptions(PeriodTrackerSection section) {
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
