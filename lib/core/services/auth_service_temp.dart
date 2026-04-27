import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/register_request.dart';
import '../models/login_request.dart';
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
        debugPrint('✅ Authentication token detected and saved');
      } else {
        debugPrint('ℹ️ No authentication token found in response');
      }
    } catch (e) {
      debugPrint('❌ Error detecting/saving token: $e');
    }
  }

  /// Generic HTTP request method
  Future<ApiResponse<T>> _makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    try {
      // Build URL
      String cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
      String url = '${ApiConfig.baseUrl}$cleanEndpoint';

      // Prepare headers
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

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

      // Make request
      late http.Response response;
      final uri = Uri.parse(url);

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
    } on SocketException catch (e) {
      debugPrint('🔌 SocketException: ${e.message}');
      return ApiResponse.error(
        'No internet connection. Please check your network.',
        statusCode: 0,
      );
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return ApiResponse.error('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Send OTP
  Future<ApiResponse<Map<String, dynamic>>> sendOtp({
    required String phone,
  }) async {
    try {
      final response = await _makeRequest<Map<String, dynamic>>(
        'POST',
        '/auth/otp/send',
        body: {'phone': phone},
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
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _makeRequest<Map<String, dynamic>>(
        'POST',
        '/auth/otp/verify',
        body: {'phone': phone, 'otp': otp},
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
      debugPrint('📝 Fetching testimonials: limit=$limit, offset=$offset');

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
      debugPrint('🚀 Starting registration for user: ${request.fullName}');

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
}
