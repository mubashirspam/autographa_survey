import 'dart:convert';
import 'package:autographa_survey/model/login_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id';
  static const String _userDataKey = 'user_data';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    int? userId,
  }) async {
    // Calculate expiry time (58 minutes from now)
    final expiryTime = DateTime.now()
        .add(const Duration(minutes: 58))
        .millisecondsSinceEpoch
        .toString();

    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _tokenExpiryKey, value: expiryTime);
    if (userId != null) {
      await _storage.write(key: _userIdKey, value: userId.toString());
    }
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // Get user id
  static Future<int?> getUserId() async {
    final userIdStr = await _storage.read(key: _userIdKey);
    return userIdStr != null ? int.parse(userIdStr) : null;
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Check if access token is expired
  static Future<bool> isAccessTokenExpired() async {
    final expiryTimeStr = await _storage.read(key: _tokenExpiryKey);
    if (expiryTimeStr == null) return true;

    final expiryTime = int.parse(expiryTimeStr);
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    return currentTime >= expiryTime;
  }

  // Clear all tokens (for logout)
  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenExpiryKey);
    await _storage.delete(key: _userIdKey);
  }

  static Future<void> saveUser({
    required LoginModel user,
  }) async {
    // Convert user object to JSON string
    final userJson = jsonEncode({
      'accessToken': user.accessToken,
      'refreshToken': user.refreshToken,
      'name': user.name,
      'email': user.email,
      'personId': user.personId,
    });
    
    // Save user data to secure storage
    await _storage.write(key: _userDataKey, value: userJson);
  }
  
  // Get user data
  static Future<LoginModel> getUser() async {
    final userJson = await _storage.read(key: _userDataKey);
    
    if (userJson == null || userJson.isEmpty) {
      // Return empty user if no data found
      return LoginModel();
    }
    
    try {
      final Map<String, dynamic> userData = jsonDecode(userJson);
      return LoginModel(
        accessToken: userData['accessToken'],
        refreshToken: userData['refreshToken'],
        name: userData['name'],
        email: userData['email'],
        personId: userData['personId'],
      );
    } catch (e) {
      // Return empty user if parsing fails
      return LoginModel();
    }
  }
}
