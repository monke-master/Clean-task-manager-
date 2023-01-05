import 'package:flutter/material.dart';
import 'package:task_manager_arch/styles/text_styles.dart';

import 'app_colors.dart';

class ButtonStyles {

  static final ButtonStyle defaultButton = ElevatedButton.styleFrom(
    textStyle: TextStyles.buttonTextStyle,
    backgroundColor: AppColors.lightBlue,
    minimumSize: const Size.fromHeight(45),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0)
    )
  );

  static final ButtonStyle defaultTextButton = TextButton.styleFrom(
    textStyle: TextStyles.headerStyle,
    foregroundColor: Colors.black,
    minimumSize: const Size.fromHeight(45),
  );

  static final ButtonStyle categoryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.blue,
    textStyle: TextStyles.categoryTextStyle,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
  );

  static final ButtonStyle selectedCategoryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.lightBlue,
    textStyle: TextStyles.categoryTextStyle,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
  );

  static final ButtonStyle dialogButton = TextButton.styleFrom(
    textStyle: TextStyles.hintTextStyle,

  );

}