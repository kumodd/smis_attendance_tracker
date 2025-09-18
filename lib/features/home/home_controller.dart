import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smis_attendance_tracker/features/home/model/user_model.dart';
import 'package:smis_attendance_tracker/services/attendance_service.dart';
 // model for user

class HomeController extends GetxController {
  final storage = GetStorage();
  final AttendanceService _attendanceService = AttendanceService();

  // Bottom navigation
  var currentIndex = 0.obs;

  // Sticky header user info
  var userName = ''.obs;
  var userRole = ''.obs;
  var userDesignation = ''.obs;
  var userLocation = ''.obs;

  // Dynamic greeting
  var greeting = ''.obs;

  // Direct reports
  var directReports = <UserModel>[].obs;
  var isLoadingReports = false.obs;


   // Status counts
  var greenCenterCount = 0.obs;
  var kanakTowerCount = 0.obs;
  var wfhCount = 0.obs;
  var leaveCount = 0.obs;
  /// Update counts dynamically based on `todayOffice`
  void calculateCounts() {
    greenCenterCount.value =
        directReports.where((u) => u.todayOffice == "Green Center").length;

    kanakTowerCount.value =
        directReports.where((u) => u.todayOffice == "Kanak Tower").length;

    wfhCount.value =
        directReports.where((u) => u.todayOffice == "Work From Home").length;

    leaveCount.value =
        directReports.where((u) => u.todayOffice == "On Leave").length;
  }

  /// Update direct reports from API response
  void setDirectReports(List<UserModel> users) {
    directReports.assignAll(users);
    calculateCounts();
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _updateGreeting();
    fetchDirectReports();
  }

  /// Load user info from storage
  void _loadUserData() {
    final user = storage.read("user") ?? {};
    userName.value = user["name"] ?? "User Name";
    userRole.value =
        "${user["role"] ?? "Role"} • ${user["designation"] ?? "Designation"}";
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

  /// Fetch direct reports from API
  Future<void> fetchDirectReports() async {
    try {
      isLoadingReports.value = true;
      final response = await _attendanceService.getUserList();

      if (response.statusCode == 200) {
        final usersJson = response.data["data"]["users"] as List;
        directReports.value =
            usersJson.map((u) => UserModel.fromJson(u)).toList();
      } else {
        directReports.clear();
      }
    } catch (e) {
      directReports.clear();
    } finally {
      isLoadingReports.value = false;
    }
  }

  /// Refresh user data dynamically
  void refreshUserData() {
    _loadUserData();
    fetchDirectReports();
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