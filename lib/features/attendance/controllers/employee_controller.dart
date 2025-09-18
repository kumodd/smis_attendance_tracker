import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smis_attendance_tracker/routes/app_routes.dart';
import 'package:smis_attendance_tracker/services/user_service.dart';
import 'package:smis_attendance_tracker/utils/logger.dart';

class AddEmployeeController extends GetxController {
  final employeeNameController = TextEditingController();
  final phoneController = TextEditingController();
  final psidController = TextEditingController();
  final selectedDesignation = 'IT executive'.obs;

  final UserService _userService = UserService();

  final List<String> designations = [
    'IT executive',
    'Sr. Project Manager',
    'Tower Lead',
    'Software Engineer',
    'Project Coordinator',
    'HR Manager',
  ];

  /// Common snackbar helper
  void _showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> addEmployee() async {
    if (employeeNameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      _showSnackbar('Error', 'Please fill in all required fields.', isError: true);
      return;
    }

    // Show loader
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      AppLogger.i("Sending add user request...");

      final res = await _userService.addUser(
        name: employeeNameController.text.trim(),
        phone: phoneController.text.trim(),
        psid: psidController.text.trim().isEmpty ? null : psidController.text.trim(),
        designation: selectedDesignation.value,
      );

      AppLogger.i("Add employee response: ${res.data}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        _showSnackbar('Success', 'Employee added successfully!');

        // Reset form
        employeeNameController.clear();
        phoneController.clear();
        psidController.clear();
        selectedDesignation.value = designations.first;

        // Navigate after short delay (so user sees snackbar)
        await Future.delayed(const Duration(milliseconds: 600));
        Get.offAllNamed(AppRoutes.home);
      } else {
        _showSnackbar(
          'Error',
          res.data?["message"] ?? "Something went wrong",
          isError: true,
        );
      }
    } catch (e, st) {
      AppLogger.e("Add employee error", e, st);
      _showSnackbar('Error', e.toString(), isError: true);
    } finally {
      if (Get.isDialogOpen ?? false) {
        Get.back(); // Close loader safely
      }
    }
  }

  @override
  void onClose() {
    employeeNameController.dispose();
    phoneController.dispose();
    psidController.dispose();
    super.onClose();
  }
}