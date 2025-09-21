import 'package:dio/dio.dart';
import 'package:smis_attendance_tracker/core/dio_client.dart'; // your ApiClient wrapper
import 'package:get_storage/get_storage.dart';
import '../utils/logger.dart';

class AttendanceService {
  final Dio _client = ApiClient().client;

  /// Get list of direct reports (users under manager)
  Future<Response> getUserList() async {
    try {
      final response = await _client.get("/user/user-list");
      return response;
    } catch (e, st) {
      AppLogger.e("❌ getUserList failed", e, st);
      rethrow;
    }
  }

  /// ✅ Get user attendance history with Authorization header
  Future<Response> getAttendance() async {
    return await _client.get("/attendance/my-attendance");
  }

  /// Mark attendance
  Future<Response> markAttendance({
    // Present / Absent / WFH etc.
    required double latitude,
    required double longitude,
    String? officeName, // optional → when matched with office
  }) async {
    try {
      final requestBody = {
        "gpsLat": latitude,
        "gpsLng": longitude,
        if (officeName != null)
          "officeName": officeName, // ✅ add only if matched
      };

      AppLogger.i("📤 markAttendance Request: $requestBody");

      final response = await _client.post(
        "/attendance/mark-attendance",
        data: requestBody,
      );

      AppLogger.i("✅ markAttendance Response: ${response.data}");
      return response;
    } catch (e, st) {
      AppLogger.e("❌ markAttendance failed", e, st);
      rethrow;
    }
  }

  /// Fetch full attendance history of a user
  Future<Response> getUserAttendance(String userId) async {
    try {
      final response = await _client.get("/attendance/user-attendance/$userId");
      return response;
    } catch (e, st) {
      AppLogger.e("❌ getUserAttendance failed", e, st);
      rethrow;
    }
  }
}
