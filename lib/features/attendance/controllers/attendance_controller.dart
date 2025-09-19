import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:smis_attendance_tracker/core/location_helper.dart';
import '../../../services/attendance_service.dart';
import '../../../utils/logger.dart';

enum AttendanceType { greenCenter, kanakTower, wfh, leave, currentDate }

class AttendanceController extends GetxController {

  var status = "Not tracked yet".obs;
  var isLoading = false.obs;
  var userId="".obs;
  var canMark = false
      .obs; // ✅ controls mark button enable/disable after successful track
  final storage = GetStorage();
  final AttendanceService _attendanceService = AttendanceService();

  /// store last tracked details
  Position? lastPosition;
  String? lastOfficeName;

  /// Predefined office locations with range in meters (from storage)
  List<Map<String, dynamic>> get officeLocations {
    final data = storage.read("locations") ?? [];
    return List<Map<String, dynamic>>.from(data);
  }





  /// Track location automatically on bottom sheet open
  @override
  void onInit() {
    super.onInit();
    _autoTrackLocation();
    AppLogger.i("AttendanceController initialized user id=>$userId");
  }

  Future<void> _autoTrackLocation() async {
    if (!isLoading.value) {
      await trackLocation();
    }
  }

  Future<void> trackLocation() async {
    try {
      isLoading.value = true;
      canMark.value = false;
      status.value = "Tracking location...";

      final pos = await LocationHelper.getCurrentLocation();
      if (pos == null) {
        status.value = "Could not get location";
        return;
      }

      AppLogger.i("Current Position: lat=${pos.latitude}, lng=${pos.longitude}");

      bool matched = false;
      String? officeName;

      for (var loc in officeLocations) {
        try {
          final double lat = double.tryParse(loc["lat"].toString()) ?? 0.0;
          final double lng = double.tryParse(loc["lng"].toString()) ?? 0.0;
          const double range = 500.0;

          final distance =
          Geolocator.distanceBetween(pos.latitude, pos.longitude, lat, lng);

          if (distance <= range) {
            officeName = loc["name"].toString();
            matched = true;
            break;
          }
        } catch (e) {
          AppLogger.e("Error parsing location: $e");
        }
      }

      if (matched) {
        status.value = "Working from $officeName";
        lastOfficeName = officeName;
      } else {
        status.value = "Working from Home";
        lastOfficeName = "WORK FROM HOME";
      }

      lastPosition = pos;
      canMark.value = true;
    } catch (e) {
      status.value = "Error: $e";
      AppLogger.e("trackLocation failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markTodayAttendance() async {
    if (lastPosition == null) {
      status.value = "Please track location first!";
      return;
    }

    try {
      isLoading.value = true;
      canMark.value = false;
      status.value = "Marking attendance...";

      final response = await _attendanceService.markAttendance(
        latitude: lastPosition!.latitude,
        longitude: lastPosition!.longitude,
        officeName: lastOfficeName,
      );

      if (response.statusCode == 200) {
        status.value = "✅ Attendance marked successfully";
      } else {
        status.value = "❌ Failed to mark attendance: ${response.statusMessage}";
      }
    } catch (e, st) {
      status.value = "Error: $e";
      AppLogger.e("markTodayAttendance failed", e, st);
    } finally {
      isLoading.value = false;
      canMark.value = false;
    }
  }


  /// Attendance history
  var attendanceList = <dynamic>[].obs;
  var errorMessage = "".obs;

  Future<void> fetchAttendance() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final response = await _attendanceService.getAttendance();
      AppLogger.i("My Attendance List Response: ${response.data}");

      if (response.statusCode == 200 && response.data["status"] == 200) {
        attendanceList.value = response.data["data"] ?? [];
      } else {
        errorMessage.value =
            response.data["message"] ?? "Failed to load data";
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Calendar mapping
  var attendanceMap = <DateTime, AttendanceType>{}.obs;

  Map<String, AttendanceType> officeNameMap = {
    "ITC GREEN CENTER": AttendanceType.greenCenter,
    "KANAK TOWER": AttendanceType.kanakTower,
    "WORK FROM HOME": AttendanceType.wfh,
    "ON LEAVE": AttendanceType.leave,
  };

  Future<void> fetchUserAttendance(String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final response = await _attendanceService.getUserAttendance(userId);

      if (response.statusCode == 200 && response.data["status"] == 200) {
        final List data = response.data["data"]["attendance"] ?? [];
        Map<DateTime, AttendanceType> mapped = {};
        for (var item in data) {
          final rawDate = item["captureDate"];
          final officeName =
          (item["officeName"] ?? "").toString().toUpperCase();

          final date = DateFormat("yyyy-MM-dd HH:mm:ss.S").parse(rawDate);
          final key = DateTime(date.year, date.month, date.day);

          if (officeNameMap.containsKey(officeName)) {
            mapped[key] = officeNameMap[officeName]!;
          }
        }

        final today = DateTime.now();
        final currentDate = DateTime(today.year, today.month, today.day);
        mapped[currentDate] = AttendanceType.currentDate;

        attendanceMap.value = mapped;
      } else {
        errorMessage.value =
            response.data["message"] ?? "Failed to load attendance data";
      }
    } catch (e) {
      errorMessage.value = "Error: $e";
    } finally {
      isLoading.value = false;
    }
  }



}
