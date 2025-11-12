import 'package:flutter/material.dart';

const String fontAll = 'Montserrat';

class AppLayout {
  const AppLayout._();

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
