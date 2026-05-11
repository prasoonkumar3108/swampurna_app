import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_post_screen.dart';
import 'blog_detail_screen.dart';

// --- Improved Models for API Data ---
class BlogModel {
  final String title, date, imageUrl, category, slug;
  final String? content;
  final String? authorName;

  BlogModel({
    required this.title,
    required this.date,
    required this.imageUrl,
    required this.category,
    required this.slug,
    this.content,
    this.authorName,
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
      slug: json['slug'] ?? '',
      content: json['content'],
      authorName: json['author_name'],
    );
  }
}

class PostModel {
  final String title, content, imageUrl, authorEmail;
  final int likes, comments, likeCount, commentCount;
  final bool likedByMe;
  final String? createdAt;
  PostModel({
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.authorEmail,
    required this.likes,
    required this.comments,
    this.likeCount = 0,
    this.commentCount = 0,
    this.likedByMe = false,
    this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    debugPrint('PostModel JSON: $json');
    return PostModel(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['image_url'] ?? json['image'] ?? json['url'] ?? '',
      authorEmail: json['author']?['email'] ?? 'Anonymous',
      likes: json['like_count'] ?? 0,
      comments: json['comment_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      likedByMe: json['liked_by_me'] ?? false,
      createdAt: json['created_at'],
    );
  }
}

class SnapModel {
  final String id, mediaUrl, type, title, description;
  final String? authorEmail;

  SnapModel({
    required this.id,
    required this.mediaUrl,
    required this.type,
    required this.title,
    required this.description,
    this.authorEmail,
  });

  factory SnapModel.fromJson(Map<String, dynamic> json) {
    debugPrint('SnapModel JSON: $json');
    return SnapModel(
      id: json['id'] ?? '',
      mediaUrl: json['media_url'] ?? json['url'] ?? json['media'] ?? '',
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
  int _currentIndex = 0;

  final Color navyBlue = const Color(0xFF1E1E5F);
  final Color accentOrange = const Color(0xFFFFA000);
  final String placeholder = "https://via.placeholder.com/150";

  // Keys to force FutureBuilder refresh
  int _postsRefreshKey = 0;
  int _snapsRefreshKey = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // Refresh method to trigger data reload
  void _refreshData() {
    // Force FutureBuilder to rebuild by incrementing keys
    setState(() {
      _postsRefreshKey++;
      _snapsRefreshKey++;
    });
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
        if (jsonData.containsKey('data') && jsonData['data'] != null) {
          List data = jsonData['data'];
          if (data.isNotEmpty) {
            return data.map((json) => SnapModel.fromJson(json)).toList();
          } else {
            debugPrint('Snaps data array is empty');
            return [];
          }
        } else {
          debugPrint('No data key found in response');
          return [];
        }
      } else {
        debugPrint('Snaps API failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
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
        bottom: false, // Don't add bottom padding since extendBody is true
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _tabController.animateTo(index);
          });
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: const Color(0xFFE67E22),
        unselectedItemColor: Colors.grey[600],
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/ftab.png', height: 24, width: 24),
            activeIcon: Image.asset(
              'assets/images/ftab.png',
              height: 24,
              width: 24,
              color: const Color(0xFFE67E22),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/stab.png', height: 24, width: 24),
            activeIcon: Image.asset(
              'assets/images/stab.png',
              height: 24,
              width: 24,
              color: const Color(0xFFE67E22),
            ),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/ttab.png', height: 24, width: 24),
            activeIcon: Image.asset(
              'assets/images/ttab.png',
              height: 24,
              width: 24,
              color: const Color(0xFFE67E22),
            ),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/frtab.png', height: 24, width: 24),
            activeIcon: Image.asset(
              'assets/images/frtab.png',
              height: 24,
              width: 24,
              color: const Color(0xFFE67E22),
            ),
            label: 'Rewards',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/fftab.png', height: 24, width: 24),
            activeIcon: Image.asset(
              'assets/images/fftab.png',
              height: 24,
              width: 24,
              color: const Color(0xFFE67E22),
            ),
            label: 'Profile',
          ),
        ],
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 54),
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => itemBuilder(snapshot.data![index]),
        );
      },
    );
  }

  // --- Item Builders ---
  Widget _buildBlogItem(BlogModel blog) {
    return GestureDetector(
      onTap: () {
        if (blog.slug.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogDetailScreen(slug: blog.slug),
            ),
          );
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                blog.imageUrl.isEmpty ? placeholder : blog.imageUrl,
                width: 85,
                height: 85,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 85,
                  height: 85,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
                ),
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
      ),
    );
  }

  // --- Tab 2: Recent Post ---
  Widget _buildRecentPostTab() {
    return Column(
      children: [
        _buildSubmissionBar(
          "Submit your post here for review",
          postType: PostType.recentPost,
        ),
        Expanded(
          child: FutureBuilder<List<PostModel>>(
            key: ValueKey('posts_$_postsRefreshKey'),
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
                  bottom: 30,
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
    // Calculate time ago
    String timeAgo = 'Just now';
    if (post.createdAt != null) {
      try {
        final createdAt = DateTime.parse(post.createdAt!);
        final now = DateTime.now();
        final difference = now.difference(createdAt);

        if (difference.inDays > 0) {
          timeAgo = '${difference.inDays} days ago';
        } else if (difference.inHours > 0) {
          timeAgo = '${difference.inHours} hours ago';
        } else if (difference.inMinutes > 0) {
          timeAgo = '${difference.inMinutes} minutes ago';
        }
      } catch (e) {
        debugPrint('Error parsing date: $e');
      }
    }

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
          // Header - Post title instead of FlowCare
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: navyBlue,
                  child: const Icon(
                    Icons.person,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    post.title.isNotEmpty ? post.title : 'Anonymous',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => print('More options clicked'),
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Media Image - Proper square/rectangular with BoxFit.cover
          if (post.imageUrl.isNotEmpty && post.imageUrl != placeholder)
            Container(
              width: double.infinity,
              height: 350,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) {
                    debugPrint(
                      'Recent Post image load error: $error for URL: $url',
                    );
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 40),
                    );
                  },
                ),
              ),
            ),

          // Action Row - 4 Icons: Like, Comment, Share, Bookmark
          if (post.imageUrl.isNotEmpty && post.imageUrl != placeholder)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Like Icon
                  GestureDetector(
                    onTap: () => print('Like clicked'),
                    child: Icon(
                      post.likedByMe ? Icons.favorite : Icons.favorite_border,
                      color: post.likedByMe ? Colors.red : Colors.black54,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Comment Icon
                  GestureDetector(
                    onTap: () => print('Comment clicked'),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.black54,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Share Icon
                  GestureDetector(
                    onTap: () => print('Share clicked'),
                    child: Icon(Icons.send, color: Colors.black54, size: 24),
                  ),
                  const SizedBox(width: 20),
                  // Bookmark Icon
                  GestureDetector(
                    onTap: () => print('Bookmark clicked'),
                    child: Icon(
                      Icons.bookmark_border,
                      color: Colors.black54,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

          // Content Section - Full description without maxLines constraint
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post content without maxLines
                Text(
                  post.content,
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
                const SizedBox(height: 8),

                // Stats & Time
                Row(
                  children: [
                    Text(
                      '${post.likeCount} likes',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (post.commentCount > 0)
                      GestureDetector(
                        onTap: () => print('View all comments clicked'),
                        child: Text(
                          'View all ${post.commentCount} comments',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      timeAgo,
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Comment Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => print('Add comment clicked'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Add a comment...',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // --- Tab 3: Cycle Snaps ---
  Widget _buildSnapGrid(Future<List<SnapModel>> future) {
    return Column(
      children: [
        _buildSubmissionBar(
          "Submit your snap here for review",
          postType: PostType.cycleSnap,
        ),
        Expanded(
          child: FutureBuilder<List<SnapModel>>(
            key: ValueKey('snaps_$_snapsRefreshKey'),
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
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
                            imageUrl:
                                (snap.mediaUrl.isNotEmpty &&
                                    snap.mediaUrl != 'null' &&
                                    snap.mediaUrl != placeholder)
                                ? snap.mediaUrl
                                : placeholder,
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
                                'Cycle Snap image load error: $error for URL: ${snap.mediaUrl}',
                              );
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 40),
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
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.7),
                                ],
                                stops: const [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Bottom Content
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title
                              Text(
                                (snap.title.isNotEmpty && snap.title != 'null')
                                    ? snap.title
                                    : 'Cycle Snap',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              // Author and Date
                              if (snap.authorEmail != null)
                                Text(
                                  snap.authorEmail!.split('@').first,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 9,
                                  ),
                                ),
                            ],
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: navyBlue,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: Colors.orange, width: 2),
          insets: EdgeInsets.only(bottom: 8),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorPadding: const EdgeInsets.only(bottom: 4),
        dividerColor: Colors.transparent,
        labelColor: accentOrange,
        unselectedLabelColor: Colors.white,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        tabs: [
          const Tab(text: "Our blog"),
          Tab(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: const Text("Recent Posts"),
            ),
          ),
          const Tab(text: "Cycle snaps"),
        ],
      ),
    );
  }

  Widget _buildSubmissionBar(String hint, {PostType? postType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(hint, style: TextStyle(color: navyBlue, fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatePostScreen(
                    postType: postType ?? PostType.recentPost,
                  ),
                ),
              );

              // If post was created successfully, refresh the data
              if (result == true) {
                _refreshData();
              }
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
