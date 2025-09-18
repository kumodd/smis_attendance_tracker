import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../core/dio_client.dart';
import '../utils/logger.dart';

class AttendanceService {
  final Dio _dio = DioClient.dio;
  final storage = GetStorage();

  /// ✅ Get user attendance history with Authorization header
  Future<Response> getAttendance() async {
    final token = storage.read("accessToken");
    AppLogger.i("Access Token: ${token}");


    return await _dio.get(
      "/attendance/my-attendance",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );
  }
}
