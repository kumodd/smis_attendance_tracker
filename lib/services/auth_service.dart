import 'package:dio/dio.dart';
import '../core/dio_client.dart';

class AuthService {
  final Dio _dio = DioClient.dio;

  Future<Response> sendOtp(String userId) async {
    return await _dio.post("/auth/send-otp", data: {"userId": userId});
  }

  Future<Response> verifyOtp(String userId, String otp) async {
    return await _dio.post("/auth/verify-otp", data: {
      "userId": userId,
      "otp": otp,
    });
  }


}