import 'package:get/get.dart';
import 'package:smis_attendance_tracker/features/attendance/views/attendance_view.dart';
import 'package:smis_attendance_tracker/features/auth/views/login_page.dart';
import 'package:smis_attendance_tracker/features/auth/views/otp_page.dart';
import 'package:smis_attendance_tracker/features/home/home_view.dart';

import '../features/attendance/views/my_attendance.dart';


class AppRoutes {
  static const String login = '/login';
  static const String otp = '/otp';
  static const String attendance = '/attendance';
  static const String home = '/home';
  static const String myAttendance = '/myAttendance';


  static List<GetPage> pages = [
    GetPage(name: login, page: () =>  LoginView()),
    GetPage(name: otp, page: () => const OtpView()),
    GetPage(name: attendance, page: () =>  AttendanceView()),
    GetPage(name: home, page: () =>  HomeView()),
    GetPage(name: myAttendance, page: () =>  AttendanceHistoryScreen()),
  ];
}