import 'package:get/get.dart';

import '../dio_client.dart';
import '../storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Register singletons for app-wide use
    Get.lazyPut<StorageService>(() => StorageService(), fenix: true);
    Get.put(DioClient.dio, permanent: true);
  }
}