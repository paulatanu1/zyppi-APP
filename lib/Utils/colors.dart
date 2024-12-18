import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryButtonColor = Color(0xFFF32AA0);
  static const Color googleSignInButtonColor = Color(0xFFF6F5F5);
  static const Color googleSignInShadowColor = Colors.grey;
  static const Color textFormFieldColor = Color.fromARGB(255, 207, 207, 207);
  static const Color blue = Color(0xFF05416F);
  static const Color hintTextColor = Color(0xFF676767);
  static const Color hintTextColor1 = Color(0xFFF3F3F3);
  static const Color unselectedOTP = Color.fromRGBO(248, 55, 88, 0.33);
  static const Color selectedOTP = Color(0xFFF32AA0);
  static const Color selectedOTP1 = Color.fromARGB(255, 231, 62, 115);
  static const Color white = Color(0xFFFFFFFF);
  static const Color deepBlue = Color(0xFF3158E9);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFFA8A8A9);
  static const Color grey1 = Color(0xFF575757);
  static const Color deepBlue1 = Color(0xFF1541E6);
  static const Color lightBlue = Color(0xFF597AF1);
  static const Color green = Color(0xFF53B175);
  static  LinearGradient gradientHomeBackGround = LinearGradient(
    begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
    Colors.blueAccent.withOpacity(0.6),
    Colors.white,
    Colors.white
  ]);

  //Category Card Colors
  static const List<Map<String, dynamic>> categoryColors = [
    {
      'categoryCard': Color.fromRGBO(83, 177, 117, 0.1),
      'categoryCardBorder': Color.fromRGBO(83, 177, 117, 1)
    },
    {
      'categoryCard': Color.fromRGBO(255, 236, 247, 1),
      'categoryCardBorder': Color.fromRGBO(251, 84, 182, 1)
    },
    {
      'categoryCard': Color.fromRGBO(248, 164, 76, 0.1),
      'categoryCardBorder': Color.fromRGBO(250, 189, 124, 1)
    },
    {
      'categoryCard': Color.fromRGBO(237, 247, 253, 1),
      'categoryCardBorder': Color.fromRGBO(82, 186, 244, 1)
    }
  ];
}
