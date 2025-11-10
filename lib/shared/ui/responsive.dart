import "package:flutter/material.dart";

bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 900;

class AppSizes {
  static double iconLg(BuildContext context) => isDesktop(context) ? 22.0 : 28.0;
  static const double cardRadius = 20;
  static const double cardPad = 16;
  static const double cardGap = 12;
}