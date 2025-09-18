import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/bindings/initial_binding.dart';
import 'core/theme.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final bool isLoggedIn = storage.read("isLoggedIn") ?? false;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Attendance SMIS",
      theme: AppTheme.lightTheme,
      initialBinding: InitialBinding(),

      // ✅ Decides where to start
      initialRoute: isLoggedIn ? AppRoutes.home : AppRoutes.login,

      getPages: AppRoutes.pages,
    );
  }
}