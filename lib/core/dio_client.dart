import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smis_attendance_tracker/routes/app_routes.dart';
import 'package:smis_attendance_tracker/utils/logger.dart';
import 'constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  final Dio _dio = Dio();
  final storage = GetStorage();

  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  ApiClient._internal() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      validateStatus: (status) {
        // ✅ Allow 200-499 into onResponse (so 401 handled here, not as exception)
        return status != null && status < 300;
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = storage.read("accessToken");
          AppLogger.d("Stored Token: $token");
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          AppLogger.d("➡️ [REQUEST] ${options.method} ${options.uri}");
          AppLogger.d("Headers: ${options.headers}");
          AppLogger.d("Data: ${options.data}");

          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.i(
            "✅ [RESPONSE] ${response.statusCode} ${response.requestOptions.uri}",
          );
          AppLogger.d("Response Data: ${response.data}");
          return handler.next(response);
        },
        onError: (DioError error, handler) async {
          final status = error.response?.statusCode;
          AppLogger.e("❌ [ERROR] $status ${error.message}");
          if (error.response != null) {
            AppLogger.e("Error Data: ${error.response?.data}");
          }

          // 🚨 Skip refresh if this is the refresh request itself
          if (error.requestOptions.path.contains("/auth/refresh-token")) {
            AppLogger.e("⚠️ Refresh token request failed. Logging out...");
            _logoutUser();
            return handler.next(error);
          }

          // 🚨 Handle expired token
          if (status == 401 || status == 403) {
            if (!_isRefreshing) {
              _isRefreshing = true;
              _refreshCompleter = Completer();

              final refreshed = await _refreshToken();

              _isRefreshing = false;
              _refreshCompleter?.complete();

              if (refreshed) {
                final newToken = storage.read("accessToken");
                error.requestOptions.headers["Authorization"] =
                    "Bearer $newToken";

                AppLogger.i("🔁 Retrying request with new token...");
                final cloneReq = await _dio.fetch(error.requestOptions);
                return handler.resolve(cloneReq);
              } else {
                AppLogger.e("🚪 Refresh failed. Logging out...");
                _logoutUser();
              }
            } else {
              // If refresh already happening → wait
              AppLogger.d("⏳ Waiting for ongoing refresh...");
              await _refreshCompleter?.future;

              final newToken = storage.read("accessToken");
              error.requestOptions.headers["Authorization"] =
                  "Bearer $newToken";
              final cloneReq = await _dio.fetch(error.requestOptions);
              return handler.resolve(cloneReq);
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  Dio get client => _dio;

  /// 🔄 Refresh token logic
  Future<bool> _refreshToken() async {
    final refreshToken = storage.read("refreshToken");
    if (refreshToken == null) {
      AppLogger.e("⚠️ No refresh token available");
      return false;
    }

    try {
      AppLogger.i("🔄 Calling refresh token API...");
      final response = await _dio.post(
        "/auth/refresh-token",
        data: {"refreshToken": refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data["data"];
        storage.write("accessToken", data["accessToken"]);
        storage.write("refreshToken", data["refreshToken"]);

        AppLogger.i("🔑 Token refreshed successfully");
        return true;
      } else {
        AppLogger.e("⚠️ Refresh failed: ${response.data}");
      }
    } catch (e, st) {
      AppLogger.e("❌ Refresh token exception", e, st);
    }
    return false;
  }

  /// 🚪 Logout user & clear storage
  void _logoutUser() {
    storage.erase();
    Get.offAllNamed(AppRoutes.login);
    AppLogger.i("👋 User logged out, storage cleared.");
  }
}
