import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_colors.dart';

// Стили текста
class TextStyles {

  // Стиль заголовка
  static const TextStyle headerStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

  static const TextStyle appBarTextStyle = TextStyle(
    color: AppColors.lightBlue,
    fontSize: 20,
  );


  static const TextStyle buttonText = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

  static const TextStyle defaultText = TextStyle(
    color: Colors.black,
    fontSize: 20,
  );

}