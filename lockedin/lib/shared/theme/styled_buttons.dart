import 'package:flutter/material.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:sizer/sizer.dart';

class AppButtonStyles {
  static final ButtonStyle elevatedButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
    textStyle: AppTextStyles.buttonText,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(90)),
    padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
  );

  static final ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    textStyle: AppTextStyles.buttonText.copyWith(color: AppColors.primary),
    side: BorderSide(color: AppColors.primary, width: 0.3.w),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(90)),
    padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
  );

  static final ButtonStyle iconButton = IconButton.styleFrom(
    padding: EdgeInsets.all(2.w),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(90)),
  );

  static Widget outlinedIconButton({
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(0), // Reduced padding
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary,
          width: 0.3.w, // Reduced border width
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.primary),
        iconSize: 5.w, // Reduced icon size
        constraints: BoxConstraints(minWidth: 8.w, minHeight: 8.w),
      ),
    );
  }

  static Widget socialLoginButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 6.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 6.w, color: AppColors.primary),
      label: Text(
        text,
        style: AppTextStyles.buttonText.copyWith(color: AppColors.primary),
      ),
    );
  }
}
