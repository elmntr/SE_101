


import 'package:flutter/material.dart';


//FONTS AND IMAGES
const String fontAll = 'Gantari';
const String imageAll = 'assets/images/chicken_joo_logo.png';


class AppLayout {
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > 800;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;


//LAYOUT SETTINGS (PADDINGS, FONT SIZES, BUTTON SIZES, ETC.)
  static double titleFontSize(BuildContext context) =>
      isDesktop(context) ? 40 : 30;

  static double fieldPadding(BuildContext context) =>
      isDesktop(context) ? 600 : 50;

  static double loginButtonWidth(BuildContext context) =>
      isDesktop(context) ? 180 : 1000;
}
