import 'package:flutter/material.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:sizer/sizer.dart';

class AppTextStyles {
  static final TextStyle headline1 = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
  static final TextStyle headline2 = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
  static final TextStyle bodyText1 = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
  );
  static final TextStyle bodyText2 = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: Colors.black54,
  );
  static final TextStyle buttonText = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
}
