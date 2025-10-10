import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smis_attendance_tracker/routes/app_routes.dart';
import 'package:smis_attendance_tracker/services/user_service.dart';
import 'package:smis_attendance_tracker/utils/logger.dart';

class AddEmployeeController extends GetxController {
  final employeeNameController = TextEditingController();
  final phoneController = TextEditingController();
  final psidController = TextEditingController();

  final RxString selectedDesignation = ''.obs; // 🔹 Observable for dropdown
  final RxList<String> designations = <String>[].obs;

  final isLoading = false.obs;
  final isSuccessUpdateEMployee = false.obs;

  final UserService _userService = UserService();
  final GetStorage storage = GetStorage();

  /// 🔹 Load designations from local storage
  void _loadDesignations() {
    final storedDesignations =
        storage.read<List<dynamic>>("designations") ?? [];

    // Convert to List<String>
    final List<String> stringList = storedDesignations
        .map((e) => e.toString())
        .toList();

    designations.assignAll(stringList);

    // 🔹 Set default selection if list is not empty
    if (designations.isNotEmpty) {
      selectedDesignation.value = designations.first;
    }
  }

  /// 🔹 Phone validation helper
  bool _isValidPhone(String phone) {
    final regex = RegExp(r'^[0-9]{10}$');
    return regex.hasMatch(phone);
  }

  /// 🔹 Show snackbar
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

  /// 🔹 Add employee
  Future<void> addEmployee() async {
    final name = employeeNameController.text.trim();
    final phone = phoneController.text.trim();
    final psid = psidController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      _showSnackbar(
        'Error',
        'Please fill in all required fields.',
        isError: true,
      );
      return;
    }

    if (!_isValidPhone(phone)) {
      _showSnackbar(
        'Error',
        'Phone number must be exactly 10 digits.',
        isError: true,
      );
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      AppLogger.i("Sending add user request...");

      final res = await _userService.addUser(
        name: name,
        phone: phone,
        psid: psid.isEmpty ? null : psid,
        designation: selectedDesignation.value,
      );

      AppLogger.i("Add employee response: ${res.data}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        _showSnackbar('Success', 'Employee added successfully!');

        // Reset form
        employeeNameController.clear();
        phoneController.clear();
        psidController.clear();
        selectedDesignation.value = designations.isNotEmpty
            ? designations.first
            : '';

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

  /// 🔹 Update employee
  Future<void> updateEmployee(
    String psid,
    String name,
    String designation,
    String phone,
  ) async {
    if (!_isValidPhone(phone)) {
      _showSnackbar(
        'Error',
        'Phone number must be exactly 10 digits.',
        isError: true,
      );
      return;
    }

    isLoading.value = true;
    isSuccessUpdateEMployee.value = false;

    try {
      final res = await _userService.updateUser(
        psid: psid,
        name: name,
        phone: phone,
        designation: designation,
      );

      if (res.statusCode == 200) {
        isSuccessUpdateEMployee.value = true;
        _showSnackbar('Success', "Employee updated successfully!");
      } else {
        isSuccessUpdateEMployee.value = false;
        _showSnackbar(
          'Error',
          res.data?["message"] ?? "Something went wrong",
          isError: true,
        );
      }
    } catch (e, st) {
      isSuccessUpdateEMployee.value = false;
      AppLogger.e("Update employee error", e, st);
      _showSnackbar('Error', e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadDesignations();
  }

  @override
  void onClose() {
    // If needed in future:
    // employeeNameController.dispose();
    // phoneController.dispose();
    // psidController.dispose();
    super.onClose();
  }
}
