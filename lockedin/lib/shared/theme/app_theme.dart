import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/theme/styled_buttons.dart';
import 'package:lockedin/shared/theme/text_styles.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headline1.copyWith(fontSize: 22.sp),
      headlineMedium: AppTextStyles.headline2.copyWith(fontSize: 18.sp),
      bodyLarge: AppTextStyles.bodyText1.copyWith(fontSize: 14.sp),
      bodyMedium: AppTextStyles.bodyText2.copyWith(fontSize: 12.sp),
      labelLarge: AppTextStyles.buttonText.copyWith(fontSize: 14.sp),
    ),
    appBarTheme: AppBarTheme(
      color: AppColors.white,
      elevation: 0,
      iconTheme: IconThemeData(size: 6.w, color: AppColors.black),
      titleTextStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.primary,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppButtonStyles.elevatedButton,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppButtonStyles.outlinedButton,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(2.w)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 0.5.w),
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
    ),
    iconTheme: IconThemeData(size: 6.w, color: AppColors.gray),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.primary,
      contentTextStyle: TextStyle(fontSize: 12.sp, color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(AppColors.primary),
      trackColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.5)),
    ),
    checkboxTheme: CheckboxThemeData(
      checkColor: MaterialStateProperty.all(Colors.white),
      fillColor: MaterialStateProperty.all(AppColors.primary),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      elevation: 6,
    ),
    dividerTheme: DividerThemeData(color: Colors.grey[300], thickness: 0.2.h),
    tabBarTheme: TabBarTheme(
      labelColor: AppColors.primary,
      unselectedLabelColor: Colors.grey,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.primary, width: 0.5.w),
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.black,
      unselectedItemColor: AppColors.gray,
      selectedIconTheme: IconThemeData(size: 6.w, color: AppColors.black),
      unselectedIconTheme: IconThemeData(size: 6.w, color: AppColors.gray),
      selectedLabelStyle: TextStyle(fontSize: 10.sp),
      unselectedLabelStyle: TextStyle(fontSize: 10.sp),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.white,
    scaffoldBackgroundColor: AppColors.black,
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headline1.copyWith(
        fontSize: 22.sp,
        color: AppColors.white,
      ),
      headlineMedium: AppTextStyles.headline2.copyWith(
        fontSize: 18.sp,
        color: AppColors.white,
      ),
      bodyLarge: AppTextStyles.bodyText1.copyWith(
        fontSize: 14.sp,
        color: Colors.white,
      ),
      bodyMedium: AppTextStyles.bodyText2.copyWith(
        fontSize: 12.sp,
        color: Colors.white70,
      ),
      labelLarge: AppTextStyles.buttonText.copyWith(fontSize: 14.sp),
    ),
    appBarTheme: AppBarTheme(
      color: AppColors.black,
      elevation: 0,
      iconTheme: IconThemeData(size: 6.w, color: AppColors.white),
      titleTextStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.black,
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(2.w)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 0.5.w),
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.darkBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
    ),
    iconTheme: IconThemeData(size: 6.w, color: AppColors.white),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(AppColors.primary),
      trackColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.5)),
    ),
    checkboxTheme: CheckboxThemeData(
      checkColor: MaterialStateProperty.all(AppColors.black),
      fillColor: MaterialStateProperty.all(AppColors.primary),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      elevation: 6,
    ),
    dividerTheme: DividerThemeData(color: AppColors.gray, thickness: 0.2.h),
    tabBarTheme: TabBarTheme(
      labelColor: AppColors.white,
      unselectedLabelColor: Colors.grey,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.white, width: 0.5.w),
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1C2227),
      selectedItemColor: AppColors.white,
      unselectedItemColor: Colors.grey,
      selectedIconTheme: IconThemeData(size: 6.w, color: AppColors.white),
      unselectedIconTheme: IconThemeData(size: 6.w, color: Colors.grey),
      selectedLabelStyle: TextStyle(fontSize: 10.sp),
      unselectedLabelStyle: TextStyle(fontSize: 10.sp),
    ),
  );
}
