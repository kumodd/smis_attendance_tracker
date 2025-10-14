import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:smis_attendance_tracker/routes/app_routes.dart';
import 'package:smis_attendance_tracker/services/user_service.dart';
import 'package:smis_attendance_tracker/utils/logger.dart';

class AddEmployeeController extends GetxController {
  final employeeNameController = TextEditingController();
  final phoneController = TextEditingController();
  final psidController = TextEditingController();

  final RxString selectedDesignation = ''.obs;
  final RxList<String> designations = <String>[].obs;

  final isLoading = false.obs;
  final isSuccessUpdateEMployee = false.obs;

  final UserService _userService = UserService();
  final GetStorage storage = GetStorage();

  void _loadDesignations() {
    final storedDesignations =
        storage.read<List<dynamic>>("designations") ?? [];
    final List<String> stringList = storedDesignations
        .map((e) => e.toString())
        .toList();
    designations.assignAll(stringList);

    if (designations.isNotEmpty) {
      selectedDesignation.value = designations.first;
    }
  }

  bool _isValidPhone(String phone) {
    final regex = RegExp(r'^[0-9]{10}$');
    return regex.hasMatch(phone);
  }

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

  Future<void> _closeDialog() async {
    for (int i = 0; i < 3; i++) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
        await Future.delayed(const Duration(milliseconds: 100));
      } else {
        break;
      }
    }
  }

  Future<void> addEmployee() async {
    final name = employeeNameController.text.trim();
    final phone = phoneController.text.trim();
    final psid = psidController.text.trim();

    if (name.isEmpty || phone.isEmpty || psid.isEmpty) {
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
    if (psid.length < 3) {
      _showSnackbar(
        'Error',
        'PSID must be at-lease 3 digits long.',
        isError: true,
      );
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final res = await _userService.addUser(
        name: name,
        phone: phone,
        psid: psid.isEmpty ? null : psid,
        designation: selectedDesignation.value,
      );

      await _closeDialog();

      if (res.statusCode == 200 || res.statusCode == 201) {
        _showSnackbar('Success', 'Employee added successfully!');
        employeeNameController.clear();
        phoneController.clear();
        psidController.clear();
        selectedDesignation.value = designations.isNotEmpty
            ? designations.first
            : '';

        await Future.delayed(const Duration(milliseconds: 300));
        Get.offAllNamed(AppRoutes.home);
      } else {
        final errorMsg = _extractErrorMessageFromData(res.data);
        _showSnackbar(
          'Error',
          errorMsg ?? "Something went wrong",
          isError: true,
        );
      }
    } on DioError catch (e) {
      await _closeDialog();
      final errorMessage = _extractErrorMessage(e);
      AppLogger.e("Add employee DioError: $errorMessage");
      _showSnackbar(
        'Error',
        errorMessage ?? "Something went wrong",
        isError: true,
      );
    } catch (e) {
      await _closeDialog();
      AppLogger.e("Add employee unexpected error: $e");
      _showSnackbar('Error', "Something went wrong", isError: true);
    }
  }

  Future<void> updateEmployee(
    String psid,
    String name,
    String designation,
    String phone,
  ) async {
    if (name.isEmpty || phone.isEmpty) {
      _showSnackbar('Error', 'Please fill all fields.', isError: true);
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
        final errorMsg = _extractErrorMessageFromData(res.data);
        isSuccessUpdateEMployee.value = false;
        _showSnackbar(
          'Error',
          errorMsg ?? "Something went wrong",
          isError: true,
        );
      }
    } on DioError catch (e) {
      final errorMessage = _extractErrorMessage(e);
      isSuccessUpdateEMployee.value = false;
      AppLogger.e("Update employee DioError: $errorMessage");
      _showSnackbar(
        'Error',
        errorMessage ?? "Something went wrong",
        isError: true,
      );
    } catch (e) {
      isSuccessUpdateEMployee.value = false;
      AppLogger.e("Update employee unexpected error: $e");
      _showSnackbar('Error', "Something went wrong", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// Extract error message from DioError (like AuthController)
  String? _extractErrorMessage(DioError e) {
    try {
      final data = e.response?.data;

      if (data is Map) {
        if (data.containsKey('error')) return data['error'].toString();
        if (data.containsKey('message')) return data['message'].toString();
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          if (errors is Map) {
            final firstKey = errors.keys.first;
            final firstError = errors[firstKey];
            if (firstError is List && firstError.isNotEmpty) {
              return firstError.first.toString();
            } else if (firstError is String) {
              return firstError;
            }
          }
        }
      }

      return e.message ?? "Unknown error occurred";
    } catch (err) {
      return "Failed to parse error";
    }
  }

  /// Extract error message from normal response data when statusCode is error
  String? _extractErrorMessageFromData(dynamic data) {
    try {
      if (data is Map) {
        if (data.containsKey('error')) return data['error'].toString();
        if (data.containsKey('message')) return data['message'].toString();
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          if (errors is Map) {
            final firstKey = errors.keys.first;
            final firstError = errors[firstKey];
            if (firstError is List && firstError.isNotEmpty) {
              return firstError.first.toString();
            } else if (firstError is String) {
              return firstError;
            }
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadDesignations();
  }

  @override
  void onClose() {
    employeeNameController.dispose();
    phoneController.dispose();
    psidController.dispose();
    super.onClose();
  }
}
