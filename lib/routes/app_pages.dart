import 'package:get/get.dart';
import 'package:smis_attendance_tracker/features/attendance/views/attendance_view.dart';
import 'package:smis_attendance_tracker/features/auth/views/login_page.dart';
import 'package:smis_attendance_tracker/features/auth/views/otp_page.dart';
import 'package:smis_attendance_tracker/features/home/home_view.dart';

class AppPages {
  static final routes = [
    GetPage(name: '/login', page: () =>  LoginView()),
    GetPage(name: '/otp', page: () => const OtpView()),
    GetPage(name: '/attendance', page: () => const AttendanceView()),
    GetPage(name: '/home', page: () =>  HomeView()),
    
    
  ];
}