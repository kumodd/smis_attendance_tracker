import 'package:dio/dio.dart';
import '../core/dio_client.dart';

class AuthService {
final api = ApiClient().client;

// Example


  Future<Response> sendOtp(String userId) async {
    return await api.post("/auth/send-otp", data: {"userId": userId});
  }

  Future<Response> verifyOtp(String userId, String otp) async {
    return await api.post("/auth/verify-otp", data: {
      "userId": userId,
      "otp": otp,
    });
  }


}