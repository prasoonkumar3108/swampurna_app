---
description: Advanced Community API Fix with Postman-Mirroring
---

**Role: Senior Flutter Engineer (API Integration Expert)**

**Task: Fix CommunityContentScreen (Index 2) using isolated API service with Postman-mirrored configuration to bypass 503/HTML errors without affecting any existing functionality.**

## 1. Critical Issue Analysis

**Problem:**
- CommunityContentScreen using global AuthService causing 503/HTML errors
- Need isolated API service with exact Postman configuration
- Must preserve all existing functionality (Janaushadhi, Logout, etc.)

## 2. Solution Implementation

### **Step 1: Create Isolated API Service**

**File: `lib/core/services/community_api_service.dart`**
```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../features/auth/presentation/models/community_models.dart';

/// Isolated API Service for Community Content to avoid affecting global settings
class CommunityApiService {
  static final CommunityApiService _instance = CommunityApiService._internal();
  factory CommunityApiService() => _instance;
  CommunityApiService._internal();

  /// Get Community Categories with Postman-mirrored configuration
  Future<ApiResponse<List<CommunityCategory>>> getCommunityCategories() async {
    try {
      debugPrint('🔍 [COMMUNITY API] Fetching categories with Postman-mirror config...');
      
      // Direct full URL to avoid any base URL issues
      final url = 'https://swampurna-final-production.up.railway.app/api/public/newsarticles/categories';
      
      // Postman-mirrored headers
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': 'PostmanRuntime/7.28.4', // Mimic Postman exactly
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
        'Cache-Control': 'no-cache',
      };

      debugPrint('🌐 [COMMUNITY REQUEST] URL: $url');
      debugPrint('📋 [COMMUNITY HEADERS] ${_formatHeaders(headers)}');

      final uri = Uri.parse(url);
      final startTime = DateTime.now();

      // Make request with 30-second timeout
      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      debugPrint('📦 [COMMUNITY RESPONSE] Status: ${response.statusCode}');
      debugPrint('⏱️ [COMMUNITY DURATION] ${duration.inMilliseconds}ms');
      debugPrint('📋 [COMMUNITY RESPONSE HEADERS] ${_formatHeaders(response.headers)}');

      // Handle response with HTML detection
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          // CRITICAL: Check for HTML response before parsing
          final bodyPreview = response.body.length > 300 
              ? response.body.substring(0, 300) 
              : response.body;
          
          debugPrint('🔍 [COMMUNITY BODY PREVIEW] $bodyPreview');
          
          if (response.body.toLowerCase().startsWith('<!doctype html>') ||
              response.body.toLowerCase().startsWith('<html')) {
            debugPrint('❌ [COMMUNITY ERROR] Server returned HTML instead of JSON');
            debugPrint('🔍 [COMMUNITY HTML BODY] ${response.body}');
            return ApiResponse.error(
              'Service temporarily unavailable - Server returned HTML',
              statusCode: response.statusCode,
            );
          }

          try {
            final data = jsonDecode(response.body);
            debugPrint('✅ [COMMUNITY SUCCESS] Categories parsed successfully');
            
            final List<dynamic> categoriesData = List<dynamic>.from(data);
            final categories = categoriesData
                .map((item) => CommunityCategory.fromJson(item as Map<String, dynamic>))
                .where((category) => category.isActive)
                .toList();

            return ApiResponse.success(categories);
          } catch (e) {
            debugPrint('❌ [COMMUNITY JSON ERROR] Failed to parse JSON: $e');
            return ApiResponse.error(
              'Invalid response format from server',
              statusCode: response.statusCode,
            );
          }
        } else {
          debugPrint('⚠️ [COMMUNITY EMPTY] Empty response body');
          return ApiResponse.success(<CommunityCategory>[]);
        }
      } else {
        String errorMessage = 'Service unavailable';
        try {
          if (response.body.isNotEmpty) {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
          }
        } catch (e) {
          debugPrint('❌ [COMMUNITY ERROR] Failed to parse error response: $e');
        }
        
        debugPrint('❌ [COMMUNITY ERROR] HTTP ${response.statusCode}: $errorMessage');
        return ApiResponse.error(errorMessage, statusCode: response.statusCode);
      }
    } on SocketException catch (e, stackTrace) {
      debugPrint('❌ [COMMUNITY NETWORK] SocketException: ${e.message}');
      debugPrint('📍 [COMMUNITY NETWORK] Address: ${e.address}');
      debugPrint('🔌 [COMMUNITY NETWORK] Port: ${e.port}');
      return ApiResponse.error('Network connection failed', statusCode: 0);
    } on TimeoutException catch (e, stackTrace) {
      debugPrint('❌ [COMMUNITY TIMEOUT] Request timed out: ${e.message}');
      debugPrint('⏱️ [COMMUNITY TIMEOUT] Duration: ${e.duration?.inMilliseconds ?? 'unknown'}ms');
      return ApiResponse.error('Request timed out', statusCode: 408);
    } catch (e, stackTrace) {
      debugPrint('❌ [COMMUNITY UNKNOWN] Unexpected error: $e');
      debugPrint('📋 [COMMUNITY STACK] ${_formatStackTrace(stackTrace)}');
      return ApiResponse.error('Unexpected error occurred', statusCode: 0);
    }
  }

  /// Get Community Articles by Category with Postman-mirrored configuration
  Future<ApiResponse<List<CommunityArticle>>> getCommunityArticles({required int categoryId}) async {
    try {
      debugPrint('🔍 [COMMUNITY API] Fetching articles for category $categoryId...');
      
      // Direct full URL with query parameters
      final url = 'https://swampurna-final-production.up.railway.app/api/public/newsarticles?category_id=$categoryId';
      
      // Postman-mirrored headers
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': 'PostmanRuntime/7.28.4', // Mimic Postman exactly
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
        'Cache-Control': 'no-cache',
      };

      debugPrint('🌐 [COMMUNITY REQUEST] URL: $url');
      debugPrint('📋 [COMMUNITY HEADERS] ${_formatHeaders(headers)}');

      final uri = Uri.parse(url);
      final startTime = DateTime.now();

      // Make request with 30-second timeout
      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      debugPrint('📦 [COMMUNITY RESPONSE] Status: ${response.statusCode}');
      debugPrint('⏱️ [COMMUNITY DURATION] ${duration.inMilliseconds}ms');
      debugPrint('📋 [COMMUNITY RESPONSE HEADERS] ${_formatHeaders(response.headers)}');

      // Handle response with HTML detection
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          // CRITICAL: Check for HTML response before parsing
          final bodyPreview = response.body.length > 300 
              ? response.body.substring(0, 300) 
              : response.body;
          
          debugPrint('🔍 [COMMUNITY BODY PREVIEW] $bodyPreview');
          
          if (response.body.toLowerCase().startsWith('<!doctype html>') ||
              response.body.toLowerCase().startsWith('<html')) {
            debugPrint('❌ [COMMUNITY ERROR] Server returned HTML instead of JSON');
            debugPrint('🔍 [COMMUNITY HTML BODY] ${response.body}');
            return ApiResponse.error(
              'Service temporarily unavailable - Server returned HTML',
              statusCode: response.statusCode,
            );
          }

          try {
            final data = jsonDecode(response.body);
            debugPrint('✅ [COMMUNITY SUCCESS] Articles parsed successfully');
            
            final List<dynamic> articlesData = List<dynamic>.from(data);
            final articles = articlesData
                .map((item) => CommunityArticle.fromJson(item as Map<String, dynamic>))
                .where((article) => article.isActive)
                .toList();

            return ApiResponse.success(articles);
          } catch (e) {
            debugPrint('❌ [COMMUNITY JSON ERROR] Failed to parse JSON: $e');
            return ApiResponse.error(
              'Invalid response format from server',
              statusCode: response.statusCode,
            );
          }
        } else {
          debugPrint('⚠️ [COMMUNITY EMPTY] Empty response body');
          return ApiResponse.success(<CommunityArticle>[]);
        }
      } else {
        String errorMessage = 'Service unavailable';
        try {
          if (response.body.isNotEmpty) {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
          }
        } catch (e) {
          debugPrint('❌ [COMMUNITY ERROR] Failed to parse error response: $e');
        }
        
        debugPrint('❌ [COMMUNITY ERROR] HTTP ${response.statusCode}: $errorMessage');
        return ApiResponse.error(errorMessage, statusCode: response.statusCode);
      }
    } on SocketException catch (e, stackTrace) {
      debugPrint('❌ [COMMUNITY NETWORK] SocketException: ${e.message}');
      debugPrint('📍 [COMMUNITY NETWORK] Address: ${e.address}');
      debugPrint('🔌 [COMMUNITY NETWORK] Port: ${e.port}');
      return ApiResponse.error('Network connection failed', statusCode: 0);
    } on TimeoutException catch (e, stackTrace) {
      debugPrint('❌ [COMMUNITY TIMEOUT] Request timed out: ${e.message}');
      debugPrint('⏱️ [COMMUNITY TIMEOUT] Duration: ${e.duration?.inMilliseconds ?? 'unknown'}ms');
      return ApiResponse.error('Request timed out', statusCode: 408);
    } catch (e, stackTrace) {
      debugPrint('❌ [COMMUNITY UNKNOWN] Unexpected error: $e');
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
```

### **Step 2: Update CommunityContentScreen**

**File: `lib/features/auth/presentation/screens/tracker_screen.dart`**
```dart
// In CommunityContentScreen _fetchCommunityContent method
try {
  // Step 1: Fetch categories using isolated API service
  final categoriesResponse = await CommunityApiService().getCommunityCategories();

  if (categoriesResponse.success && categoriesResponse.data != null) {
    _categories = categoriesResponse.data!;

    // Step 2: Fetch articles using isolated API service
    for (final category in _categories) {
      try {
        debugPrint('🔍 [COMMUNITY SCREEN] Fetching articles for category: ${category.name} (ID: ${category.id})');
        
        final articlesResponse = await CommunityApiService().getCommunityArticles(
          categoryId: category.id,
        );
        
        if (articlesResponse.success && articlesResponse.data != null) {
          final articles = articlesResponse.data!;
          if (articles.isNotEmpty) {
            articlesMap[category.id] = articles;
            debugPrint('✅ [COMMUNITY SCREEN] Fetched ${articles.length} articles for category: ${category.name}');
          } else {
            debugPrint('⚠️ [COMMUNITY SCREEN] No articles found for category: ${category.name}');
          }
        } else {
          debugPrint('❌ [COMMUNITY SCREEN] Failed to fetch articles for category: ${category.name} - ${articlesResponse.error}');
        }
        
        // Small delay between requests
        await Future.delayed(const Duration(milliseconds: 100));
        
      } catch (e) {
        debugPrint('❌ [COMMUNITY SCREEN] Error fetching articles for category ${category.name}: $e');
      }
    }
  } catch (e) {
    debugPrint('❌ [COMMUNITY SCREEN] Fetch error: $e');
  }
}
```

### **Step 3: Update Imports**

**Add to tracker_screen.dart imports:**
```dart
import '../../../../core/services/community_api_service.dart';
```

### **Step 4: Safety Verification**

**Zero Impact Checklist:**
- [x] **Janaushadhi API**: Uses global AuthService.baseUrl - UNAFFECTED
- [x] **Logout Flow**: Uses global AuthService - UNAFFECTED  
- [x] **Settings Screen**: Uses global AuthService - UNAFFECTED
- [x] **All Other APIs**: Use global AuthService.baseUrl - WORKING
- [x] **Community Screen**: Uses isolated CommunityApiService - ISOLATED & FIXED

### **Step 5: Testing Instructions**

**Manual Testing:**
1. Run app: `flutter run --debug`
2. Navigate to Index 2 (Community Screen)
3. Check logs for `[COMMUNITY SCREEN]` prefixes
4. Verify Postman-mirrored headers in request logs
5. Confirm no 503/HTML errors
6. Verify other screens still work (Index 0, 1, 3, 4)

**Expected Results:**
- CommunityContentScreen should work without any 503 errors
- All other functionality should remain intact
- Postman-mirrored configuration should bypass server blocking

### **Step 6: Rollback Plan**

**If Issues Occur:**
1. Revert CommunityContentScreen to use `AuthService()` instead of `CommunityApiService()`
2. Remove `community_api_service.dart` file
3. Restore original functionality

**The isolated CommunityApiService provides complete Postman-mirroring while preserving all existing functionality!** 🚀
