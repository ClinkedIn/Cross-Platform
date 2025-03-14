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
  );
  static Widget outlinedIconButton({
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(0), // Reduced padding
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary,
          width: 2, // Reduced border width
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.primary),
        iconSize: 20, // Reduced icon size
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 24, color: AppColors.primary),
        label: Text(
          text,
          style: AppTextStyles.buttonText.copyWith(color: AppColors.primary),
        ),
      );
    }

}
