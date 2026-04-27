import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing authentication token storage
class TokenStorageService {
  static const String _tokenKey = 'auth_token';
  static TokenStorageService? _instance;
  static TokenStorageService get instance => _instance ??= TokenStorageService._();
  
  TokenStorageService._();

  /// Save authentication token
  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      print('✅ Token saved successfully');
    } catch (e) {
      print('❌ Error saving token: $e');
    }
  }

  /// Get authentication token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      print('🔑 Token retrieved: ${token != null ? 'Found' : 'Not found'}');
      return token;
    } catch (e) {
      print('❌ Error retrieving token: $e');
      return null;
    }
  }

  /// Remove authentication token (logout)
  Future<void> removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      print('🗑️ Token removed successfully');
    } catch (e) {
      print('❌ Error removing token: $e');
    }
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_tokenKey);
    } catch (e) {
      print('❌ Error checking token: $e');
      return false;
    }
  }

  /// Clear all stored data (for complete logout)
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('🗑️ All stored data cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }
}
