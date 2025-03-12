import 'package:flutter/material.dart';
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
      headlineLarge: AppTextStyles.headline1,
      headlineMedium: AppTextStyles.headline2,
      bodyLarge: AppTextStyles.bodyText1,
      bodyMedium: AppTextStyles.bodyText2,
      labelLarge: AppTextStyles.buttonText,
    ),
    appBarTheme: const AppBarTheme(
      color: AppColors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.black),
      titleTextStyle: TextStyle(
        fontSize: 20,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    iconButtonTheme: IconButtonThemeData(style: AppButtonStyles.iconButton),
    iconTheme: IconThemeData(color: AppColors.gray),

    // New Features
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.primary,
      contentTextStyle: TextStyle(color: Colors.white),
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
    dividerTheme: DividerThemeData(color: Colors.grey[300], thickness: 1),
    tabBarTheme: TabBarTheme(
      labelColor: AppColors.primary,
      unselectedLabelColor: Colors.grey,
      indicator: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.primary, width: 2)),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.black,
      unselectedItemColor: AppColors.gray,
      selectedIconTheme: IconThemeData(color: AppColors.black, size: 28),
      unselectedIconTheme: IconThemeData(color: AppColors.gray, size: 28),
      selectedLabelStyle: TextStyle(fontSize: 12, color: AppColors.black),
      unselectedLabelStyle: TextStyle(fontSize: 12, color: AppColors.gray),
      enableFeedback: true,
      type: BottomNavigationBarType.fixed,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.white,
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headline1.copyWith(color: AppColors.white),
      headlineMedium: AppTextStyles.headline2.copyWith(color: AppColors.white),
      bodyLarge: AppTextStyles.bodyText1.copyWith(color: Colors.white),
      bodyMedium: AppTextStyles.bodyText2.copyWith(color: Colors.white70),
      labelLarge: AppTextStyles.buttonText,
    ),
    appBarTheme: const AppBarTheme(
      color: AppColors.black,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.white),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
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
      fillColor: AppColors.black,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.black,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    iconButtonTheme: IconButtonThemeData(style: AppButtonStyles.iconButton),
    iconTheme: IconThemeData(color: AppColors.white),

    // New Features
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.primary,
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
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
    dividerTheme: DividerThemeData(color: AppColors.gray, thickness: 1),
    tabBarTheme: TabBarTheme(
      labelColor: AppColors.white,
      unselectedLabelColor: Colors.grey,
      indicator: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.white, width: 2)),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(
        0xFF1C2227,
      ), // Dark background from the image
      selectedItemColor: AppColors.white,
      unselectedItemColor: Colors.grey,
      selectedIconTheme: IconThemeData(color: AppColors.white, size: 28),
      unselectedIconTheme: IconThemeData(color: Colors.grey, size: 28),
      selectedLabelStyle: TextStyle(fontSize: 12, color: AppColors.white),
      unselectedLabelStyle: TextStyle(fontSize: 12, color: Colors.grey),
      enableFeedback: true,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
