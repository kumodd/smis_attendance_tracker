import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'constants.dart';

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  )..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final storage = GetStorage();
        final token = storage.read(AppConstants.storageToken);
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
      onError: (DioError e, handler) {
        print("API Error: ${e.message}");
        return handler.next(e);
      },
    ));
}