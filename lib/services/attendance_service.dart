import 'package:dio/dio.dart';
import 'package:smis_attendance_tracker/core/dio_client.dart';
// your ApiClient wrapper
import 'package:get_storage/get_storage.dart';
import '../core/dio_client.dart';
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

  /// Example: Fetch today’s attendance of a user
  Future<Response> getTodayAttendance(String userId) async {
    try {
      final response = await _client.get(
        "/attendance/today",
        queryParameters: {"userId": userId},
      );
      return response;
    } catch (e, st) {
      AppLogger.e("❌ getTodayAttendance failed", e, st);
      rethrow;
    }
  }

  /// Example: Mark attendance
  Future<Response> markAttendance({
    required String userId,
    required String status, // Present / Absent / WFH etc.
  }) async {
    try {
      final response = await _client.post(
        "/attendance/mark",
        data: {
          "userId": userId,
          "status": status,
  Future<Response> getUserAttendance(String userId) async {
    final token = storage.read("accessToken");
    AppLogger.i("Access Token: ${token}");


    return await _dio.get(
      "/attendance/user-attendance/$userId",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      return response;
    } catch (e, st) {
      AppLogger.e("❌ markAttendance failed", e, st);
      rethrow;
    }
      ),
    );
  }
}
