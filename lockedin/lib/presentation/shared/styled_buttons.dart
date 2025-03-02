import 'package:flutter/material.dart';

class StyledButton extends StatelessWidget {
  const StyledButton({
    super.key,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.blue,
    required this.text,
    this.width = double.infinity,
  });

  final void Function() onPressed;
  final Color backgroundColor;
  final Color textColor;
  final String text;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        side:
            backgroundColor == Colors.white
                ? BorderSide(color: textColor, width: 2)
                : BorderSide.none,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),

      child: SizedBox(
        width: width,
        child: Center(child: Text(text, style: TextStyle(color: textColor))),
      ),
    );
  }
}
