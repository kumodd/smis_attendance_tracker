import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  final storage = GetStorage();

  // Bottom navigation
  var currentIndex = 0.obs;

  // Sticky header user info
  var userName = ''.obs;
  var userRole = ''.obs;
  var userDesignation = ''.obs;
  var userLocation = ''.obs;

  // Dynamic greeting
  var greeting = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _updateGreeting();
  }

  /// Load user info from storage
  void _loadUserData() {
    final user = storage.read("user") ?? {};
    userName.value = user["name"] ?? "User Name";
    userRole.value = "${user["role"] ?? "Role"} • ${user["designation"] ?? "Designation"}";
    userDesignation.value = user["designation"] ?? "Designation";
    userLocation.value = user["location"] ?? "-- --";
  }

  /// Update greeting based on IST time
  void _updateGreeting() {
    final nowUtc = DateTime.now().toUtc();
    final istOffset = const Duration(hours: 5, minutes: 30);
    final nowIst = nowUtc.add(istOffset);

    final hour = nowIst.hour;

    if (hour >= 5 && hour < 12) {
      greeting.value = "Good morning";
    } else if (hour >= 12 && hour < 17) {
      greeting.value = "Good afternoon";
    } else if (hour >= 17 && hour < 21) {
      greeting.value = "Good evening";
    } else {
      greeting.value = "Good night";
    }
  }

  /// Refresh user data dynamically
  void refreshUserData() {
    _loadUserData();
  }

  /// Change bottom navigation tab
  void changeTab(int index) {
    currentIndex.value = index;
  }

  /// Logout
  void logout() {
    storage.erase();
    Get.offAllNamed("/login"); // or AppRoutes.login
  }
}