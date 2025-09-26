import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smis_attendance_tracker/features/home/model/user_model.dart';
import 'package:smis_attendance_tracker/services/attendance_service.dart';
import 'package:smis_attendance_tracker/utils/logger.dart';
import '../attendance/controllers/attendance_controller.dart';

class HomeController extends GetxController {
  final storage = GetStorage();
  final AttendanceService _attendanceService = AttendanceService();
  final AttendanceController _attendanceController = Get.put(
    AttendanceController(),
  );

  // Bottom navigation
  var currentIndex = 0.obs;

  // Sticky header user info
  var userName = ''.obs;
  var userRole = ''.obs;
  var userRoleType = ''.obs;
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

  // 🔹 Search & Role filtering
  var searchText = ''.obs;

  // 🔹 Static roles
  var roles = ["All", "Tower Admin", "Reporting Manager", "User"].obs;

  // Multi-selection roles
  var selectedRoles = <String>[].obs;

  // Attendance
  var isAttendanceMarked = false.obs;

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
    userRoleType.value = user["role"] ?? "Role";
    userRole.value =
        "${user["role"] ?? "Role"} • ${user["designation"] ?? "Designation"}";
    userDesignation.value = user["designation"] ?? "Designation";
    userLocation.value = user["location"] ?? "-- --";
  }

  /// 🔹 Combined Filtered reports
  List<UserModel> get filteredReports {
    Iterable<UserModel> list = directReports;

    // Apply search filter
    if (searchText.isNotEmpty) {
      final query = searchText.value.toLowerCase();
      list = list.where(
        (u) =>
            u.userName.toLowerCase().contains(query) ||
            u.role.toLowerCase().contains(query) ||
            u.designation.toLowerCase().contains(query),
      );
    }

    // Apply multi-role filter
    if (selectedRoles.isNotEmpty && !selectedRoles.contains("All")) {
      list = list.where((u) => selectedRoles.contains(u.role));
    }

    return list.toList();
  }

  /// Toggle role selection
  void toggleRoleSelection(String role) {
    if (role == "All") {
      selectedRoles.clear();
      selectedRoles.add("All");
    } else {
      selectedRoles.remove("All");
      if (selectedRoles.contains(role)) {
        selectedRoles.remove(role);
      } else {
        selectedRoles.add(role);
      }
    }
  }

  /// Update counts dynamically based on `todayOffice`
  void calculateCounts() {
    String norm(String? v) => (v ?? '').toLowerCase().trim();
    AppLogger.d(
      "Calculating counts from ${directReports.length} direct reports",
    );

    greenCenterCount.value = directReports
        .where((u) => norm(u.todayOffice).contains('green center'))
        .length;

    kanakTowerCount.value = directReports
        .where((u) => norm(u.todayOffice).contains('kanak tower'))
        .length;

    wfhCount.value = directReports.where((u) {
      final t = norm(u.todayOffice);
      return t.contains('work from home') || t.contains('wfh');
    }).length;

    leaveCount.value = directReports
        .where(
          (u) =>
              norm(u.todayOffice).contains('on leave') ||
              norm(u.todayOffice).contains('leave'),
        )
        .length;
  }

  /// Update direct reports from API response
  void setDirectReports(List<UserModel> users) {
    directReports.assignAll(users);
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
        checkMyAttendance();
        final usersJson = response.data["data"]["users"] as List;
        final users = usersJson.map((u) => UserModel.fromJson(u)).toList();

        directReports.assignAll(users);

        _resetCounts();
        for (var user in users) {
          final t = (user.todayOffice ?? '').toLowerCase().trim();
          if (t.contains('green') && t.contains('center')) {
            greenCenterCount.value++;
          } else if (t.contains('kanak') && t.contains('tower')) {
            kanakTowerCount.value++;
          } else if (t.contains('wfh') ||
              (t.contains('work') && t.contains('home'))) {
            wfhCount.value++;
          } else if (t.contains('leave') ||
              (t.contains('on') && t.contains('leave'))) {
            leaveCount.value++;
          }
        }
      } else {
        directReports.clear();
        _resetCounts();
      }
    } catch (e) {
      directReports.clear();
      _resetCounts();
    } finally {
      isLoadingReports.value = false;
    }
  }

  /// Check if user has marked attendance today
  Future<void> checkMyAttendance() async {
    try {
      await _attendanceController.fetchAttendance();
      final records = _attendanceController.attendanceList;

      final today = DateTime.now().toLocal();
      final todayStr =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      final hasToday = records.any((record) {
        final captureDate = record["captureDate"]?.toString() ?? "";
        return captureDate.startsWith(todayStr);
      });

      isAttendanceMarked.value = hasToday;
    } catch (e) {
      isAttendanceMarked.value = false;
    }
  }

  /// Helper to reset counts
  void _resetCounts() {
    greenCenterCount.value = 0;
    kanakTowerCount.value = 0;
    wfhCount.value = 0;
    leaveCount.value = 0;
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

  /// Trigger refresh after role filter
  void filterReportsByRole() => directReports.refresh();

  /// Logout
  void logout() {
    storage.erase();
    Get.offAllNamed("/login");
  }
}
