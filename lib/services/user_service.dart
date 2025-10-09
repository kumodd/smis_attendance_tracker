import 'package:dio/dio.dart';
import 'package:smis_attendance_tracker/utils/logger.dart';
import '../core/dio_client.dart';

class UserService {
  final Dio api = ApiClient().client;

  /// Create new user
  Future<Response> addUser({
    required String name,
    required String phone,
    String? psid,
    required String designation,
  }) async {
    try {
      return await api.post(
        "/user/create-user",
        data: {
          "name": name,
          "mobile": phone,
          "psid": psid,
          "designation": designation,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

    Future<Response> updateUser({
    required String name,
    required String phone,
    required String designation,
    required String psid,
  }) async {
    try {
      return await api.post(
        "/user/update-user/$psid",
        data: {
          "name": name,
          "mobile": phone,
          "designation": designation,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
