import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';

/// API Response wrapper for handling success/error states
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse({required this.success, this.data, this.error, this.statusCode});

  factory ApiResponse.success(T? data, {int? statusCode}) {
    return ApiResponse<T>(success: true, data: data, statusCode: statusCode);
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse<T>(success: false, error: error, statusCode: statusCode);
  }
}

/// Custom API exceptions for better error handling
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Network timeout exception
class NetworkTimeoutException extends ApiException {
  NetworkTimeoutException(String message, {int? statusCode})
    : super(message, statusCode: statusCode);
}

/// No internet connection exception
class NoInternetException extends ApiException {
  NoInternetException(String message) : super(message, statusCode: 0);
}

/// API Configuration
class ApiConfig {
  static const String _baseUrl =
      'https://swampurna-final-production.up.railway.app/api/v1';
  static const Duration _timeout = Duration(seconds: 30);
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static String get baseUrl => _baseUrl;
  static Duration get timeout => _timeout;
  static Map<String, String> get defaultHeaders => _defaultHeaders;

  /// Get auth headers with token if available
  static Future<Map<String, String>> getAuthHeaders() async {
    final headers = Map<String, String>.from(_defaultHeaders);

    // TODO: Replace with actual token management
    // final token = await TokenManager.getToken();
    // if (token != null) {
    //   headers['Authorization'] = 'Bearer $token';
    // }

    return headers;
  }
}

/// User registration request model
class RegisterRequest {
  final String fullName;
  final String? email;
  final String phoneNumber;
  final String birthDate;
  final String password;

  RegisterRequest({
    required this.fullName,
    this.email,
    required this.phoneNumber,
    required this.birthDate,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'birth_date': birthDate,
      'password': password,
    };
  }
}

/// User registration response model
class RegisterResponse {
  final String userId;
  final String token;
  final String name;
  final String email;

  RegisterResponse({
    required this.userId,
    required this.token,
    required this.name,
    required this.email,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      userId: json['user_id'] ?? '',
      token: json['token'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

/// Authentication Service
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Generic HTTP request method using HttpClient
  Future<ApiResponse<T>> _makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = true,
    bool useHttps = true,
  }) async {
    try {
      // Ensure endpoint starts with / and base URL doesn't end with /
      String cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
      String cleanBaseUrl = ApiConfig.baseUrl.endsWith('/')
          ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
          : ApiConfig.baseUrl;

      // Allow HTTP fallback for testing when HTTPS fails due to permissions
      String protocolUrl = cleanBaseUrl;
      if (!useHttps) {
        protocolUrl = cleanBaseUrl.replaceFirst('https://', 'http://');
      }

      final uri = Uri.parse('$protocolUrl$cleanEndpoint');
      debugPrint('🌐 Full URL: $uri');
      debugPrint('🔒 HTTPS: $useHttps');

      final requestHeaders = requiresAuth
          ? await ApiConfig.getAuthHeaders()
          : ApiConfig.defaultHeaders;

      // Add custom headers if provided
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      debugPrint('API Request: $method $uri');
      debugPrint('Headers: $requestHeaders');
      if (body != null) debugPrint('Body: $body');

      final client = HttpClient();
      client.connectionTimeout = ApiConfig.timeout;
      client.idleTimeout = ApiConfig.timeout;

      HttpClientRequest request;
      switch (method.toUpperCase()) {
        case 'GET':
          request = await client.getUrl(uri);
          break;
        case 'POST':
          request = await client.postUrl(uri);
          break;
        case 'PUT':
          request = await client.putUrl(uri);
          break;
        case 'DELETE':
          request = await client.deleteUrl(uri);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      // Set headers
      requestHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });

      // Add body for POST/PUT requests
      if (body != null &&
          (method.toUpperCase() == 'POST' || method.toUpperCase() == 'PUT')) {
        request.add(utf8.encode(jsonEncode(body)));
      }

      final response = await request.close().timeout(ApiConfig.timeout);

      final responseBody = await response.transform(utf8.decoder).join();
      final statusCode = response.statusCode;

      debugPrint('API Response: $statusCode $responseBody');

      return _handleResponse<T>(statusCode, responseBody);
    } on SocketException catch (e) {
      debugPrint('🔌 SocketException details: ${e.message}');
      debugPrint('🔌 SocketException type: ${e.runtimeType}');
      debugPrint('🔌 SocketException toString: ${e.toString()}');

      // Check for specific macOS network permission issues
      if (e.toString().contains('Operation not permitted') ||
          e.toString().contains('errno = 1')) {
        debugPrint('🍎 macOS Network Permission Issue Detected');
        debugPrint('🍎 Solutions:');
        debugPrint(
          '   1. Check System Preferences > Security & Privacy > Network',
        );
        debugPrint(
          '   2. Try running app with different network configuration',
        );
        debugPrint('   3. Check if firewall is blocking the connection');
        throw NoInternetException(
          'Network permission denied. Please check your macOS security settings.',
        );
      }

      // Check for DNS resolution issues
      if (e.toString().contains('No address associated with hostname') ||
          e.toString().contains('Host not found')) {
        debugPrint('🌍 DNS Resolution Issue Detected');
        debugPrint('🌍 Solutions:');
        debugPrint('   1. Check if the domain name is correct');
        debugPrint('   2. Try using a different network (VPN/DNS)');
        throw NoInternetException(
          'DNS resolution failed. Please check the API URL.',
        );
      }

      // Check for SSL/TLS issues
      if (e.toString().contains('SSL') ||
          e.toString().contains('TLS') ||
          e.toString().contains('certificate')) {
        debugPrint('🔒 SSL/TLS Issue Detected');
        debugPrint('🔒 Solutions:');
        debugPrint('   1. Check if SSL certificate is valid');
        debugPrint('   2. Try HTTP instead of HTTPS for testing');
        throw NoInternetException(
          'SSL/TLS connection failed. Please check server certificate.',
        );
      }

      throw NoInternetException(
        'Network connection failed. Please check your internet connection.',
      );
    } on TimeoutException catch (e) {
      debugPrint('⏰ TimeoutException details: ${e.message}');
      debugPrint('⏰ TimeoutException type: ${e.runtimeType}');
      debugPrint('⏰ TimeoutException toString: ${e.toString()}');
      throw NetworkTimeoutException('Request timeout. Please try again.');
    } on FormatException catch (e) {
      debugPrint('🔗 URI FormatException: ${e.message}');
      debugPrint('🔗 FormatException type: ${e.runtimeType}');
      debugPrint('🔗 FormatException toString: ${e.toString()}');
      throw ApiException('Invalid URL format. Please check API configuration.');
    } catch (e) {
      debugPrint('💥 Unexpected error: $e');
      debugPrint('💥 Error type: ${e.runtimeType}');
      debugPrint('💥 Error toString: ${e.toString()}');
      throw ApiException('An unexpected error occurred. Please try again.');
    }
  }

  /// Handle HTTP response and create appropriate ApiResponse
  ApiResponse<T> _handleResponse<T>(int? statusCode, String responseBody) {
    if (statusCode != null && statusCode! >= 200 && statusCode! < 300) {
      if (responseBody.isEmpty) {
        return ApiResponse.success(null, statusCode: statusCode);
      }

      try {
        final jsonData = jsonDecode(responseBody);
        return ApiResponse.success(jsonData, statusCode: statusCode);
      } catch (e) {
        debugPrint('JSON parsing error: $e');
        return ApiResponse.error(
          'Failed to parse response data',
          statusCode: statusCode,
        );
      }
    }

    // Handle error responses
    String errorMessage = 'Request failed';
    if (responseBody.isNotEmpty) {
      try {
        final errorData = jsonDecode(responseBody);
        if (errorData is Map<String, dynamic>) {
          errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              errorData['detail'] ??
              'Unknown error occurred';
        }
      } catch (e) {
        debugPrint('Error parsing error response: $e');
      }
    }

    // Handle specific HTTP status codes
    switch (statusCode) {
      case 400:
        errorMessage = 'Bad request: $errorMessage';
        break;
      case 401:
        errorMessage = 'Unauthorized: Please login again';
        break;
      case 403:
        errorMessage = 'Forbidden: You don\'t have permission';
        break;
      case 404:
        errorMessage = 'Not found: The requested resource was not found';
        break;
      case 429:
        errorMessage = 'Too many requests: Please try again later';
        break;
      case 500:
        errorMessage = 'Server error: Please try again later';
        break;
      case 502:
        errorMessage = 'Service unavailable: Please try again later';
        break;
      case 503:
        errorMessage = 'Service maintenance: Please try again later';
        break;
      default:
        errorMessage = 'Request failed: $errorMessage';
    }

    return ApiResponse.error(errorMessage, statusCode: statusCode);
  }

  /// Register a new user
  Future<ApiResponse<RegisterResponse>> registerUser(
    RegisterRequest request,
  ) async {
    try {
      debugPrint('🚀 Starting registration for user: ${request.fullName}');

      // Try HTTPS first, fall back to HTTP if permission denied
      ApiResponse<Map<String, dynamic>> response;
      try {
        response = await _makeRequest<Map<String, dynamic>>(
          'POST',
          '/auth/register',
          body: request.toJson(),
          requiresAuth: false,
          useHttps: true,
        );
      } catch (e) {
        if (e.toString().contains('Operation not permitted') ||
            e.toString().contains('errno = 1')) {
          debugPrint('🔄 HTTPS failed due to permissions, trying HTTP...');
          response = await _makeRequest<Map<String, dynamic>>(
            'POST',
            '/auth/register',
            body: request.toJson(),
            requiresAuth: false,
            useHttps: false,
          );
        } else {
          rethrow;
        }
      }

      if (response.success && response.data != null) {
        final registerResponse = RegisterResponse.fromJson(response.data!);
        debugPrint('✅ Registration successful: ${registerResponse.userId}');
        return ApiResponse.success(
          registerResponse,
          statusCode: response.statusCode,
        );
      } else {
        debugPrint('❌ Registration failed: ${response.error}');
        return ApiResponse.error(
          response.error ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      debugPrint('🔌 SocketException during registration: ${e.message}');
      debugPrint('🔌 SocketException details: ${e.toString()}');
      return ApiResponse.error(
        'Please check your internet connection and try again',
        statusCode: 0,
      );
    } on TimeoutException catch (e) {
      debugPrint('⏰ TimeoutException during registration: ${e.message}');
      debugPrint('⏰ TimeoutException details: ${e.toString()}');
      return ApiResponse.error(
        'Request timed out. Please check your connection and try again',
        statusCode: 408,
      );
    } on ApiException catch (e) {
      debugPrint('⚠️ ApiException during registration: ${e.message}');
      return ApiResponse.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      debugPrint('💥 Unexpected error during registration: ${e.toString()}');
      debugPrint('💥 Error type: ${e.runtimeType}');
      return ApiResponse.error(
        'An unexpected error occurred. Please try again',
        statusCode: 500,
      );
    }
  }

  /// Login user
  Future<ApiResponse<Map<String, dynamic>>> loginUser({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _makeRequest<Map<String, dynamic>>(
        'POST',
        '/auth/login',
        body: {'phone': phone, 'password': password},
        requiresAuth: false,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(e.message, statusCode: e.statusCode);
      }
      return ApiResponse.error('Login failed: ${e.toString()}');
    }
  }

  /// Send OTP
  Future<ApiResponse<Map<String, dynamic>>> sendOtp({
    required String phone,
  }) async {
    try {
      final response = await _makeRequest<Map<String, dynamic>>(
        'POST',
        '/auth/send-otp',
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
        '/auth/verify-otp',
        body: {'phone': phone, 'otp': otp},
        requiresAuth: false,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(e.message, statusCode: e.statusCode);
      }
      return ApiResponse.error('Failed to verify OTP: ${e.toString()}');
    }
  }
}
