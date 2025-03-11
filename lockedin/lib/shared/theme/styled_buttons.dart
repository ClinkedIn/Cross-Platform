import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppButtonStyles {
  static final ButtonStyle elevatedButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
    textStyle: AppTextStyles.buttonText,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(90)),
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
  );

  static final ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    textStyle: AppTextStyles.buttonText.copyWith(color: AppColors.primary),
    side: const BorderSide(color: AppColors.primary, width: 3),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(90)),
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
  );
  static final ButtonStyle iconButton = IconButton.styleFrom(
    padding: const EdgeInsets.all(8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(90)),
    side: const BorderSide(color: AppColors.primary),
  );
  static Widget outlinedIconButton({
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ), // Border added here
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}
