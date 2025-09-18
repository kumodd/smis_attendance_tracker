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
  var isLoading = false.obs; // ✅ added
  final storage = GetStorage();
  final AttendanceService _attendanceService = AttendanceService();

  /// Predefined office locations with range in meters (from storage)
  List<Map<String, dynamic>> get officeLocations {
    final data = storage.read("locations") ?? [];
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> trackLocation() async {
    try {
      isLoading.value = true; // ✅ start loading
      status.value = "Tracking location...";

      final pos = await LocationHelper.getCurrentLocation();

      if (pos == null) {
        status.value = "Could not get location";
        return;
      }

      bool matched = false;
      for (var loc in officeLocations) {
        final distance = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          loc["lat"],
          loc["lng"],
        );

        if (distance <= loc["range"]) {
          status.value = "Working from ${loc["name"]}";
          matched = true;
          break;
        }
      }

      if (!matched) {
        status.value = "Working from Home";
      }
    } catch (e) {
      status.value = "Error: ${e.toString()}";
    } finally {
      isLoading.value = false; // ✅ stop loading
    }
  }

  var attendanceList = <dynamic>[].obs; // ✅ history data
  var errorMessage = "".obs; // ✅ error handling


  /// Fetch attendance from API
  Future<void> fetchAttendance() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final response = await _attendanceService.getAttendance();
      AppLogger.i("My Attendance List Response: ${response.data}");

      if (response.statusCode == 200 && response.data["status"] == 200) {
        attendanceList.value = response.data["data"] ?? [];
      } else {
        errorMessage.value = response.data["message"] ?? "Failed to load data";
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

// Add RxMap<DateTime, AttendanceType> and AttendanceType enum
  // ... your other code ...

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
          final officeName = (item["officeName"] ?? "").toString().toUpperCase();

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
        errorMessage.value = response.data["message"] ?? "Failed to load attendance data";
      }
    } catch (e) {
      errorMessage.value = "Error: $e";
    } finally {
      isLoading.value = false;
    }
  }


}
