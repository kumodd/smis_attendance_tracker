import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:smis_attendance_tracker/routes/app_routes.dart';
import 'package:smis_attendance_tracker/services/auth_service.dart';
import 'package:smis_attendance_tracker/utils/logger.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();
  final storage = GetStorage();

  final TextEditingController userIdController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  var isLoading = false.obs;

  Future<void> sendOtp() async {
    String userId = userIdController.text.trim();

    if (userId.isEmpty) {
      Get.snackbar("Error", "ADID cannot be empty");
      return;
    }
    if (userId.length < 3) {
      Get.snackbar(
        "Error",
        "ADID must be at least 3 characters long",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFB00020),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _authService.sendOtp(userId);
      AppLogger.i("Send OTP Response: ${response.data}");
      if (response.statusCode == 200) {
        Get.snackbar("Success", "OTP sent successfully");
        Get.toNamed(AppRoutes.otp, arguments: {"userId": userId});
      }
    } on DioError catch (e) {
      final errorMessage = _extractErrorMessage(e);
      AppLogger.e("Send OTP Error: $errorMessage");
      //Get.snackbar("Error", errorMessage ?? "Something went wrong");
    } catch (e) {
      AppLogger.e("Unexpected error: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    String userId = (Get.arguments?["userId"] ?? "");
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      Get.snackbar("Error", "OTP cannot be empty");
      return;
    }

    try {
      isLoading.value = true;

      final response = await _authService.verifyOtp(userId, otp);
      AppLogger.i("Verify OTP Response: ${response.data}");

      if (response.statusCode == 200) {
        final body = response.data;

        storage.write("isLoggedIn", true);
        storage.write("accessToken", body["data"]["tokens"]["accessToken"]);
        storage.write("refreshToken", body["data"]["tokens"]["refreshToken"]);
        storage.write("user", body["data"]["user"]);
        storage.write("settings", body["data"]["settings"]);
        final designations = (body["data"]["designations"] as List<dynamic>)
            .map((e) => e["designation"])
            .toList();

        storage.write("designations", designations);

        final offices = body["data"]["offices"] ?? [];
        final geoFence = body["data"]["settings"]["geoFence"] ?? 100;

        final List<Map<String, dynamic>> locations = offices
            .map<Map<String, dynamic>>((office) {
              return {
                "name": office["officeName"],
                "lat": office["gpsLat"],
                "lng": office["gpsLon"],
                "range": geoFence,
              };
            })
            .toList();

        storage.write("locations", locations);

        Get.snackbar("Success", "OTP verified");
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.snackbar("Error", "Invalid OTP");
      }
    } on DioError catch (e) {
      final errorMessage = _extractErrorMessage(e);
      AppLogger.e("Verify OTP DioError: $errorMessage");
      //Get.snackbar("Error", errorMessage ?? "Something went wrong");
    } catch (e) {
      AppLogger.e("Unexpected error: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Helper to extract error message from DioError
  String? _extractErrorMessage(DioError e) {
    try {
      final data = e.response?.data;

      if (data is Map) {
        if (data.containsKey('error')) return data['error'].toString();
        if (data.containsKey('message')) return data['message'].toString();
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          if (errors is Map) {
            final firstKey = errors.keys.first;
            final firstError = errors[firstKey];
            if (firstError is List && firstError.isNotEmpty) {
              return firstError.first.toString();
            } else if (firstError is String) {
              return firstError;
            }
          }
        }
      }

      return e.message ?? "Unknown error occurred";
    } catch (err) {
      return "Failed to parse error";
    }
  }

  /// ✅ Check if user is logged in (for splash/initial route)
  bool get isLoggedIn => storage.read("isLoggedIn") ?? false;

  /// ✅ Logout function
  void logout() {
    storage.erase();
    AppLogger.i("User logged out");
    Get.offAllNamed(AppRoutes.login);
  }
}
