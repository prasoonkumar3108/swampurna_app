import 'package:flutter/material.dart';

// --- Models for API Data (Kept as requested) ---
class BlogModel {
  final String title, category, date, views, imageUrl;
  BlogModel({
    required this.title,
    required this.category,
    required this.date,
    required this.views,
    required this.imageUrl,
  });
}

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final Color navyBlue = const Color(0xFF1E1E5F);
  final Color accentOrange = const Color(0xFFFFA000);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // REMOVED: Scaffold, SafeArea, and BottomNavigationBar
    // These are already provided by TrackerScreen
    return Column(
      children: [
        _buildCustomTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBlogTab(),
              _buildRecentPostTab(),
              _buildCycleSnapsTab(),
            ],
          ),
        ),
      ],
    );
  }

  // --- Tab 1: Our Blog ---
  Widget _buildBlogTab() {
    List<BlogModel> blogs = List.generate(
      10,
      (index) => BlogModel(
        title: index % 2 == 0
            ? "Breaking the Silence: Understanding Menstruation"
            : "Sustainable Menstrual Products: What You Need to Know",
        category: index % 2 == 0 ? "Health" : "Sustainability",
        date: "Feb 13, 2025",
        views: "5,432 views",
        imageUrl: "",
      ),
    );

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: blogs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final blog = blogs[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.image, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          blog.category,
                          style: TextStyle(fontSize: 10, color: navyBlue),
                        ),
                      ),
                      Text(
                        "${blog.date} • ${blog.views}",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    blog.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: navyBlue,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Tab 2: Recent Post ---
  Widget _buildRecentPostTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSubmissionBar("Submit your post here for review"),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "FlowCare",
                          style: TextStyle(
                            color: navyBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.more_horiz),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.play_circle_outline, size: 50),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Icon(Icons.favorite_border),
                        SizedBox(width: 15),
                        Icon(Icons.chat_bubble_outline),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Tab 3: Cycle Snaps ---
  Widget _buildCycleSnapsTab() {
    return Column(
      children: [
        _buildSubmissionBar("Submit your snap here for review"),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 4,
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Icon(Icons.play_arrow, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: navyBlue,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: accentOrange.withOpacity(0.2), // Subtle highlight
        ),
        indicatorColor: accentOrange,
        indicatorWeight: 3,
        dividerColor: Colors.transparent,
        labelColor: accentOrange,
        unselectedLabelColor: Colors.white,
        tabs: const [
          Tab(text: "Our blog"),
          Tab(text: "Recent Post"),
          Tab(text: "Cycle snaps"),
        ],
      ),
    );
  }

  Widget _buildSubmissionBar(String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(hint, style: TextStyle(color: navyBlue, fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: navyBlue),
            child: const Text("Post", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
