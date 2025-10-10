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
      Get.snackbar("Error", errorMessage ?? "Something went wrong");
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
      Get.snackbar("Error", errorMessage ?? "Something went wrong");
    } catch (e) {
      AppLogger.e("Unexpected error: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Helper to extract error message from DioError
  String? _extractErrorMessage(DioError e) {
    if (e.response?.data is Map && e.response?.data["error"] != null) {
      return e.response?.data["error"].toString();
    }
    return e.message ?? "Unknown error occurred";
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
