import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:sizer/sizer.dart';

class Connection extends StatelessWidget {
  final ImageProvider profileImage;
  final String firstName;
  final String lastName;
  final String lastJobTitle;
  final VoidCallback onNameTap;

  const Connection({
    required this.profileImage,
    required this.firstName,
    required this. lastName,
    required this.lastJobTitle,
    required this.onNameTap,
    super.key,
  });

  get profilePicture => null;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          backgroundImage: profileImage,
        ),
        SizedBox(width: 1.5.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onNameTap,
              child: Text(
                '${firstName} ${lastName}',
                style: TextStyle(fontSize: 16.px, fontWeight: FontWeight.bold),
              ),
            ),
            Text(lastJobTitle),
          ],
        ),
        Spacer(),
        IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
        IconButton(onPressed: () {}, icon: Icon(Icons.send)),
      ],
    );
  }
}
