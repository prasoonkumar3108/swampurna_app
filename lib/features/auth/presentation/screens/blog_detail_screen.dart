import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BlogDetailScreen extends StatefulWidget {
  final String slug;

  const BlogDetailScreen({super.key, required this.slug});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  static const Color primaryTextColor = Color(0xFF2E3192);
  static const Color bgColor = Color(
    0xFFE1F5F3,
  ); // Light cyan shade from screenshot

  bool _isLoading = true;
  String? _error;
  BlogDetailModel? _blogDetail;

  @override
  void initState() {
    super.initState();
    _fetchBlogDetail();
  }

  // Helper method to format section_key
  String _formatSectionKey(String sectionKey) {
    return sectionKey
        .split('_')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  Future<void> _fetchBlogDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await http.get(
        Uri.parse(
          'https://swampurna-final-production.up.railway.app/api/public/newsarticles/${widget.slug}',
        ),
      );

      debugPrint('Blog Detail API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        debugPrint('Blog Detail JSON: $jsonData');

        if (jsonData.containsKey('data')) {
          final blogData = jsonData['data'];
          setState(() {
            _blogDetail = BlogDetailModel.fromJson(blogData);
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'Blog article not found';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load blog: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching blog detail: $e');
      setState(() {
        _error = 'Failed to load blog: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryTextColor, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryTextColor),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Oops!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchBlogDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTextColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_blogDetail == null) {
      return const Center(
        child: Text(
          'No blog data available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Image - Always show the box
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: _blogDetail!.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: _blogDetail!.imageUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.broken_image, size: 48),
                      ),
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No image available',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Meta Info Row
          Row(
            children: [
              // Category Chip - White background
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _formatSectionKey(_blogDetail!.category),
                  style: const TextStyle(
                    color: primaryTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Date
              Text(
                _blogDetail!.formattedDate,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            _blogDetail!.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 16),

          // Author Row - Only show if author data is present
          if (_blogDetail!.authorName != null &&
              _blogDetail!.authorName!.isNotEmpty)
            Column(
              children: [
                Row(
                  children: [
                    // Profile Avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: primaryTextColor.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: primaryTextColor,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Author Name
                    Text(
                      'By ${_blogDetail!.authorName}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),

          // Content
          if (_blogDetail!.content != null && _blogDetail!.content!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _blogDetail!.content!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.6,
                ),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// Blog Detail Model for detailed view
class BlogDetailModel {
  final String title;
  final String imageUrl;
  final String category;
  final String createdAt;
  final String? content;
  final String? authorName;
  final String slug;

  BlogDetailModel({
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.createdAt,
    required this.slug,
    this.content,
    this.authorName,
  });

  factory BlogDetailModel.fromJson(Map<String, dynamic> json) {
    return BlogDetailModel(
      title: json['title'] ?? 'No Title',
      imageUrl: json['image_url'] ?? '',
      category: json['section_key'] ?? 'General',
      createdAt: json['created_at'] ?? '',
      slug: json['slug'] ?? '',
      content: json['content'],
      authorName: json['author_name'],
    );
  }

  String get formattedDate {
    try {
      if (createdAt.isEmpty) return 'Recent';
      final dateTime = DateTime.parse(createdAt);
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return 'Recent';
    }
  }
}
