import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../services/token_storage_service.dart';
import '../../features/auth/presentation/models/community_models.dart';

/// Isolated API Service for Community Content to avoid affecting global settings
class CommunityApiService {
  static final CommunityApiService _instance = CommunityApiService._internal();
  factory CommunityApiService() => _instance;
  CommunityApiService._internal();

  /// Make HTTP request with Postman-mirrored configuration
  Future<http.Response> _makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    bool requiresAuth = false,
    dynamic body,
  }) async {
    // Direct URL to avoid base URL issues
    final url = endpoint.startsWith('http') ? endpoint : endpoint;

    // Prepare headers to match working Swift version
    final requestHeaders = <String, String>{
      'Accept': 'application/json, image/avif, */*',
      'Authorization': 'Bearer YOUR_TOKEN',
      'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'Cache-Control': 'no-cache',
    };

    // Add custom headers
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    // Add authorization header if required
    if (requiresAuth) {
      final token = await TokenStorageService.instance.getToken();
      if (token != null && token.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }
    }

    debugPrint('\n🌐 [COMMUNITY API REQUEST] --> $method $url');
    debugPrint('📋 [COMMUNITY HEADERS] ${_formatHeaders(requestHeaders)}');
    if (body != null) {
      debugPrint('📦 [COMMUNITY BODY] ${_formatJsonForLog(body)}');
    } else {
      debugPrint('📦 [COMMUNITY BODY] (empty)');
    }
    debugPrint('🔐 [COMMUNITY AUTH] Auth Required: $requiresAuth');
    debugPrint('⏰ [COMMUNITY TIMESTAMP] ${DateTime.now().toIso8601String()}');

    final uri = Uri.parse(url);
    final startTime = DateTime.now();

    // Make request with 30-second timeout
    late http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(uri, headers: requestHeaders)
              .timeout(const Duration(seconds: 30));
          break;
        case 'POST':
          response = await http
              .post(
                uri,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(const Duration(seconds: 30));
          break;
        case 'PUT':
          response = await http
              .put(
                uri,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(const Duration(seconds: 30));
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
    } catch (e) {
      rethrow;
    }

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    debugPrint('📬 [COMMUNITY API RESPONSE] <-- $method $url');
    debugPrint('📊 [COMMUNITY STATUS] ${response.statusCode}');
    debugPrint('⏱️ [COMMUNITY DURATION] ${duration.inMilliseconds}ms');
    debugPrint(
      '📋 [COMMUNITY RESPONSE HEADERS] ${_formatHeaders(response.headers.cast<String, String>())}',
    );

    if (response.body.isNotEmpty) {
      final bodyPreview = response.body.length > 300
          ? response.body.substring(0, 300)
          : response.body;
      debugPrint('🔍 [COMMUNITY BODY PREVIEW] $bodyPreview');
    }

    return response;
  }

  /// Format JSON for logging
  static String _formatJsonForLog(dynamic json) {
    try {
      return const JsonEncoder.withIndent('  ').convert(json);
    } catch (e) {
      return 'Failed to serialize JSON: $e';
    }
  }

  /// Get Community Categories with Postman-mirrored configuration
  Future<ApiResponse<List<CommunityCategory>>> getCommunityCategories() async {
    try {
      debugPrint('🔍 [COMMUNITY API] Fetching categories with Silent Guard...');

      // Direct full URL to avoid any base URL issues
      final url =
          'https://swampurna-final-production.up.railway.app/api/public/newsarticles/categories';

      // Exact Swift headers
      final headers = {
        'Accept': 'application/json, image/avif, */*',
        'Authorization': 'Bearer YOUR_TOKEN',
        'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)',
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
        'Cache-Control': 'no-cache',
      };

      debugPrint('🌐 [COMMUNITY REQUEST] URL: $url');
      debugPrint('📋 [COMMUNITY HEADERS] ${_formatHeaders(headers)}');

      final uri = Uri.parse(url);

      // API Request Overhaul: Use response.bodyBytes to avoid encoding issues
      final response = await http.get(uri, headers: headers);

      debugPrint('📦 [COMMUNITY RESPONSE] Status: ${response.statusCode}');
      debugPrint(
        '📋 [COMMUNITY RESPONSE HEADERS] ${_formatHeaders(response.headers)}',
      );

      // The 'If Not JSON, Don't Touch' Rule
      if (!response.headers['content-type']!.contains('application/json')) {
        print('📡 Not a JSON response, skipping...');
        return ApiResponse.success([]);
      }

      final decoded = json.decode(utf8.decode(response.bodyBytes));
      debugPrint('✅ [COMMUNITY SUCCESS] Categories parsed successfully');

      final List<dynamic> categoriesData = List<dynamic>.from(decoded);
      final categories = categoriesData
          .map(
            (item) => CommunityCategory.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      return ApiResponse.success(categories);
    } catch (e) {
      debugPrint('❌ [COMMUNITY SILENT GUARD] Any error: $e');
      return ApiResponse.success(
        [],
      ); // NEVER throw an error, just return empty list
    }
  }

  /// Get Community Articles by Category with Postman-mirrored configuration
  Future<ApiResponse<List<CommunityArticle>>> getCommunityArticles({
    required int categoryId,
  }) async {
    try {
      debugPrint(
        '🔍 [COMMUNITY API] Fetching articles for category $categoryId with Silent Guard...',
      );

      // Direct full URL with query parameters
      final url =
          'https://swampurna-final-production.up.railway.app/api/public/newsarticles?category_id=$categoryId';

      // Exact Swift headers
      final headers = {
        'Accept': 'application/json, image/avif, */*',
        'Authorization': 'Bearer YOUR_TOKEN',
        'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)',
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
        'Cache-Control': 'no-cache',
      };

      debugPrint('🌐 [COMMUNITY REQUEST] URL: $url');
      debugPrint('📋 [COMMUNITY HEADERS] ${_formatHeaders(headers)}');

      final uri = Uri.parse(url);

      // API Request Overhaul: Use response.bodyBytes to avoid encoding issues
      final response = await http.get(uri, headers: headers);

      debugPrint('📦 [COMMUNITY RESPONSE] Status: ${response.statusCode}');
      debugPrint(
        '📋 [COMMUNITY RESPONSE HEADERS] ${_formatHeaders(response.headers)}',
      );

      // The 'If Not JSON, Don't Touch' Rule
      if (!response.headers['content-type']!.contains('application/json')) {
        print('📡 Not a JSON response, skipping...');
        return ApiResponse.success([]);
      }

      final decoded = json.decode(utf8.decode(response.bodyBytes));
      debugPrint('✅ [COMMUNITY SUCCESS] Articles parsed successfully');

      final List<dynamic> articlesData = List<dynamic>.from(decoded);
      final articles = List<CommunityArticle>.from(
        articlesData.map(
          (item) => CommunityArticle.fromJson(item as Map<String, dynamic>),
        ),
      );

      return ApiResponse.success(articles);
    } catch (e) {
      debugPrint('❌ [COMMUNITY SILENT GUARD] Any error: $e');
      return ApiResponse.success(
        [],
      ); // NEVER throw an error, just return empty list
    }
  }

  /// Get Period Tracker Setup (for TrackerScreen compatibility)
  Future<ApiResponse<Map<String, dynamic>>> getPeriodTrackerSetup() async {
    try {
      debugPrint('🔍 [COMMUNITY API] Fetching period tracker setup...');

      final startTime = DateTime.now();
      final response = await _makeRequest<Map<String, dynamic>>(
        'GET',
        '${ApiConfig.communityBaseUrl}/period-tracker/setup',
        requiresAuth: true,
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      debugPrint('📦 [COMMUNITY RESPONSE] Status: ${response.statusCode}');
      debugPrint('⏱️ [COMMUNITY DURATION] ${duration.inMilliseconds}ms');
      debugPrint(
        '📋 [COMMUNITY RESPONSE HEADERS] ${_formatHeaders(response.headers)}',
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);
          debugPrint('✅ [COMMUNITY SUCCESS] Period tracker setup fetched');
          return ApiResponse.success(data);
        } else {
          debugPrint('⚠️ [COMMUNITY EMPTY] Empty response body');
          return ApiResponse.success(<String, dynamic>{});
        }
      } else {
        String errorMessage = 'Service unavailable';
        try {
          if (response.body.isNotEmpty) {
            final errorData = jsonDecode(response.body);
            errorMessage =
                errorData['message'] ?? errorData['error'] ?? errorMessage;
          }
        } catch (e) {
          debugPrint('❌ [COMMUNITY ERROR] Failed to parse error response: $e');
        }

        debugPrint(
          '❌ [COMMUNITY ERROR] HTTP ${response.statusCode}: $errorMessage',
        );
        return ApiResponse.error(errorMessage, statusCode: response.statusCode);
      }
    } on SocketException catch (e, stackTrace) {
      debugPrint('❌ [COMMUNITY NETWORK] SocketException: ${e.message}');
      return ApiResponse.error('Network connection failed', statusCode: 0);
    } on TimeoutException catch (e, stackTrace) {
      debugPrint('❌ [COMMUNITY TIMEOUT] Request timed out: ${e.message}');
      return ApiResponse.error('Request timed out', statusCode: 408);
    } catch (e, stackTrace) {
      debugPrint('❌ [COMMUNITY CATCH-ALL] Any error occurred: $e');
      debugPrint('📋 [COMMUNITY STACK] ${_formatStackTrace(stackTrace)}');
      return ApiResponse.error('Unexpected error occurred', statusCode: 0);
    }
  }

  /// Get Period Tracker Summary (for TrackerScreen compatibility)
  Future<ApiResponse<Map<String, dynamic>>> getPeriodTrackerSummary(
    String month,
  ) async {
    try {
      debugPrint(
        '🔍 [COMMUNITY API] Fetching period tracker summary for month: $month',
      );

      final startTime = DateTime.now();
      final response = await _makeRequest<Map<String, dynamic>>(
        'GET',
        '${ApiConfig.communityBaseUrl}/period-tracker/summary?month=$month',
        requiresAuth: true,
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      debugPrint('📦 [COMMUNITY RESPONSE] Status: ${response.statusCode}');
      debugPrint('⏱️ [COMMUNITY DURATION] ${duration.inMilliseconds}ms');
      debugPrint(
        '📋 [COMMUNITY RESPONSE HEADERS] ${_formatHeaders(response.headers)}',
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);
          debugPrint('✅ [COMMUNITY SUCCESS] Period tracker summary fetched');
          return ApiResponse.success(data);
        } else {
          debugPrint('⚠️ [COMMUNITY EMPTY] Empty response body');
          return ApiResponse.success(<String, dynamic>{});
        }
      } else {
        String errorMessage = 'Service unavailable';
        try {
          if (response.body.isNotEmpty) {
            final errorData = jsonDecode(response.body);
            errorMessage =
                errorData['message'] ?? errorData['error'] ?? errorMessage;
          }
        } catch (e) {
          debugPrint('❌ [COMMUNITY ERROR] Failed to parse error response: $e');
        }

        debugPrint(
          '❌ [COMMUNITY ERROR] HTTP ${response.statusCode}: $errorMessage',
        );
        return ApiResponse.error(errorMessage, statusCode: response.statusCode);
      }
    } on SocketException catch (e, stackTrace) {
      debugPrint('❌ [COMMUNITY NETWORK] SocketException: ${e.message}');
      return ApiResponse.error('Network connection failed', statusCode: 0);
    } on TimeoutException catch (e, stackTrace) {
      debugPrint('❌ [COMMUNITY TIMEOUT] Request timed out: ${e.message}');
      return ApiResponse.error('Request timed out', statusCode: 408);
    } catch (e, stackTrace) {
      debugPrint('❌ [COMMUNITY CATCH-ALL] Any error occurred: $e');
      debugPrint('📋 [COMMUNITY STACK] ${_formatStackTrace(stackTrace)}');
      return ApiResponse.error('Unexpected error occurred', statusCode: 0);
    }
  }

  /// Format headers for logging
  static String _formatHeaders(Map<String, String> headers) {
    final buffer = StringBuffer();
    headers.forEach((key, value) {
      buffer.writeln('  $key: $value');
    });
    return buffer.toString();
  }

  /// Format stack trace for logging
  static String _formatStackTrace(StackTrace? stackTrace) {
    if (stackTrace == null) return 'No stack trace available';
    return stackTrace.toString().split('\n').take(10).join('\n');
  }
}
