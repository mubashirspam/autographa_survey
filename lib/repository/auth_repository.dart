import 'package:autographa_survey/utils/endpoints.dart';
import '../model/model.dart';
import '../utils/api_helper.dart';
import '../utils/api_response.dart';
import '../utils/token_manager.dart';

class AuthRepository {
  Future<ApiResponse<LoginModel>> login(String email, String password) async {
    try {
      final response = await ApiHelper.post<Map<String, dynamic>>(
          apiLogin,
          {
            'email': email,
            'password': password,
          },
          useStaging: true);

      if (response.isSuccess && response.data != null) {
        final loginModel = LoginModel.fromJson(response.data!);

        if (loginModel.accessToken != null && loginModel.refreshToken != null) {
          await TokenManager.saveTokens(
            accessToken: loginModel.accessToken!,
            refreshToken: loginModel.refreshToken!,
            userId: loginModel.personId ??1,
          );
        }
        
        return ApiResponse.success(loginModel);
      } else {
        return ApiResponse.error(response.error ?? 'Login failed');
      }
    } catch (e) {
      return ApiResponse.error('Login failed: ${e.toString()}');
    }
  }

  Future<ApiResponse<LoginModel>> saveUser(LoginModel user) async {
    try {
      await TokenManager.saveUser(user: user);
      return ApiResponse.success(user);
    } catch (e) {
      return ApiResponse.error('Failed to save user: ${e.toString()}');
    }
  }

  Future<ApiResponse<LoginModel>> getUser() async {
    try {
      final user = await TokenManager.getUser();
      return ApiResponse.success(user);
    } catch (e) {
      return ApiResponse.error('Failed to get user: ${e.toString()}');
    }
  }

  Future<ApiResponse<RefreshModel>> refresh(String refreshToken) async {
    try {
      final response = await ApiHelper.post<Map<String, dynamic>>(
          apiRefresh,
          {
            'refreshToken': refreshToken,
          },
          useStaging: true);

      if (response.isSuccess && response.data != null) {
        final refreshModel = RefreshModel.fromJson(response.data!);

        // Save new tokens to secure storage
        await TokenManager.saveTokens(
          accessToken: refreshModel.accessToken,
          refreshToken: refreshModel.refreshToken,
        );

        return ApiResponse.success(refreshModel);
      } else {
        return ApiResponse.error(response.error ?? 'Token refresh failed');
      }
    } catch (e) {
      return ApiResponse.error('Token refresh failed: ${e.toString()}');
    }
  }
}
