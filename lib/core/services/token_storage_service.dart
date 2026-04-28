import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing authentication token storage
class TokenStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _loginFlagKey = 'is_logged_in_flag';
  static TokenStorageService? _instance;
  static TokenStorageService get instance =>
      _instance ??= TokenStorageService._();

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

  /// Save login session flag (for persistent login)
  Future<void> saveLoginSession(bool isLoggedIn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_loginFlagKey, isLoggedIn);
      print('✅ Login session flag saved: $isLoggedIn');
    } catch (e) {
      print('❌ Error saving login session: $e');
    }
  }

  /// Get login session flag
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_loginFlagKey) ?? false;
      print('🔍 Login session status: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      print('❌ Error checking login session: $e');
      return false;
    }
  }

  /// Check if user has valid login session (token + flag)
  Future<bool> hasValidLoginSession() async {
    try {
      final token = await getToken();
      final isUserLoggedInFlag = await isLoggedIn();

      bool hasValidSession =
          (token != null && token.isNotEmpty) && isUserLoggedInFlag;
      print('🔍 Valid login session check: $hasValidSession');
      print('   - Token exists: ${token != null}');
      print('   - Login flag: $isUserLoggedInFlag');

      return hasValidSession;
    } catch (e) {
      print('❌ Error checking valid login session: $e');
      return false;
    }
  }

  /// Complete logout (clear both token and login flag)
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_loginFlagKey);
      print('🗑️ Complete logout successful - Token and login flag cleared');
    } catch (e) {
      print('❌ Error during logout: $e');
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
