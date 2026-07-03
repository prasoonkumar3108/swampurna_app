import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_app/features/auth/models/news_article_detail.dart';

class DynamicCommunityDetailScreen extends StatefulWidget {
  final String slug;
  const DynamicCommunityDetailScreen({super.key, required this.slug});

  @override
  State<DynamicCommunityDetailScreen> createState() =>
      _DynamicCommunityDetailScreenState();
}

class _DynamicCommunityDetailScreenState
    extends State<DynamicCommunityDetailScreen> {
  bool _isLoading = true;
  String? _error;
  NewsArticleDetail? _article;

  @override
  void initState() {
    super.initState();
    _fetchArticleDetail();
  }

  Future<void> _fetchArticleDetail() async {
    final url =
        "https://swampurna-final-production.up.railway.app/api/public/newsarticles/${widget.slug}";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          _article = NewsArticleDetail.fromJson(jsonData);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Failed to load article";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD1F1F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD1F1F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Community Detail",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_article == null) {
      return const Center(child: Text("No article found"));
    }

    return SingleChildScrollView(
     padding: EdgeInsets.only(
    left: 16,
    right: 16,
    top: 16,
    bottom: MediaQuery.of(context).padding.bottom + 16, // ✅ safe bottom padding
  ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: _article!.imageUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 220,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 220,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 40),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            _article!.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (_article!.subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              _article!.subtitle!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Description
          Text(
            _article!.description.replaceAll("&nbsp;", " "),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
