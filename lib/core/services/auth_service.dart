import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/register_request.dart';
import 'token_storage_service.dart';

/// Custom API exceptions for better error handling
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Authentication Service
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Detect and save authentication token from API response
  Future<void> _detectAndSaveToken(Map<String, dynamic> responseData) async {
    try {
      // Check for various token field names
      final possibleTokenKeys = [
        'token',
        'access_token',
        'jwt',
        'auth_token',
        'bearer_token',
      ];
      String? token;

      for (final key in possibleTokenKeys) {
        if (responseData.containsKey(key) && responseData[key] != null) {
          token = responseData[key].toString();
          break;
        }
      }

      // Also check nested data structures
      if (token == null && responseData.containsKey('data')) {
        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          for (final key in possibleTokenKeys) {
            if (data.containsKey(key) && data[key] != null) {
              token = data[key].toString();
              break;
            }
          }
        }
      }

      // Save token if found
      if (token != null && token.isNotEmpty) {
        await TokenStorageService.instance.saveToken(token);
        await TokenStorageService.instance.saveLoginSession(
          true,
        ); // Save login session flag
        debugPrint('✅ Authentication token and login session saved');
      } else {
        debugPrint('ℹ️ No authentication token found in response');
      }
    } catch (e) {
      debugPrint('❌ Error detecting/saving token: $e');
    }
  }

  /// Generic HTTP request method with comprehensive logging (CORS proxy only for web)
  Future<ApiResponse<T>> _makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = true,
    bool useCorsProxy = kIsWeb, // Only enable CORS proxy for web development
  }) async {
    try {
      // Build URL
      String cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
      String url = '${ApiConfig.baseUrl}$cleanEndpoint';

      // CORS Proxy for Web Development Only
      if (useCorsProxy) {
        const String proxyUrl = 'https://cors-anywhere.herokuapp.com/';
        url = '$proxyUrl$url';
        debugPrint('🌐 [CORS PROXY] Enabled for Web Development');
        debugPrint('🔗 Original URL: ${ApiConfig.baseUrl}$cleanEndpoint');
        debugPrint('🔗 Proxy URL: $url');
      }

      // Prepare headers
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add CORS headers for web development only
      if (kIsWeb) {
        requestHeaders['Origin'] =
            'https://localhost:3000'; // Development origin
        requestHeaders['X-Requested-With'] = 'XMLHttpRequest';
        debugPrint('🌐 [CORS HEADERS] Added Origin and X-Requested-With');
      }

      // Add authorization header if required
      if (requiresAuth) {
        final token = await TokenStorageService.instance.getToken();
        if (token != null && token.isNotEmpty) {
          requestHeaders['Authorization'] = 'Bearer $token';
        }
      }

      // Add custom headers
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      // 🔍 REQUEST LOGGING
      debugPrint('\n🌐 [API REQUEST] --> $method $url');
      debugPrint('📋 Headers: ${_formatHeadersForLog(requestHeaders)}');
      if (body != null) {
        debugPrint('📦 Body: ${_formatJsonForLog(body)}');
      } else {
        debugPrint('📦 Body: (empty)');
      }
      debugPrint('🔐 Auth Required: $requiresAuth');
      debugPrint('⏰ Timestamp: ${DateTime.now().toIso8601String()}');

      // Make request
      late http.Response response;
      final uri = Uri.parse(url);
      final startTime = DateTime.now();

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: requestHeaders);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: requestHeaders);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      // 🔍 RESPONSE LOGGING
      debugPrint('\n📬 [API RESPONSE] <-- $method $url');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('⏱️ Duration: ${duration.inMilliseconds}ms');
      debugPrint(
        '📋 Response Headers: ${_formatHeadersForLog(response.headers)}',
      );

      if (response.body.isNotEmpty) {
        try {
          final parsedBody = jsonDecode(response.body);
          debugPrint('📦 Response Body: ${_formatJsonForLog(parsedBody)}');
        } catch (e) {
          debugPrint('📦 Response Body (raw): ${response.body}');
        }
      } else {
        debugPrint('📦 Response Body: (empty)');
      }
      debugPrint('⏰ Timestamp: ${endTime.toIso8601String()}');

      // Handle response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);
          return ApiResponse.success(
            data as T,
            statusCode: response.statusCode,
          );
        } else {
          return ApiResponse.success(
            null as T,
            statusCode: response.statusCode,
          );
        }
      } else {
        String errorMessage = 'Request failed';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage =
              errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (e) {
          errorMessage =
              'HTTP ${response.statusCode}: ${response.reasonPhrase}';
        }
        return ApiResponse.error(errorMessage, statusCode: response.statusCode);
      }
    } on SocketException catch (e, stackTrace) {
      // 🔍 ERROR LOGGING - SocketException
      debugPrint('\n❌ [API ERROR] <-- SocketException');
      debugPrint('🔥 Error: ${e.message}');
      debugPrint('📍 Address: ${e.address}');
      debugPrint('🔗 Port: ${e.port}');
      debugPrint('📋 Stack Trace:\n${_formatStackTrace(stackTrace)}');
      debugPrint('⏰ Timestamp: ${DateTime.now().toIso8601String()}');

      return ApiResponse.error(
        'No internet connection. Please check your network.',
        statusCode: 0,
      );
    } on TimeoutException catch (e, stackTrace) {
      // 🔍 ERROR LOGGING - TimeoutException
      debugPrint('\n❌ [API ERROR] <-- TimeoutException');
      debugPrint('🔥 Error: ${e.message}');
      debugPrint('⏱️ Duration: ${e.duration?.inMilliseconds ?? 'unknown'}ms');
      debugPrint('📋 Stack Trace:\n${_formatStackTrace(stackTrace)}');
      debugPrint('⏰ Timestamp: ${DateTime.now().toIso8601String()}');

      return ApiResponse.error(
        'Request timed out. Please check your connection.',
        statusCode: 408,
      );
    } on http.ClientException catch (e, stackTrace) {
      // 🔍 ERROR LOGGING - ClientException (CORS/Web Issues)
      debugPrint('\n❌ [API ERROR] <-- ClientException');
      debugPrint('🔥 Error: ${e.message}');
      debugPrint('🌐 URL: ${e.uri}');
      debugPrint('📋 Stack Trace:\n${_formatStackTrace(stackTrace)}');
      debugPrint('⏰ Timestamp: ${DateTime.now().toIso8601String()}');

      // Check for common CORS/Mixed Content issues
      String errorMessage = 'Network request failed';
      if (e.message.toLowerCase().contains('cors')) {
        errorMessage =
            'CORS policy blocked this request. The server may need to allow your origin.';
        debugPrint('🚫 CORS Issue Detected: ${e.message}');
      } else if (e.message.toLowerCase().contains('mixed content')) {
        errorMessage =
            'Mixed content error. The page was loaded over HTTPS but requested an HTTP resource.';
        debugPrint('🚫 Mixed Content Issue Detected: ${e.message}');
      } else if (e.message.toLowerCase().contains('certificate')) {
        errorMessage =
            'SSL certificate error. The server certificate may be invalid.';
        debugPrint('🚫 SSL Certificate Issue Detected: ${e.message}');
      } else if (e.message.toLowerCase().contains('connection')) {
        errorMessage =
            'Connection failed. Please check if the server is reachable.';
        debugPrint('🚫 Connection Issue Detected: ${e.message}');
      }

      return ApiResponse.error(errorMessage, statusCode: 0);
    } catch (e, stackTrace) {
      // 🔍 ERROR LOGGING - General Exception
      debugPrint('\n❌ [API ERROR] <-- General Exception');
      debugPrint('🔥 Error: $e');
      debugPrint('🔍 Type: ${e.runtimeType}');
      debugPrint('📋 Stack Trace:\n${_formatStackTrace(stackTrace)}');
      debugPrint('⏰ Timestamp: ${DateTime.now().toIso8601String()}');

      return ApiResponse.error('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Format headers for readable logging
  String _formatHeadersForLog(Map<String, dynamic> headers) {
    if (headers.isEmpty) return '(empty)';

    final formatted = headers.entries
        .map((entry) {
          String value = entry.value;
          // Mask sensitive headers
          if (entry.key.toLowerCase().contains('authorization') &&
              value.length > 20) {
            value = '${value.substring(0, 20)}...[MASKED]';
          }
          return '${entry.key}: $value';
        })
        .join(', ');

    return '{$formatted}';
  }

  /// Format JSON for readable logging
  String _formatJsonForLog(dynamic json) {
    try {
      return const JsonEncoder.withIndent('  ').convert(json);
    } catch (e) {
      return json.toString();
    }
  }

  /// Format stack trace for readable logging
  String _formatStackTrace(StackTrace stackTrace) {
    final lines = stackTrace.toString().split('\n');
    // Show only first 10 lines to keep logs readable
    final relevantLines = lines.take(10).join('\n');
    if (lines.length > 10) {
      return '$relevantLines\n... (${lines.length - 10} more lines)';
    }
    return relevantLines;
  }

  /// Send OTP - Dynamic method for both email and phone
  Future<ApiResponse<Map<String, dynamic>>> sendOtp({
    String? email,
    String? phone,
    String purpose = 'login',
  }) async {
    try {
      final Map<String, dynamic> body = {'purpose': purpose};

      if (email != null) {
        body['email'] = email;
      } else if (phone != null) {
        body['phone'] = phone;
      } else {
        return ApiResponse.error('Either email or phone must be provided');
      }

      final response = await _makeRequest<Map<String, dynamic>>(
        'POST',
        '/auth/otp/send',
        body: body,
        requiresAuth: false,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(e.message, statusCode: e.statusCode);
      }
      return ApiResponse.error('Failed to send OTP: ${e.toString()}');
    }
  }

  /// Verify OTP
  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    String? phone,
    String? email,
    required String otp,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'otp': otp,
        'purpose': 'login', // Required field for login flow
      };

      if (phone != null) {
        body['phone'] = phone;
      } else if (email != null) {
        body['email'] = email;
      } else {
        return ApiResponse.error('Either phone or email must be provided');
      }

      final response = await _makeRequest<Map<String, dynamic>>(
        'POST',
        '/auth/otp/verify',
        body: body,
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        debugPrint('✅ OTP verification successful');

        // Detect and save token from response
        await _detectAndSaveToken(response.data!);
      }

      return response;
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(e.message, statusCode: e.statusCode);
      }
      return ApiResponse.error('Failed to verify OTP: ${e.toString()}');
    }
  }

  /// Fetch testimonials with pagination
  Future<ApiResponse<Map<String, dynamic>>> fetchTestimonials({
    required int limit,
    required int offset,
  }) async {
    try {
      debugPrint('� Fetching testimonials: limit=$limit, offset=$offset');

      // Build URL with query parameters
      final endpoint = '/testimonials?limit=$limit&offset=$offset';

      // Check if we have a token for authenticated requests
      final token = await TokenStorageService.instance.getToken();
      final requiresAuth = token != null && token.isNotEmpty;

      final response = await _makeRequest<Map<String, dynamic>>(
        'GET',
        endpoint,
        requiresAuth: requiresAuth,
      );

      debugPrint('✅ Testimonials fetched successfully');
      return response;
    } catch (e) {
      debugPrint('❌ Testimonials fetch error: $e');
      if (e is ApiException) {
        return ApiResponse.error(e.message, statusCode: e.statusCode);
      }
      return ApiResponse.error('Failed to fetch testimonials: ${e.toString()}');
    }
  }

  /// Register a new user
  Future<ApiResponse<Map<String, dynamic>>> registerUser(
    RegisterRequest request,
  ) async {
    try {
      debugPrint('� Starting registration for user: ${request.fullName}');

      final response = await _makeRequest<Map<String, dynamic>>(
        'POST',
        '/auth/register',
        body: request.toJson(),
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        debugPrint('✅ Registration successful');

        // Detect and save token from response
        await _detectAndSaveToken(response.data!);
      }

      return response;
    } catch (e) {
      debugPrint('❌ Registration error: $e');
      if (e is ApiException) {
        return ApiResponse.error(e.message, statusCode: e.statusCode);
      }
      return ApiResponse.error('Registration failed: ${e.toString()}');
    }
  }

  /// Verify OTP for registration
  Future<ApiResponse<Map<String, dynamic>>> verifyRegistrationOtp({
    required String email,
    required String otp,
  }) async {
    try {
      debugPrint('🔐 Verifying registration OTP for email: $email');

      final response = await _makeRequest<Map<String, dynamic>>(
        'POST',
        '/auth/register/otp/verify',
        body: {'email': email, 'otp': otp},
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        debugPrint('✅ Registration OTP verification successful');

        // Detect and save token from response
        await _detectAndSaveToken(response.data!);
      }

      return response;
    } catch (e) {
      debugPrint('❌ Registration OTP verification error: $e');
      if (e is ApiException) {
        return ApiResponse.error(e.message, statusCode: e.statusCode);
      }
      return ApiResponse.error('OTP verification failed: ${e.toString()}');
    }
  }

  /// Logout user and clear session
  Future<void> logout() async {
    try {
      await TokenStorageService.instance.logout();
      debugPrint('✅ User logged out successfully');
    } catch (e) {
      debugPrint('❌ Error during logout: $e');
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await TokenStorageService.instance.hasValidLoginSession();
  }

  /// Login with PIN
  Future<ApiResponse<Map<String, dynamic>>> loginWithPIN({
    required String email,
    required String pin,
  }) async {
    try {
      final Map<String, dynamic> body = {'email': email, 'pin': pin};

      final response = await _makeRequest<Map<String, dynamic>>(
        'POST',
        '/auth/login/pin',
        body: body,
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        debugPrint('✅ PIN login successful');

        // Detect and save token from response
        await _detectAndSaveToken(response.data!);
      }

      return response;
    } catch (e) {
      debugPrint('❌ PIN login error: $e');
      if (e is ApiException) {
        return ApiResponse.error(e.message, statusCode: e.statusCode);
      }
      return ApiResponse.error('PIN login failed: ${e.toString()}');
    }
  }

  /// Set PIN
  Future<ApiResponse<Map<String, dynamic>>> setPIN({
    required String pin,
  }) async {
    try {
      // Check if user is authenticated first
      final token = await TokenStorageService.instance.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ No authentication token found for setPIN');
        return ApiResponse.error(
          'Authentication required. Please login first.',
        );
      }

      debugPrint('🔐 Setting PIN with authenticated request');

      final Map<String, dynamic> body = {'pin': pin};

      final response = await _makeRequest<Map<String, dynamic>>(
        'POST',
        '/auth/pin/set',
        body: body,
        requiresAuth: true, // Requires authentication
      );

      if (response.success) {
        debugPrint('✅ PIN set successful');
      }

      return response;
    } catch (e) {
      debugPrint('❌ Set PIN error: $e');
      if (e is ApiException) {
        // Check for authentication errors
        if (e.statusCode == 401 ||
            e.message.toLowerCase().contains('not authenticated')) {
          debugPrint('🚫 Authentication failed for setPIN');
          return ApiResponse.error(
            'Session expired. Please login again.',
            statusCode: 401,
          );
        }
        return ApiResponse.error(e.message, statusCode: e.statusCode);
      }
      return ApiResponse.error('Failed to set PIN: ${e.toString()}');
    }
  }

  /// Verify PIN
  Future<ApiResponse<Map<String, dynamic>>> verifyPIN({
    required String pin,
  }) async {
    try {
      // Check if user is authenticated first
      final token = await TokenStorageService.instance.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ No authentication token found for verifyPIN');
        return ApiResponse.error(
          'Authentication required. Please login first.',
        );
      }

      debugPrint('🔐 Verifying PIN with authenticated request');

      final Map<String, dynamic> body = {'pin': pin};

      final response = await _makeRequest<Map<String, dynamic>>(
        'POST',
        '/auth/pin/verify',
        body: body,
        requiresAuth: true, // Requires authentication
      );

      if (response.success) {
        debugPrint('✅ PIN verification successful');
      }

      return response;
    } catch (e) {
      debugPrint('❌ Verify PIN error: $e');
      if (e is ApiException) {
        // Check for authentication errors
        if (e.statusCode == 401 ||
            e.message.toLowerCase().contains('not authenticated')) {
          debugPrint('🚫 Authentication failed for verifyPIN');
          return ApiResponse.error(
            'Session expired. Please login again.',
            statusCode: 401,
          );
        }
        return ApiResponse.error(e.message, statusCode: e.statusCode);
      }
      return ApiResponse.error('PIN verification failed: ${e.toString()}');
    }
  }

  /// Fetch Period Tracker Setup data
  Future<ApiResponse<Map<String, dynamic>>> fetchPeriodTrackerSetup() async {
    try {
      debugPrint('🔄 Fetching period tracker setup data');

      final response = await _makeRequest<Map<String, dynamic>>(
        'GET',
        '/period-tracker/setup',
        requiresAuth: true, // Requires Bearer token
      );

      debugPrint('✅ Period tracker setup data fetched successfully');
      return response;
    } catch (e) {
      debugPrint('❌ Period tracker setup fetch error: $e');
      if (e is ApiException) {
        return ApiResponse.error(e.message, statusCode: e.statusCode);
      }
      return ApiResponse.error(
        'Failed to fetch period tracker setup: ${e.toString()}',
      );
    }
  }

  /// Submit onboarding data
  Future<ApiResponse<Map<String, dynamic>>> submitOnboardingData(
    Map<String, dynamic> onboardingData,
  ) async {
    try {
      print("ONBOARDING API HIT");
      print(
        "URL: https://swampurna-final-production.up.railway.app/api/v1/customers/onboarding",
      );
      print("PAYLOAD: $onboardingData");
      print(
        "HEADERS: Authorization: Bearer <token>, Content-Type: application/json",
      );

      debugPrint('🚀 Submitting onboarding data: $onboardingData');

      final response = await _makeRequest<Map<String, dynamic>>(
        'POST',
        '/customers/onboarding',
        body: onboardingData,
        requiresAuth: true,
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE DATA: ${response.data}");

      // SUCCESS: HTTP 200 or 201 with data
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Onboarding data submitted successfully');
        return ApiResponse(
          success: true,
          statusCode: response.statusCode,
          data: response.data,
          error: null,
        );
      } else {
        final errorMessage =
            response.error ?? 'Failed to submit onboarding data';
        debugPrint('❌ Onboarding submission failed: $errorMessage');
        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      print("FULL ONBOARDING API EXCEPTION: $e");
      print("EXCEPTION TYPE: ${e.runtimeType}");

      debugPrint('❌ Onboarding submission error: $e');
      if (e is ApiException) {
        print("API EXCEPTION STATUS: ${e.statusCode}");
        print("API EXCEPTION MESSAGE: ${e.message}");
        return ApiResponse.error(e.message, statusCode: e.statusCode);
      }
      return ApiResponse.error(
        'Failed to submit onboarding data: ${e.toString()}',
      );
    }
  }

  /// Get period tracker setup data
  Future<ApiResponse<Map<String, dynamic>>> getPeriodTrackerSetup() async {
    try {
      debugPrint('🔄 Fetching period tracker setup data');

      final response = await _makeRequest<Map<String, dynamic>>(
        'GET',
        '/period-tracker/setup',
        requiresAuth: true,
      );

      debugPrint('📊 Period tracker setup response: ${response.data}');

      if (response.success) {
        debugPrint('✅ Period tracker setup data fetched successfully');
        return ApiResponse.success(response.data ?? {});
      } else {
        final errorMessage =
            response.error ?? 'Failed to fetch period tracker setup';
        debugPrint('❌ Period tracker setup failed: $errorMessage');
        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      debugPrint('❌ Period tracker setup error: $e');
      return ApiResponse.error(
        'Failed to fetch period tracker setup: ${e.toString()}',
      );
    }
  }

  /// Get period tracker summary data for a specific month
  Future<ApiResponse<Map<String, dynamic>>> getPeriodTrackerSummary(
    String month,
  ) async {
    try {
      debugPrint('🔄 Fetching period tracker summary for month: $month');

      final response = await _makeRequest<Map<String, dynamic>>(
        'GET',
        '/period-tracker/summary?month=$month',
        requiresAuth: true,
      );

      debugPrint('📊 Period tracker summary response: ${response.data}');

      if (response.success) {
        debugPrint('✅ Period tracker summary data fetched successfully');
        return ApiResponse.success(response.data ?? {});
      } else {
        final errorMessage =
            response.error ?? 'Failed to fetch period tracker summary';
        debugPrint('❌ Period tracker summary failed: $errorMessage');
        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      debugPrint('❌ Period tracker summary error: $e');
      return ApiResponse.error(
        'Failed to fetch period tracker summary: ${e.toString()}',
      );
    }
  }

  /// Create a new Recent Post
  Future<ApiResponse<Map<String, dynamic>>> createRecentPost({
    required String title,
    required String content,
    File? imageFile,
    String? imageUrl,
  }) async {
    try {
      debugPrint('🔄 Creating Recent Post...');
      debugPrint('📝 Title: $title');
      debugPrint('📄 Content: ${content.length} characters');
      debugPrint('🖼️ Has Image: ${imageFile != null}');
      debugPrint('🔗 Image URL: $imageUrl');

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'title': title,
        'content': content,
      };

      // Add image URL if provided (either from uploaded image or existing URL)
      if (imageUrl != null && imageUrl.isNotEmpty) {
        requestBody['image_url'] = imageUrl;
        debugPrint('📸 Using uploaded image URL: $imageUrl');
      } else if (imageFile != null) {
        // Fallback for now - in production this should never happen
        debugPrint('⚠️ Image file provided but no URL - using placeholder');
        requestBody['image_url'] = 'https://via.placeholder.com/400x300.png';
      }

      final response = await _makeRequest<Map<String, dynamic>>(
        'POST',
        '/posts',
        body: requestBody,
        requiresAuth: true,
      );

      debugPrint('📊 Create Recent Post response: ${response.data}');

      if (response.success) {
        debugPrint('✅ Recent Post created successfully');
        return ApiResponse.success(response.data ?? {});
      } else {
        final errorMessage = response.error ?? 'Failed to create recent post';
        debugPrint('❌ Create Recent Post failed: $errorMessage');
        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      debugPrint('❌ Create Recent Post error: $e');
      return ApiResponse.error('Failed to create recent post: ${e.toString()}');
    }
  }

  /// Create a new Cycle Snap
  Future<ApiResponse<Map<String, dynamic>>> createCycleSnap({
    required String title,
    required String description,
    File? mediaFile,
    String? mediaUrl,
  }) async {
    try {
      debugPrint('🔄 Creating Cycle Snap...');
      debugPrint('📝 Title: $title');
      debugPrint('📄 Description: ${description.length} characters');
      debugPrint('🎬 Has Media: ${mediaFile != null}');
      debugPrint('🔗 Media URL: $mediaUrl');

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'title': title,
        'description': description,
        'media_type': mediaFile != null ? 'image' : 'text',
      };

      // Add media URL if provided (either from uploaded media or existing URL)
      if (mediaUrl != null && mediaUrl.isNotEmpty) {
        requestBody['media_url'] = mediaUrl;
        debugPrint('📸 Using uploaded media URL: $mediaUrl');
      } else if (mediaFile != null) {
        // Fallback for now - in production this should never happen
        debugPrint('⚠️ Media file provided but no URL - using placeholder');
        requestBody['media_url'] = 'https://via.placeholder.com/400x300.png';
      }

      final response = await _makeRequest<Map<String, dynamic>>(
        'POST',
        '/cycle-snaps',
        body: requestBody,
        requiresAuth: true,
      );

      debugPrint('📊 Create Cycle Snap response: ${response.data}');

      if (response.success) {
        debugPrint('✅ Cycle Snap created successfully');
        return ApiResponse.success(response.data ?? {});
      } else {
        final errorMessage = response.error ?? 'Failed to create cycle snap';
        debugPrint('❌ Create Cycle Snap failed: $errorMessage');
        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      debugPrint('❌ Create Cycle Snap error: $e');
      return ApiResponse.error('Failed to create cycle snap: ${e.toString()}');
    }
  }
}
