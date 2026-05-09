import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/swift_community_api_service.dart';
import '../models/community_models.dart';
import 'news_detail_screen.dart';

/// Dynamic Community Screen matching Swift implementation
/// Replaces hardcoded content with API-driven data
class DynamicCommunityScreen extends StatefulWidget {
  const DynamicCommunityScreen({super.key});

  @override
  State<DynamicCommunityScreen> createState() => _DynamicCommunityScreenState();
}

class _DynamicCommunityScreenState extends State<DynamicCommunityScreen>
    with TickerProviderStateMixin {
  // Colors matching existing design system
  final Color navyBlue = const Color(0xFF1A237E);
  final Color scaffoldBg = const Color(0xFFD1F1F4);

  // State management
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  List<CommunityCategory> _categories = [];
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fetchCommunityContent();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  /// Fetch content using Swift-compatible API service
  Future<void> _fetchCommunityContent() async {
    if (!mounted) return;

    setState(() {
      if (_isLoading) {
        _isLoading = true;
      } else {
        _isRefreshing = true;
      }
      _error = null;
    });

    try {
      debugPrint('🚀 [DYNAMIC SCREEN] Starting API fetch...');

      final apiService = SwiftCommunityApiService();
      final categories = await apiService.fetchAllCategoriesWithArticles();

      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
          _isRefreshing = false;
        });
        debugPrint('✅ [DYNAMIC SCREEN] Loaded ${categories.length} categories');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isRefreshing = false;
        });
        debugPrint('❌ [DYNAMIC SCREEN] Fetch failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: RefreshIndicator(
        onRefresh: _fetchCommunityContent,
        color: navyBlue,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_categories.isEmpty) {
      return _buildEmptyState();
    }

    return _buildContent();
  }

  /// Loading state with shimmer effect
  Widget _buildLoadingState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildShimmerHeader(), _buildShimmerSections()],
      ),
    );
  }

  /// Error state with retry functionality
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.grey[400], size: 64),
            const SizedBox(height: 16),
            Text(
              'Failed to load content',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchCommunityContent,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: navyBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state when no categories are available
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, color: Colors.grey[400], size: 64),
            const SizedBox(height: 16),
            Text(
              'No categories available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new content',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// Main content with dynamic categories and articles
  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic sections generated from API
          ..._categories
              .map((category) => _buildCategorySection(category))
              .toList(),
          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  /// Individual category section with horizontal scrolling articles
  Widget _buildCategorySection(CommunityCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            category.name,
            style: TextStyle(
              color: navyBlue,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),

        // Horizontal scrolling articles
        if (category.articles.isNotEmpty)
          SizedBox(
            height: 200, // Card height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: category.articles.length,
              itemBuilder: (context, index) {
                final article = category.articles[index];
                return _buildArticleCard(article);
              },
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'No articles in ${category.name}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ),
            ),
          ),

        const SizedBox(height: 24),
      ],
    );
  }

  /// Individual article card with image and gradient overlay
  Widget _buildArticleCard(Article article) {
    return Container(
      width: 160, // Card width
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Image background
            CachedNetworkImage(
              imageUrl: article.imageUrl ?? '',
              width: 160,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 160,
                height: 200,
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    color: navyBlue,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 160,
                height: 200,
                color: Colors.grey[200],
                child: Icon(
                  Icons.broken_image,
                  color: Colors.grey[400],
                  size: 32,
                ),
              ),
            ),

            // Bottom gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
            ),

            // Title text overlay
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(
                article.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shimmer effect for loading state
  Widget _buildShimmerHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: 150,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildShimmerSections() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  width: 120,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 3,
                  itemBuilder: (context, index) => Container(
                    width: 160,
                    height: 200,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
