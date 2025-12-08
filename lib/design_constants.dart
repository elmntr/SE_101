import 'package:flutter/material.dart';

const String fontAll = 'Montserrat';
const String imageAll = 'assets/images/chicken_joo_logo.png';
const Color colorAll = Colors.red;

class AppLayout {
  const AppLayout._();

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > 600;

  static double fieldPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 400;
    if (width >= 800) return 200;
    return 24;
  }

  static double loginButtonWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 320;
    if (width >= 800) return 280;
    return double.infinity;
  }
}
