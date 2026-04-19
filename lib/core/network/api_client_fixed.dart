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

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {int? statusCode}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      error: error,
      statusCode: statusCode,
    );
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
  NoInternetException(String message)
      : super(message, statusCode: 0);
}

/// Centralized API Client Configuration
class ApiConfig {
  static const String _baseUrl = 'https://api.swampurna.com'; // Replace with actual API URL
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

/// Centralized API Client
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  /// Generic HTTP request method using HttpClient
  Future<ApiResponse<T>> _makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
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
      if (body != null && (method.toUpperCase() == 'POST' || method.toUpperCase() == 'PUT')) {
        request.add(utf8.encode(jsonEncode(body)));
      }

      final response = await request.close().timeout(ApiConfig.timeout);
      
      final responseBody = await response.transform(utf8.decoder).join();
      final statusCode = response.statusCode;

      debugPrint('API Response: $statusCode $responseBody');

      return _handleResponse<T>(statusCode, responseBody, fromJson);
    } on SocketException {
      throw NoInternetException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw NetworkTimeoutException('Request timeout. Please try again.');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw ApiException('An unexpected error occurred. Please try again.');
    }
  }

  /// Handle HTTP response and create appropriate ApiResponse
  ApiResponse<T> _handleResponse<T>(
    int? statusCode,
    String responseBody,
    T Function(dynamic)? fromJson,
  ) {
    if (statusCode != null && statusCode! >= 200 && statusCode! < 300) {
      if (responseBody.isEmpty) {
        return ApiResponse.success(null, statusCode: statusCode);
      }

      try {
        final jsonData = jsonDecode(responseBody);
        
        // Handle different response formats
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('data')) {
            final data = jsonData['data'];
            return ApiResponse.success(
              fromJson != null ? fromJson(data) : data as T,
              statusCode: statusCode,
            );
          } else {
            return ApiResponse.success(
              fromJson != null ? fromJson(jsonData) : jsonData as T,
              statusCode: statusCode,
            );
          }
        } else {
          return ApiResponse.success(
            fromJson != null ? fromJson(jsonData) : jsonData as T,
            statusCode: statusCode,
          );
        }
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
          errorMessage = errorData['message'] ??
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

  /// Convenience methods for HTTP operations
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) {
    return _makeRequest<T>('GET', endpoint,
        headers: headers, requiresAuth: requiresAuth, fromJson: fromJson);
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) {
    return _makeRequest<T>('POST', endpoint,
        body: body, headers: headers, requiresAuth: requiresAuth, fromJson: fromJson);
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) {
    return _makeRequest<T>('PUT', endpoint,
        body: body, headers: headers, requiresAuth: requiresAuth, fromJson: fromJson);
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) {
    return _makeRequest<T>('DELETE', endpoint,
        headers: headers, requiresAuth: requiresAuth, fromJson: fromJson);
  }
}
