import 'api_client.dart';

/// API Endpoints Service
/// This class provides a clean interface for all API calls
class ApiEndpoints {
  static final ApiClient _client = ApiClient();

  // ==================== AUTH ENDPOINTS ===================
  
  /// User registration
  static Future<ApiResponse<Map<String, dynamic>>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String dob,
    required String password,
  }) async {
    return _client.post<Map<String, dynamic>>(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'date_of_birth': dob,
        'password': password,
      },
    );
  }

  /// User login
  static Future<ApiResponse<Map<String, dynamic>>> loginUser({
    required String phone,
    required String password,
  }) async {
    return _client.post<Map<String, dynamic>>(
      '/auth/login',
      body: {
        'phone': phone,
        'password': password,
      },
    );
  }

  /// Send OTP
  static Future<ApiResponse<Map<String, dynamic>>> sendOtp({
    required String phone,
  }) async {
    return _client.post<Map<String, dynamic>>(
      '/auth/send-otp',
      body: {'phone': phone},
    );
  }

  /// Verify OTP
  static Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    return _client.post<Map<String, dynamic>>(
      '/auth/verify-otp',
      body: {
        'phone': phone,
        'otp': otp,
      },
    );
  }

  // ==================== USER PROFILE ENDPOINTS ===================

  /// Get user profile
  static Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    return _client.get<Map<String, dynamic>>('/user/profile');
  }

  /// Update user profile
  static Future<ApiResponse<Map<String, dynamic>>> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? dob,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;
    if (dob != null) body['date_of_birth'] = dob;

    return _client.put<Map<String, dynamic>>(
      '/user/profile',
      body: body.isNotEmpty ? body : null,
    );
  }

  // ==================== HEALTH TRACKING ENDPOINTS ===================

  /// Get cycle data
  static Future<ApiResponse<List<Map<String, dynamic>>>> getCycleData({
    String? startDate,
    String? endDate,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (limit != null) queryParams['limit'] = limit.toString();

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    
    return _client.get<List<Map<String, dynamic>>('/cycles?$queryString');
  }

  /// Add cycle entry
  static Future<ApiResponse<Map<String, dynamic>>> addCycleEntry({
    required String startDate,
    required String endDate,
    int? flowIntensity,
    String? notes,
    List<String>? symptoms,
  }) async {
    return _client.post<Map<String, dynamic>>(
      '/cycles',
      body: {
        'start_date': startDate,
        'end_date': endDate,
        if (flowIntensity != null) 'flow_intensity': flowIntensity,
        if (notes != null) 'notes': notes,
        if (symptoms != null) 'symptoms': symptoms,
      },
    );
  }

  /// Update cycle entry
  static Future<ApiResponse<Map<String, dynamic>>> updateCycleEntry({
    required String cycleId,
    String? startDate,
    String? endDate,
    int? flowIntensity,
    String? notes,
    List<String>? symptoms,
  }) async {
    final body = <String, dynamic>{};
    if (startDate != null) body['start_date'] = startDate;
    if (endDate != null) body['end_date'] = endDate;
    if (flowIntensity != null) body['flow_intensity'] = flowIntensity;
    if (notes != null) body['notes'] = notes;
    if (symptoms != null) body['symptoms'] = symptoms;

    return _client.put<Map<String, dynamic>>(
      '/cycles/$cycleId',
      body: body.isNotEmpty ? body : null,
    );
  }

  /// Delete cycle entry
  static Future<ApiResponse<void>> deleteCycleEntry({
    required String cycleId,
  }) async {
    return _client.delete<void>('/cycles/$cycleId');
  }

  // ==================== SURVEY ENDPOINTS ===================

  /// Get survey questions
  static Future<ApiResponse<List<Map<String, dynamic>>>> getSurveyQuestions({
    String? category,
  }) async {
    final endpoint = category != null ? '/surveys?category=$category' : '/surveys';
    return _client.get<List<Map<String, dynamic>>>(endpoint);
  }

  /// Submit survey response
  static Future<ApiResponse<Map<String, dynamic>>> submitSurveyResponse({
    required String surveyId,
    required Map<String, dynamic> responses,
  }) async {
    return _client.post<Map<String, dynamic>>(
      '/surveys/$surveyId/responses',
      body: {
        'survey_id': surveyId,
        'responses': responses,
      },
    );
  }

  /// Save source selection
  static Future<ApiResponse<Map<String, dynamic>>> saveSourceSelection({
    required String source,
  }) async {
    return _client.post<Map<String, dynamic>>(
      '/user/source',
      body: {'source': source},
    );
  }

  // ==================== COMMUNITY ENDPOINTS ===================

  /// Get community posts
  static Future<ApiResponse<List<Map<String, dynamic>>>> getCommunityPosts({
    int? page,
    int? limit,
    String? category,
  }) async {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (category != null) queryParams['category'] = category;

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    
    return _client.get<List<Map<String, dynamic>>('/community/posts?$queryString');
  }

  /// Create community post
  static Future<ApiResponse<Map<String, dynamic>>> createCommunityPost({
    required String title,
    required String content,
    String? category,
    List<String>? tags,
  }) async {
    return _client.post<Map<String, dynamic>>(
      '/community/posts',
      body: {
        'title': title,
        'content': content,
        if (category != null) 'category': category,
        if (tags != null) 'tags': tags,
      },
    );
  }

  // ==================== NOTIFICATIONS ENDPOINTS ===================

  /// Get notifications
  static Future<ApiResponse<List<Map<String, dynamic>>>> getNotifications({
    bool? read,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (read != null) queryParams['read'] = read.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    
    return _client.get<List<Map<String, dynamic>>>('/notifications?$queryString');
  }

  /// Mark notification as read
  static Future<ApiResponse<Map<String, dynamic>>> markNotificationRead({
    required String notificationId,
  }) async {
    return _client.put<Map<String, dynamic>>(
      '/notifications/$notificationId/read',
    );
  }

  // ==================== SETTINGS ENDPOINTS ===================

  /// Get user settings
  static Future<ApiResponse<Map<String, dynamic>>> getUserSettings() async {
    return _client.get<Map<String, dynamic>>('/user/settings');
  }

  /// Update user settings
  static Future<ApiResponse<Map<String, dynamic>>> updateUserSettings({
    Map<String, dynamic>? notifications,
    Map<String, dynamic>? privacy,
    Map<String, dynamic>? preferences,
  }) async {
    final body = <String, dynamic>{};
    if (notifications != null) body['notifications'] = notifications;
    if (privacy != null) body['privacy'] = privacy;
    if (preferences != null) body['preferences'] = preferences;

    return _client.put<Map<String, dynamic>>(
      '/user/settings',
      body: body.isNotEmpty ? body : null,
    );
  }

  // ==================== UTILITY METHODS ===================

  /// Dispose API client
  static void dispose() {
    _client.dispose();
  }
}
