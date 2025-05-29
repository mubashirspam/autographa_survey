import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/model.dart';
import '../repository/auth_repository.dart';
import '../utils/api_response.dart';
import '../utils/token_manager.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  ApiResponse<LoginModel> _loginResponse = ApiResponse.idle();
  ApiResponse<RefreshModel> _refreshResponse = ApiResponse.idle();
  ApiResponse<LoginModel> _userResponse = ApiResponse.idle();
  bool _isAuthenticated = false;

  ApiResponse<LoginModel> get loginResponse => _loginResponse;
  ApiResponse<RefreshModel> get refreshResponse => _refreshResponse;
  ApiResponse<LoginModel> get userResponse => _userResponse;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize auth state by checking if tokens exist
  Future<void> initAuthState() async {
    debugPrint('Initializing auth state...');
    final accessToken = await TokenManager.getAccessToken();
    final isExpired = await TokenManager.isAccessTokenExpired();
    final userId = await TokenManager.getUserId();

    debugPrint('Access token exists: ${accessToken != null}');
    debugPrint('Token expired: $isExpired');
    debugPrint('User ID exists: ${userId != null}');

    if (accessToken != null && !isExpired && userId != null) {
      _isAuthenticated = true;
      debugPrint('Valid token found, user is authenticated');
      log('Access token : $accessToken', name: 'AccessToken');
      notifyListeners();
    } else if (accessToken != null && isExpired) {
      // Token expired, try to refresh
      debugPrint('Token expired, attempting to refresh');
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken != null) {
        await refresh(refreshToken);
      } else {
        debugPrint('No refresh token found, user needs to login');
        _isAuthenticated = false;
        await TokenManager.clearTokens();
        notifyListeners();
      }
    } else {
      debugPrint('No valid token found, user is not authenticated');
      _isAuthenticated = false;
      await TokenManager.clearTokens();
      notifyListeners();
    }
  }

  Future<void> login(String email, String password, {BuildContext? context}) async {
    _loginResponse = ApiResponse.loading();
    notifyListeners();

    try {
      final result = await _authRepository.login(email, password);
      _loginResponse = result;

      if (result.isSuccess && result.data != null) {
        _isAuthenticated = true;
        // Save user data
        await _authRepository.saveUser(result.data!);
        
        // Navigate to home screen if context is provided
        if (context != null && context.mounted) {
          context.go('/home');
        }
      }

      notifyListeners();
    } catch (e) {
      _loginResponse = ApiResponse.error(e.toString());
      notifyListeners();
    }
  }

  Future<void> refresh(String refreshToken) async {
    _refreshResponse = ApiResponse.loading();
    notifyListeners();
    
    debugPrint('Attempting to refresh token');

    try {
      // Add a timeout to prevent the app from getting stuck
      final result = await _authRepository.refresh(refreshToken)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        debugPrint('Token refresh timed out after 10 seconds');
        return ApiResponse.error('Token refresh timed out');
      });
      
      _refreshResponse = result;

      if (result.isSuccess && result.data != null) {
        _isAuthenticated = true;
        debugPrint('Token refresh successful');
      } else {
        // If refresh fails, user needs to login again
        _isAuthenticated = false;
        debugPrint('Token refresh failed: ${result.error ?? 'Unknown error'}');
        await TokenManager.clearTokens();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Token refresh error: ${e.toString()}');
      _refreshResponse = ApiResponse.error(e.toString());
      _isAuthenticated = false;
      await TokenManager.clearTokens();
      notifyListeners();
    }
  }

  // Logout user and clear tokens
  Future<void> logout() async {
    await TokenManager.clearTokens();
    _isAuthenticated = false;
    _loginResponse = ApiResponse.idle();
    _refreshResponse = ApiResponse.idle();
    _userResponse = ApiResponse.idle();
    notifyListeners();
  }
  
  // Get user data
  Future<void> getUserData() async {
    _userResponse = ApiResponse.loading();
    notifyListeners();
    
    try {
      final result = await _authRepository.getUser();
      _userResponse = result;
      notifyListeners();
    } catch (e) {
      _userResponse = ApiResponse.error(e.toString());
      notifyListeners();
    }
  }
  
  // Show logout toast notification
  void showLogoutToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You have been logged out successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Check if token is expired and refresh if needed
  Future<bool> ensureValidToken() async {
    final isExpired = await TokenManager.isAccessTokenExpired();

    if (isExpired) {
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken != null) {
        await refresh(refreshToken);
        return _isAuthenticated;
      }
      return false;
    }

    return true;
  }
}
