import 'dart:developer';

import 'package:autographa_survey/utils/endpoints.dart';
import 'package:dio/dio.dart';
import '../config/environment_config.dart';
import 'api_response.dart';
import 'token_manager.dart';

class ApiHelper {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: EnvironmentConfig.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  static final Dio _dio2 = Dio(BaseOptions(
    // baseUrl: 'https://api.staging.autographa.io', 
    baseUrl: EnvironmentConfig.baseUrl2,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  static String get baseUrl => _dio.options.baseUrl;
  static String get baseUrl2 => _dio2.options.baseUrl;

  static void initializeInterceptors() {
    // Add logging interceptor in development mode
    if (EnvironmentConfig.enableLogging) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
      _dio2.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }

    _dio2.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add access token to request if available
          final accessToken = await TokenManager.getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
            if (EnvironmentConfig.enableLogging) {
              log('Token : $accessToken', name: 'API');
            }
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          // Handle 401 Unauthorized errors (token expired)
          if (e.response?.statusCode == 401) {
            final isTokenRefreshed = await _refreshToken();
            if (isTokenRefreshed) {
              // Retry the original request with new token
              return handler.resolve(await _retryRequest(e.requestOptions));
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Refresh token and return true if successful
  static Future<bool> _refreshToken() async {
    try {
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken == null) return false;

      final url = apiRefresh.startsWith('/') ? apiRefresh : '/$apiRefresh';
      final response = await _dio2.post(
        url,
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Authorization': null},
        ), // Don't send old token
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        await TokenManager.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        log('Token refreshed successfully', name: 'API');
        return true;
      }
      return false;
    } catch (e) {
      log('Token refresh failed: $e', name: 'API');
      return false;
    }
  }

  // Retry a failed request with new token
  static Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final accessToken = await TokenManager.getAccessToken();
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    options.headers!['Authorization'] = 'Bearer $accessToken';

    return _dio2.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  static Future<ApiResponse<T>> get<T>(String endpoint) async {
    final url = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    log('GET ${baseUrl + url}', name: 'APIS');
    try {
      final response = await _dio.get(url);
      // log('response: ${response}', name: 'SUCCESS');

      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      log('GET ${baseUrl + url} error: ${e}', name: 'ERROR');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }

  static Future<ApiResponse<T>> post<T>(String endpoint, dynamic data,
      {bool useStaging = false}) async {
    final url = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    log('POST ${useStaging ? baseUrl2 + url : baseUrl + url}', name: 'API');
    try {
      final response = await (useStaging ? _dio2 : _dio).post(url, data: data);

      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }

  static Future<ApiResponse<T>> put<T>(String endpoint, dynamic data) async {
    final url = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    log('PUT ${baseUrl + url}', name: 'API');
    try {
      final response = await _dio.put(url, data: data);

      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }

  static Future<ApiResponse<T>> delete<T>(String endpoint) async {
    final url = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    log('DELETE ${baseUrl + url}', name: 'API');
    try {
      final response = await _dio.delete(url);

      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }

  static String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? 'Server error occurred';
        return 'Error $statusCode: $message';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      default:
        return 'Network error occurred';
    }
  }
}
