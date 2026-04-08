import 'package:flutter/material.dart';

// Keep these only if the files exist, otherwise the consolidated classes below take over
import 'customize_period_screen.dart';
import 'community_screen.dart';

// --- Models ---
class CalendarDay {
  final int day;
  final String type;
  CalendarDay({required this.day, required this.type});
}

class TrackerData {
  final String monthTitle;
  final List<CalendarDay> days;
  TrackerData({required this.monthTitle, required this.days});
}

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  int _currentIndex = 0;

  final Color bgColor = const Color(0xFFC5EBEA);
  final Color navyBlue = const Color(0xFF1E1E5F);
  final Color periodPink = const Color(0xFFE91E63);
  final Color postPurple = const Color(0xFF4A148C);
  final Color ovulationGreen = const Color(0xFF388E3C);
  final Color preYellow = const Color(0xFFFFA000);

  late TrackerData apiData;

  @override
  void initState() {
    super.initState();
    apiData = TrackerData(
      monthTitle: "FEBRUARY 2026",
      days: [
        ...List.generate(8, (i) => CalendarDay(day: i + 1, type: 'period')),
        ...List.generate(2, (i) => CalendarDay(day: i + 9, type: 'post')),
        ...List.generate(5, (i) => CalendarDay(day: i + 11, type: 'ovulation')),
        ...List.generate(11, (i) => CalendarDay(day: i + 16, type: 'none')),
        ...List.generate(2, (i) => CalendarDay(day: i + 27, type: 'pre')),
      ],
    );
  }

  void navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentIndex == 3 ? const Color(0xFF121212) : bgColor,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildTrackerUI(), // Index 0
            const CommunityScreen(), // Index 1
            const CommunityContentScreen(), // Index 2
            const LiveStreamScreen(), // Index 3
            const SettingsScreen(), // Index 4
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 70.0),
              child: FloatingActionButton(
                heroTag: "tracker_fab",
                onPressed: () => navigateTo(const CustomizePeriod()),
                backgroundColor: navyBlue,
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            )
          : null,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- INDEX 0: MAIN TRACKER UI ---
  Widget _buildTrackerUI() {
    final double screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildTopWarningBar(),
          _buildMainHeader(),
          _buildCalendarCard(screenWidth),
          _buildLegendSection(),
          const SizedBox(height: 10),
          _buildActionBtn("Edit period dates"),
          _buildInsightsSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTopWarningBar() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Your predictions are based on limited data...",
              style: TextStyle(
                fontSize: 11,
                color: navyBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => navigateTo(const CustomizePeriod()),
            style: ElevatedButton.styleFrom(
              backgroundColor: navyBlue,
              minimumSize: const Size(60, 30),
            ),
            child: const Text(
              "Edit",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.chevron_left, color: navyBlue, size: 30),
          Text(
            "Your Tracker",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: navyBlue,
            ),
          ),
          Icon(Icons.chevron_right, color: navyBlue, size: 30),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(double width) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Text(
            apiData.monthTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: navyBlue,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          _buildWeekdayLabels(),
          const Divider(thickness: 1, indent: 10, endIndent: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: apiData.days.length,
            itemBuilder: (context, index) => _calendarCell(apiData.days[index]),
          ),
          Container(
            height: 30,
            width: double.infinity,
            color: navyBlue.withOpacity(0.9),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: labels
          .map(
            (l) => Text(
              l,
              style: TextStyle(fontWeight: FontWeight.bold, color: navyBlue),
            ),
          )
          .toList(),
    );
  }

  Widget _calendarCell(CalendarDay info) {
    Color circleColor = Colors.transparent;
    if (info.type == 'period')
      circleColor = periodPink;
    else if (info.type == 'post')
      circleColor = postPurple;
    else if (info.type == 'ovulation')
      circleColor = ovulationGreen;
    else if (info.type == 'pre')
      circleColor = preYellow;

    return Center(
      child: Container(
        decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
        padding: const EdgeInsets.all(8),
        child: Text(
          "${info.day}",
          style: TextStyle(
            color: info.type == 'none' ? Colors.black87 : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 20,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          _legendItem(preYellow, "Pre-Period"),
          _legendItem(periodPink, "Period Days"),
          _legendItem(postPurple, "Post-Period"),
          _legendItem(ovulationGreen, "Peak Ovulation"),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 7, backgroundColor: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: navyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn(String text) {
    return ElevatedButton(
      onPressed: () => navigateTo(const CustomizePeriod()),
      style: ElevatedButton.styleFrom(
        backgroundColor: navyBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Menstrual Health Tips",
            style: TextStyle(
              color: navyBlue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _insightCard(
                "Flow Types &\nHydration",
                Icons.water_drop_outlined,
              ),
              _insightCard("Period-Friendly\nNutrition", Icons.restaurant_menu),
              _insightCard("Exercise &\nMovement", Icons.fitness_center),
            ],
          ),
        ),
      ],
    );
  }

  Widget _insightCard(String title, IconData icon) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: navyBlue, width: 2),
            ),
            child: Icon(icon, size: 40, color: Colors.orangeAccent),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: navyBlue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: navyBlue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon(Icons.home_outlined, 0),
          _navIcon(Icons.calendar_month, 1),
          _navIcon(Icons.book_outlined, 2),
          _navIcon(Icons.workspace_premium_outlined, 3),
          _navIcon(Icons.person_outline, 4),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    bool isActive = _currentIndex == index;
    return IconButton(
      onPressed: () => setState(() => _currentIndex = index),
      icon: Icon(
        icon,
        color: isActive ? Colors.orange : Colors.white,
        size: 30,
      ),
    );
  }
}

// =============================================================================
// RESTORED SUB-SCREENS (Consolidated to avoid "Not Defined" errors)
// =============================================================================

class CommunityContentScreen extends StatelessWidget {
  const CommunityContentScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final Color navyBlue = const Color(0xFF1E1E5F);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Trending Now", navyBlue),
          _buildRow(["Cycle Phases", "Blood Color", "Cramps"]),
          _buildHeader("Guides", navyBlue),
          _buildRow(["Late Period", "Flow Types", "PMS vs PMDD"]),
        ],
      ),
    );
  }

  Widget _buildHeader(String t, Color c) => Padding(
    padding: const EdgeInsets.all(20),
    child: Text(
      t,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c),
    ),
  );

  Widget _buildRow(List<String> items) => SizedBox(
    height: 200,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemCount: items.length,
      itemBuilder: (context, i) => Container(
        width: 150,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          image: const DecorationImage(
            image: NetworkImage('https://via.placeholder.com/150x200'),
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            items[i],
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}

class LiveStreamScreen extends StatelessWidget {
  const LiveStreamScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121212),
      child: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            color: Colors.grey[900],
            child: const Icon(
              Icons.play_circle_fill,
              size: 80,
              color: Colors.white,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "Live Events",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final Color navyBlue = const Color(0xFF1E1E5F);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Center(
          child: Text(
            "Settings",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E5F),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _item(Icons.person, "Profile", navyBlue),
        _item(Icons.notifications, "Notifications", navyBlue),
        _item(Icons.lock, "Privacy", navyBlue),
        _item(Icons.help, "Help", navyBlue),
        const Divider(),
        _item(Icons.logout, "Logout", Colors.red),
      ],
    );
  }

  Widget _item(IconData i, String t, Color c) => ListTile(
    leading: Icon(i, color: c),
    title: Text(
      t,
      style: TextStyle(color: c, fontWeight: FontWeight.bold),
    ),
    trailing: const Icon(Icons.chevron_right),
  );
}
