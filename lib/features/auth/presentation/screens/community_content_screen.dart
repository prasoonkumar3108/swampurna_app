// community_content_screen.dart
import 'package:flutter/material.dart';

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
          _buildSectionHeader("Trending Now", navyBlue),
          _buildHorizontalList([
            _cardItem("Menstrual Cycle\nPhases Explained", "assets/cycle.png"),
            _cardItem("Period Blood Color\nGuide", "assets/blood.png"),
            _cardItem("Managing Period\nCramps Naturally", "assets/cramps.png"),
          ]),
          const SizedBox(height: 25),
          _buildSectionHeader("When to Track Your Cycle", navyBlue),
          _buildHorizontalList([
            _cardItem("Late Period? Possible\nReasons", "assets/late.png"),
            _cardItem("Period Flow Types:\nLight to Heavy", "assets/flow.png"),
            _cardItem("PMS vs PMDD:\nKnow the Difference", "assets/pms.png"),
          ]),
          const SizedBox(height: 25),
          _buildSectionHeader("Menstrual Hygiene & Care", navyBlue),
          _buildHorizontalList([
            _cardItem("Preventing Rashes\n& Infections", "assets/rash.png"),
            _cardItem("Can You Swim or\nExercise?", "assets/swim.png"),
            _cardItem("Eco-Friendly Period\nChoices", "assets/eco.png"),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildHorizontalList(List<Widget> items) {
    return SizedBox(
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        children: items,
      ),
    );
  }

  Widget _cardItem(String title, String imgPath) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage('https://via.placeholder.com/160x220'), // Replace with your API Image
          fit: BoxFit.cover,
        ),
      ),
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]),
        ),
        child: Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}