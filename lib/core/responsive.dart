import 'package:flutter/widgets.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockWidth;
  static late double blockHeight;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockWidth = screenWidth / 100;
    blockHeight = screenHeight / 100;
  }

  /// Scale text size based on screen width
  static double textSize(double size) => size * blockWidth / 3.8;

  /// Scale height
  static double height(double inputHeight) =>
      (inputHeight / 812.0) * screenHeight;

  /// Scale width
  static double width(double inputWidth) =>
      (inputWidth / 375.0) * screenWidth;
}