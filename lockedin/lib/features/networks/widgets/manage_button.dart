import 'package:flutter/material.dart';

class ManageButton extends StatelessWidget {
  final String text;
  final IconData icon;

  const ManageButton({
    required this.text,
    required this.icon,
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            label: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style: TextStyle(color: theme.iconTheme.color, fontSize: 20),
              ),
            ),
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
            ),
            onPressed: () {},
            icon: Icon(icon, color: theme.iconTheme.color, size: 24),
          ),
        ),
      ],
    );
  }
}
