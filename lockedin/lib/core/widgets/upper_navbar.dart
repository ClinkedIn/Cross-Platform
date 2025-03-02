import 'package:flutter/material.dart';

class UpperNavbar extends StatelessWidget implements PreferredSizeWidget {
  const UpperNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
        onPressed: () {},
      ),
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(5),
        ),
        child: TextField(
          decoration: InputDecoration(
            fillColor: Colors.grey[200],
            hintText: "Search",
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10.0),
          ),
          style: TextStyle(color: Colors.grey[400]),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: Colors.grey[700]),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
