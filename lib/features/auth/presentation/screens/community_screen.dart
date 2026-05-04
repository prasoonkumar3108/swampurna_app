import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Improved Models for API Data ---
class BlogModel {
  final String title, date, imageUrl, category;
  BlogModel({
    required this.title,
    required this.date,
    required this.imageUrl,
    required this.category,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      title: json['title'] ?? 'No Title',
      category: json['section_key'] ?? 'General',
      date: json['created_at'] != null
          ? DateFormat(
              'MMM dd, yyyy',
            ).format(DateTime.parse(json['created_at']))
          : 'Recent',
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class PostModel {
  final String title, content, imageUrl, authorEmail;
  final int likes, comments;
  PostModel({
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.authorEmail,
    required this.likes,
    required this.comments,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['image_url'] ?? '',
      authorEmail: json['author']?['email'] ?? 'Anonymous',
      likes: json['like_count'] ?? 0,
      comments: json['comment_count'] ?? 0,
    );
  }
}

class SnapModel {
  final String mediaUrl, type, title, description;
  final String? authorEmail;

  SnapModel({
    required this.mediaUrl,
    required this.type,
    required this.title,
    required this.description,
    this.authorEmail,
  });

  factory SnapModel.fromJson(Map<String, dynamic> json) {
    return SnapModel(
      mediaUrl: json['media_url'] ?? '',
      type: json['media_type'] ?? 'image',
      title: json['title'] ?? 'Cycle Snap',
      description: json['description'] ?? '',
      authorEmail: json['author']?['email'],
    );
  }
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
  final String placeholder = "https://via.placeholder.com/150";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // --- API Fetch Methods ---
  Future<List<BlogModel>> fetchBlogs() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://swampurna-final-production.up.railway.app/api/public/newsarticles',
        ),
      );
      debugPrint('Blogs API Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        debugPrint('Blogs JSON: $jsonData');
        if (jsonData.containsKey('data')) {
          List data = jsonData['data'];
          return data.map((json) => BlogModel.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load blogs: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching blogs: $e');
      throw Exception('Failed to load blogs: $e');
    }
  }

  Future<List<PostModel>> fetchPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse(
          'https://swampurna-final-production.up.railway.app/api/v1/posts?limit=20&offset=0',
        ),
        headers: headers,
      );
      debugPrint('Posts API Response: ${response.statusCode}');
      debugPrint('Posts Headers: $headers');
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        debugPrint('Posts JSON: $jsonData');
        if (jsonData.containsKey('data')) {
          List data = jsonData['data'];
          return data.map((json) => PostModel.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load posts: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      throw Exception('Failed to load posts: $e');
    }
  }

  Future<List<SnapModel>> fetchSnaps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse(
          'https://swampurna-final-production.up.railway.app/api/v1/cycle-snaps?mine=true&limit=20&offset=0',
        ),
        headers: headers,
      );
      debugPrint('Snaps API Response: ${response.statusCode}');
      debugPrint('Snaps Headers: $headers');
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        debugPrint('Snaps JSON: $jsonData');
        if (jsonData.containsKey('data')) {
          List data = jsonData['data'];
          return data.map((json) => SnapModel.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load snaps: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching snaps: $e');
      throw Exception('Failed to load snaps: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      extendBodyBehindAppBar: false,
      body: SafeArea(
        bottom: true, // Explicitly ensure bottom padding
        child: Column(
          children: [
            _buildCustomTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDataTab<BlogModel>(fetchBlogs(), _buildBlogItem),
                  _buildRecentPostTab(),
                  _buildSnapGrid(fetchSnaps()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Reusable Loader Wrapper ---
  Widget _buildDataTab<T>(
    Future<List<T>> future,
    Widget Function(T) itemBuilder,
  ) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) {
          print('API Error: ${snapshot.error}');
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const Center(child: Text("No data found"));

        return ListView.separated(
          padding: const EdgeInsets.only(
            bottom: 100,
          ), // Bottom padding for navigation bar
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => itemBuilder(snapshot.data![index]),
        );
      },
    );
  }

  // --- Item Builders ---
  Widget _buildBlogItem(BlogModel blog) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            blog.imageUrl.isEmpty ? placeholder : blog.imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 80,
              height: 80,
              color: Colors.grey[300],
              child: const Icon(Icons.image),
            ),
          ),
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
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      blog.category,
                      style: TextStyle(fontSize: 10, color: navyBlue),
                    ),
                  ),
                  Text(
                    blog.date,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
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
  }

  // --- Tab 2: Recent Post ---
  Widget _buildRecentPostTab() {
    return Column(
      children: [
        _buildSubmissionBar("Submit your post here for review"),
        Expanded(
          child: FutureBuilder<List<PostModel>>(
            future: fetchPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) {
                print('Posts API Error: ${snapshot.error}');
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return const Center(child: Text("No posts found"));

              return ListView.builder(
                padding: const EdgeInsets.only(
                  bottom: 100,
                ), // Bottom padding for navigation bar
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) =>
                    _buildPostItem(snapshot.data![index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPostItem(PostModel post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - ListTile style
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: navyBlue,
                  child: const Icon(
                    Icons.person,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    post.authorEmail.split('@')[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(Icons.more_horiz, color: Colors.grey[600], size: 20),
              ],
            ),
          ),

          // Media Image - Full width
          if (post.imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: post.imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 40),
              ),
            ),

          // Action Row - Transparent icons
          if (post.imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => print('Like clicked'),
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.black54,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () => print('Comment clicked'),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.black54,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () => print('Share clicked'),
                    child: Icon(Icons.share, color: Colors.black54, size: 22),
                  ),
                ],
              ),
            ),

          // Content Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: post.authorEmail.split('@')[0],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: post.content,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (post.comments > 0)
                  GestureDetector(
                    onTap: () => print('View all comments clicked'),
                    child: Text(
                      'View all ${post.comments} comments...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          // Add Comment Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Add a comment...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Tab 3: Cycle Snaps ---
  Widget _buildSnapGrid(Future<List<SnapModel>> future) {
    return Column(
      children: [
        _buildSubmissionBar("Submit your snap here for review"),
        Expanded(
          child: FutureBuilder<List<SnapModel>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) {
                print('Snaps API Error: ${snapshot.error}');
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return const Center(child: Text("No snaps found"));

              return GridView.builder(
                padding: const EdgeInsets.only(
                  bottom: 100,
                ), // Bottom padding for navigation bar
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6, // Taller cards to match screenshot
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final snap = snapshot.data![index];
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Main Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: snap.mediaUrl.isEmpty
                                ? placeholder
                                : snap.mediaUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              debugPrint(
                                'Image load error: $error for URL: ${snap.mediaUrl}',
                              );
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 40),
                              );
                            },
                          ),
                        ),

                        // Gradient Overlay for better text visibility
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.1),
                                  Colors.black.withOpacity(0.3),
                                ],
                                stops: [0.0, 0.7, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Top-left Title
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              snap.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        // Top-right More Icon
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => print(
                              'More options clicked for: ${snap.title}',
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),

                        // Bottom Description and Stats
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (snap.description.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    snap.description,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '24M views',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '#PeriodPower',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Play Icon for Videos
                        if (snap.type == 'video')
                          Center(
                            child: Icon(
                              Icons.play_circle_filled,
                              color: Colors.white,
                              size: 48,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Keep your existing UI UI Components ---
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
          color: accentOrange.withOpacity(0.2),
        ),
        indicatorColor: accentOrange,
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
            onPressed: () {
              print('Post button clicked for: $hint');
              // TODO: Implement post submission logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: navyBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text("Post", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
