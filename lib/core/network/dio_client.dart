import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Custom exceptions for better error handling
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkTimeoutException extends ApiException {
  NetworkTimeoutException(String message, {int? statusCode})
      : super(message, statusCode: statusCode);
}

class NoInternetException extends ApiException {
  NoInternetException(String message)
      : super(message, statusCode: 0);
}

/// API Configuration
class ApiConfig {
  static const String _baseUrl = 'https://api.swampurna.com';
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

/// Centralized Dio Client
class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  late final Dio _dio;

  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.timeout,
      receiveTimeout: ApiConfig.timeout,
      sendTimeout: ApiConfig.timeout,
      headers: ApiConfig.defaultHeaders,
    ));

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('API Request: ${options.method} ${options.uri}');
          debugPrint('Headers: ${options.headers}');
          if (options.data != null) debugPrint('Body: ${options.data}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('API Response: ${response.statusCode} ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('API Error: ${error.message}');
          debugPrint('Response: ${error.response?.data}');
          
          // Convert Dio exceptions to our custom exceptions
          final exception = _handleDioError(error);
          handler.reject(exception);
        },
      ),
    );
  }

  /// Handle Dio errors and convert to custom exceptions
  DioError _handleDioError(DioError error) {
    switch (error.type) {
      case DioErrorType.connectionTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        return DioError(
          requestOptions: error.requestOptions,
          error: NetworkTimeoutException('Request timeout. Please try again.'),
        );
      case DioErrorType.connectionError:
        return DioError(
          requestOptions: error.requestOptions,
          error: NoInternetException('No internet connection. Please check your network.'),
        );
      case DioErrorType.badResponse:
        final statusCode = error.response?.statusCode;
        String message = 'Request failed';
        
        if (error.response?.data != null) {
          final data = error.response!.data;
          if (data is Map<String, dynamic>) {
            message = data['message'] ?? data['error'] ?? data['detail'] ?? 'Unknown error occurred';
          }
        }
        
        // Handle specific HTTP status codes
        switch (statusCode) {
          case 400:
            message = 'Bad request: $message';
            break;
          case 401:
            message = 'Unauthorized: Please login again';
            break;
          case 403:
            message = 'Forbidden: You don\'t have permission';
            break;
          case 404:
            message = 'Not found: The requested resource was not found';
            break;
          case 429:
            message = 'Too many requests: Please try again later';
            break;
          case 500:
            message = 'Server error: Please try again later';
            break;
          case 502:
            message = 'Service unavailable: Please try again later';
            break;
          case 503:
            message = 'Service maintenance: Please try again later';
            break;
          default:
            message = 'Request failed: $message';
        }
        
        return DioError(
          requestOptions: error.requestOptions,
          response: error.response,
          error: ApiException(message, statusCode: statusCode),
        );
      case DioErrorType.cancel:
        return DioError(
          requestOptions: error.requestOptions,
          error: ApiException('Request was cancelled'),
        );
      case DioErrorType.unknown:
        return DioError(
          requestOptions: error.requestOptions,
          error: ApiException('An unexpected error occurred. Please try again.'),
        );
    }
  }

  /// Get Dio instance
  Dio get dio => _dio;

  /// Generic GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Generic POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Generic PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Generic DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
}
