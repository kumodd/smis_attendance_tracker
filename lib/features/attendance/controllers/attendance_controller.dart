import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smis_attendance_tracker/core/location_helper.dart';


class AttendanceController extends GetxController {
  var status = "Not tracked yet".obs;
  final storage = GetStorage();

  /// Predefined office locations with range in meters (from storage)
  List<Map<String, dynamic>> get officeLocations {
    final data = storage.read("locations") ?? [];
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> trackLocation() async {
    try {
      // Show full-screen loader
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

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
      // Close loader
      if (Get.isDialogOpen ?? false) Get.back();
    }
  }
}