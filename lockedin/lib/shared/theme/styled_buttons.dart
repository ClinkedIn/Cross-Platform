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

  static final ButtonStyle textButton = TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 0.w),
    minimumSize: Size(0, 0),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    textStyle: AppTextStyles.buttonText.copyWith(
      fontSize: 2.h,
      color: AppColors.primary,
      fontWeight: FontWeight.bold,
      ),
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
  required VoidCallback onPressed,
  required Widget icon,
}) {
  return OutlinedButton(
    style: OutlinedButton.styleFrom(
      minimumSize: Size(double.infinity, 6.h), // Use responsive height
      side: BorderSide(color: AppColors.primary), // Changed to blue using your theme color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.sp),
      ),
      padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 5.w), // Add padding
      backgroundColor: Colors.white, // Ensure consistent background
      foregroundColor: Colors.black87, // Text color
    ),
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 24, // Fixed width for consistency
          height: 24, // Fixed height for consistency
          child: icon,
        ),
        SizedBox(width: 3.w), // Use responsive spacing
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
}
