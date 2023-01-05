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


  static const TextStyle buttonTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

  static const TextStyle defaultTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 20,
  );

  static const TextStyle hintTextStyle = TextStyle(
    color: AppColors.lightBlue,
    fontSize: 16
  );

  static const TextStyle textStyle = TextStyle(
    color: Colors.black,
    fontSize: 16
  );

  static const TextStyle pickedDataTextStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: AppColors.gray,
  );

  static const TextStyle categoryTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );


}