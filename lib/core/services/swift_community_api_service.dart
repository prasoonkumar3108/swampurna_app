import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../features/auth/presentation/models/community_models.dart';

/// Swift-Compatible API Service for Community Content
/// Matches exact headers and behavior of working Swift implementation
class SwiftCommunityApiService {
  static final SwiftCommunityApiService _instance =
      SwiftCommunityApiService._internal();
  factory SwiftCommunityApiService() => _instance;
  SwiftCommunityApiService._internal();

  /// Base URL matching Swift implementation
  static const String _baseUrl =
      'https://swampurna-final-production.up.railway.app/api/public/newsarticles';

  /// Exact Swift headers matching working implementation
  Map<String, String> get _swiftHeaders => {
    'Authorization': 'Bearer YOUR_TOKEN', // Use same token as Swift
    'Accept': 'application/json',
    'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
    'Cache-Control': 'no-cache',
  };

  /// Fetch categories from API (Step 1)
  Future<CategoryResponse> fetchCategories() async {
    try {
      debugPrint('🔍 [SWIFT API] Fetching categories...');

      final url = Uri.parse('$_baseUrl/categories');
      debugPrint('🌐 [SWIFT API] GET $url');
      debugPrint('📋 [SWIFT API] Headers: ${_formatHeaders(_swiftHeaders)}');

      final response = await http
          .get(url, headers: _swiftHeaders)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw TimeoutException('Request timeout after 30 seconds'),
          );

      debugPrint('📦 [SWIFT API] Response Status: ${response.statusCode}');
      debugPrint(
        '📋 [SWIFT API] Response Headers: ${_formatHeaders(response.headers)}',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }

      // Content-Type validation (Swift-style)
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        debugPrint('⚠️ [SWIFT API] Non-JSON response: $contentType');
        throw Exception('Server returned non-JSON response: $contentType');
      }

      final responseBody = utf8.decode(response.bodyBytes);
      debugPrint('✅ [SWIFT API] Categories fetched successfully');

      return CategoryResponse.fromJson(json.decode(responseBody));
    } catch (e) {
      debugPrint('❌ [SWIFT API] Categories fetch failed: $e');
      rethrow;
    }
  }

  /// Fetch articles for a specific category (Step 2)
  Future<ArticleResponse> fetchArticlesForCategory(String categoryId) async {
    try {
      debugPrint('🔍 [SWIFT API] Fetching articles for category: $categoryId');

      final url = Uri.parse('$_baseUrl?category_id=$categoryId');
      debugPrint('🌐 [SWIFT API] GET $url');
      debugPrint('📋 [SWIFT API] Headers: ${_formatHeaders(_swiftHeaders)}');

      final response = await http
          .get(url, headers: _swiftHeaders)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw TimeoutException('Request timeout after 30 seconds'),
          );

      debugPrint('📦 [SWIFT API] Response Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }

      // Content-Type validation (Swift-style)
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        debugPrint('⚠️ [SWIFT API] Non-JSON response: $contentType');
        throw Exception('Server returned non-JSON response: $contentType');
      }

      final responseBody = utf8.decode(response.bodyBytes);
      debugPrint('✅ [SWIFT API] Articles fetched for category $categoryId');

      return ArticleResponse.fromJson(json.decode(responseBody));
    } catch (e) {
      debugPrint(
        '❌ [SWIFT API] Articles fetch failed for category $categoryId: $e',
      );
      rethrow;
    }
  }

  /// Fetch all categories with their articles (DispatchGroup-style)
  Future<List<CommunityCategory>> fetchAllCategoriesWithArticles() async {
    try {
      debugPrint('🚀 [SWIFT API] Starting DispatchGroup-style fetch...');

      // Step 1: Fetch all categories
      final categoriesResponse = await fetchCategories();
      final categories = categoriesResponse.data;

      debugPrint('📊 [SWIFT API] Found ${categories.length} categories');

      // Step 2: Fetch articles for each category (like Swift DispatchGroup)
      final List<Future<Map<String, dynamic>>> articleFutures = [];

      for (final category in categories) {
        articleFutures.add(
          fetchArticlesForCategory(category.id).then(
            (articlesResponse) => {
              'category': category,
              'articles': articlesResponse.data,
            },
            onError: (error) {
              debugPrint(
                '⚠️ [SWIFT API] Failed to fetch articles for ${category.name}: $error',
              );
              return {'category': category, 'articles': <Article>[]};
            },
          ),
        );
      }

      // Wait for all article fetches to complete
      final results = await Future.wait(articleFutures);

      // Step 3: Combine categories with their articles
      final List<CommunityCategory> communityCategories = [];

      for (final result in results) {
        final category = result['category'] as CategoryData;
        final articles = result['articles'] as List<Article>;

        communityCategories.add(
          CommunityCategory.fromCategoryData(category, articles),
        );
      }

      debugPrint('✅ [SWIFT API] DispatchGroup fetch completed');
      return communityCategories;
    } catch (e) {
      debugPrint('❌ [SWIFT API] DispatchGroup fetch failed: $e');
      rethrow;
    }
  }

  /// Format headers for debugging
  String _formatHeaders(Map<String, String> headers) {
    return headers.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }
}
