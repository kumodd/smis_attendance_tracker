import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
    final userId = userIdController.text.trim();

    if (userId.isEmpty) {
      Get.snackbar("Error", "User ID cannot be empty");
      return;
    }

    try {
      isLoading.value = true;
      final response = await _authService.sendOtp(userId);
      AppLogger.i("Send OTP Response: ${response.data}");

      if (response.statusCode == 200) {
        Get.snackbar("Success", "OTP sent successfully");
        Get.toNamed(AppRoutes.otp, arguments: {"userId": userId});
      } else {
        Get.snackbar("Error", "Failed to send OTP");
      }
    } catch (e) {
      AppLogger.i("Send OTP Error: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    final userId = Get.arguments?["userId"] ?? "";
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

        // ✅ Persist user, tokens, and settings in storage
        storage.write("isLoggedIn", true);
        storage.write("accessToken", body["data"]["tokens"]["accessToken"]);
        storage.write("refreshToken", body["data"]["tokens"]["refreshToken"]);
        storage.write("user", body["data"]["user"]);
        storage.write("settings", body["data"]["settings"]);

        AppLogger.i("User persisted: ${body["data"]["user"]}");

        // ✅ Save office locations in normalized format
        final offices = body["data"]["offices"] ?? [];
        final geoFence = body["data"]["settings"]["geoFence"] ?? 100; // fallback 100m

        final List<Map<String, dynamic>> locations = offices.map<Map<String, dynamic>>((office) {
          return {
            "name": office["officeName"],          // String
            "lat": office["gpsLat"],               // double
            "lng": office["gpsLon"],               // double
            "range": geoFence                      // int
          };
        }).toList();

        storage.write("locations", locations);  // ✅ This will be used by AttendanceController

        AppLogger.i("Office locations saved: $locations");

        Get.snackbar("Success", "OTP verified");
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.snackbar("Error", "Invalid OTP");
      }
    } catch (e) {
      AppLogger.i("Verify OTP Error: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
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