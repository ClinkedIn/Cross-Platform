import 'package:flutter/material.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:sizer/sizer.dart';

class LogoAppbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(60); // Standard app bar height

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: Container(),
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Text(
            "Locked ",
            style: AppTextStyles.headline1.copyWith(
              color: AppColors.primary,
              fontSize: 3.h, // Responsive font size
            ),
          ),
          Image.network(
            "https://upload.wikimedia.org/wikipedia/commons/c/ca/LinkedIn_logo_initials.png",
            height: 4.h, // Responsive height
          ),
        ],
      ),
    );
  }
}
