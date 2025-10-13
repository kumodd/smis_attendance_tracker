import 'package:flutter/material.dart';
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
  final TextEditingController searchTextController = TextEditingController();


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

  // Search & Role filtering
  var searchText = ''.obs;

  // Static roles
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

  /// Load user info from local storage
  void _loadUserData() {
    final user = storage.read("user") ?? {};
    userName.value = user["name"] ?? "User Name";
    userRoleType.value = user["role"] ?? "Role";
    userRole.value =
        "${user["role"] ?? "Role"} • ${user["designation"] ?? "Designation"}";
    userDesignation.value = user["designation"] ?? "Designation";
    userLocation.value = user["location"] ?? "-- --";
  }

  /// Filtered direct reports based on search and role
  List<UserModel> get filteredReports {
    Iterable<UserModel> list = directReports;

    if (searchText.isNotEmpty) {
      final query = searchText.value.toLowerCase();
      list = list.where(
        (u) =>
            u.userName.toLowerCase().contains(query) ||
            u.role.toLowerCase().contains(query) ||
            u.designation.toLowerCase().contains(query),
      );
    }

    if (selectedRoles.isNotEmpty && !selectedRoles.contains("All")) {
      list = list.where((u) => selectedRoles.contains(u.role));
    }

    return list.toList();
  }

  /// Toggle role filtering
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

  /// ✅ Corrected logic: treat null/empty todayOffice as leave
  void calculateCounts() {
    AppLogger.d(
      "Calculating counts from ${directReports.length} direct reports",
    );
    _resetCounts();

    for (var u in directReports) {
      final office = (u.todayOffice ?? '').toLowerCase().trim();

      if (office.isEmpty) {
        leaveCount.value++;
      } else if (office.contains('green') && office.contains('center')) {
        greenCenterCount.value++;
      } else if (office.contains('kanak') && office.contains('tower')) {
        kanakTowerCount.value++;
      } else if (office.contains('wfh') ||
          (office.contains('work') && office.contains('home'))) {
        wfhCount.value++;
      } else if (office.contains('leave') || office.contains('on leave')) {
        leaveCount.value++;
      } else {
        // Fallback → treat unmatched text as leave
        leaveCount.value++;
      }
    }

    AppLogger.d(
      "Counts → Green: ${greenCenterCount.value}, Kanak: ${kanakTowerCount.value}, WFH: ${wfhCount.value}, Leave: ${leaveCount.value}",
    );
  }

  /// Set direct reports from API
  void setDirectReports(List<UserModel> users) {
    directReports.assignAll(users);
  }

  /// Greeting based on IST
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

  /// Fetch user list
  Future<void> fetchDirectReports() async {
    try {
      isLoadingReports.value = true;
      final response = await _attendanceService.getUserList();

      if (response.statusCode == 200) {
        checkMyAttendance();

        final usersJson = response.data["data"]["users"] as List;
        final users = usersJson.map((u) => UserModel.fromJson(u)).toList();

        directReports.assignAll(users);
        calculateCounts();
      } else {
        directReports.clear();
        _resetCounts();
      }
    } catch (e) {
      AppLogger.e("Error fetching direct reports", e);
      directReports.clear();
      _resetCounts();
    } finally {
      isLoadingReports.value = false;
    }
  }

  /// Check own attendance
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

  void _resetCounts() {
    greenCenterCount.value = 0;
    kanakTowerCount.value = 0;
    wfhCount.value = 0;
    leaveCount.value = 0;
  }

  void refreshUserData() {
    _loadUserData();
    fetchDirectReports();
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void filterReportsByRole() => directReports.refresh();

  void logout() {
    storage.erase();
    Get.offAllNamed("/login");
  }
}
