import 'package:flutter/material.dart';

// --- Theme Constants ---
class AppColors {
  static const Color background = Color(0xFFD6F2F7);
  static const Color primaryNavy = Color(0xFF1D2671);
  static const Color secondaryText = Color(0xFF4A4E8E);
  static const Color selectionPink = Colors.pinkAccent;
}

// --- API Ready Models ---
class TrackerOption {
  final String id;
  final String title;
  final String icon;
  TrackerOption({required this.id, required this.title, required this.icon});
}

class TrackerSection {
  final String categoryName;
  final List<TrackerOption> options;
  TrackerSection({required this.categoryName, required this.options});
}

class CustomizePeriod extends StatefulWidget {
  const CustomizePeriod({super.key});

  @override
  State<CustomizePeriod> createState() => _CustomizePeriodState();
}

class _CustomizePeriodState extends State<CustomizePeriod> {
  final Map<String, String> _userSelections = {};

  // --- API Data Simulation (Revised with Screenshot Data) ---
  final List<TrackerSection> _sections = [
    TrackerSection(
      categoryName: "Period",
      options: [
        TrackerOption(id: "1", title: "Light", icon: "assets/light.png"),
        TrackerOption(id: "2", title: "Medium", icon: "assets/medium.png"),
        TrackerOption(id: "3", title: "Heavy", icon: "assets/heavy.png"),
      ],
    ),
    TrackerSection(
      categoryName: "Spotting",
      options: [
        TrackerOption(id: "4", title: "Red", icon: "assets/red.png"),
        TrackerOption(id: "5", title: "Brown", icon: "assets/brown.png"),
      ],
    ),
    TrackerSection(
      categoryName: "Feelings",
      options: [
        TrackerOption(id: "6", title: "Mood Swings", icon: "assets/mood.png"),
        TrackerOption(
          id: "7",
          title: "Not in control",
          icon: "assets/control.png",
        ),
        TrackerOption(id: "8", title: "Fine", icon: "assets/fine.png"),
      ],
    ),
    TrackerSection(
      categoryName: "Pain",
      options: [
        TrackerOption(
          id: "9",
          title: "Pain free",
          icon: "assets/pain_free.png",
        ),
        TrackerOption(id: "10", title: "Cramps", icon: "assets/cramps.png"),
        TrackerOption(
          id: "11",
          title: "Ovulation",
          icon: "assets/ovulation.png",
        ),
      ],
    ),
    TrackerSection(
      categoryName: "Sleep quality",
      options: [
        TrackerOption(id: "12", title: "Good", icon: "assets/sleep_good.png"),
        TrackerOption(
          id: "13",
          title: "Disturbed",
          icon: "assets/sleep_bad.png",
        ),
      ],
    ),
    TrackerSection(
      categoryName: "Perimenopause",
      options: [
        TrackerOption(
          id: "14",
          title: "Trouble falling asleep",
          icon: "assets/sleep_issue.png",
        ),
        TrackerOption(
          id: "15",
          title: "Vaginal dryness",
          icon: "assets/dry.png",
        ),
        TrackerOption(
          id: "16",
          title: "Mood swings",
          icon: "assets/mood_2.png",
        ),
      ],
    ),
    TrackerSection(
      categoryName: "Pregnancy experiences",
      options: [
        TrackerOption(id: "17", title: "Nesting", icon: "assets/nesting.png"),
        TrackerOption(id: "18", title: "Bonding", icon: "assets/bonding.png"),
        TrackerOption(
          id: "19",
          title: "Contractions",
          icon: "assets/contractions.png",
        ),
      ],
    ),
    TrackerSection(
      categoryName: "Pregnancy Superpowers",
      options: [
        TrackerOption(id: "20", title: "Super taste", icon: "assets/taste.png"),
        TrackerOption(id: "21", title: "Super smell", icon: "assets/smell.png"),
        TrackerOption(
          id: "22",
          title: "Intense orgasm",
          icon: "assets/orgasm.png",
        ),
      ],
    ),
    TrackerSection(
      categoryName: "Fetal movements",
      options: [
        TrackerOption(id: "23", title: "Activity", icon: "assets/activity.png"),
        TrackerOption(
          id: "24",
          title: "More activity",
          icon: "assets/more_act.png",
        ),
        TrackerOption(
          id: "25",
          title: "Less activity",
          icon: "assets/less_act.png",
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),

      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              0,
              20,
              100,
            ), // Bottom padding for button
            children: [
              const Center(
                child: Text(
                  "Customize yourself and get\naccurate result",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ..._sections.map((section) => _buildSection(section)),
            ],
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Skip",
            style: TextStyle(color: AppColors.secondaryText, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(TrackerSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                section.categoryName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
              const Text(
                "Learn more >",
                style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 125,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: section.options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              final option = section.options[index];
              final bool isSelected =
                  _userSelections[section.categoryName] == option.id;

              return OptionCircle(
                option: option,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _userSelections[section.categoryName] = option.id;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ElevatedButton(
        onPressed: () {
          print("Selected Data: $_userSelections");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryNavy,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          "Continue",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class OptionCircle extends StatelessWidget {
  final TrackerOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionCircle({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.5),
                border: Border.all(
                  color: isSelected
                      ? AppColors.selectionPink
                      : AppColors.primaryNavy,
                  width: isSelected ? 3 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.selectionPink.withOpacity(0.2),
                          blurRadius: 10,
                        ),
                      ]
                    : [],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),

                  child: Image.asset(
                    option.icon,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.bubble_chart_outlined,
                      color: AppColors.primaryNavy,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              option.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: AppColors.primaryNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
