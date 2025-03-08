import 'package:flutter/material.dart';
import 'package:lockedin/presentation/shared/styled_buttons.dart';

class ProfileButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: StyledButton(onPressed: () {}, text: "Open to")),
              SizedBox(width: 10),
              Expanded(
                child: StyledButton(
                  onPressed: () {},
                  backgroundColor: Colors.blue[600]!,
                  textColor: Colors.white,
                  text: "Add section",
                ),
              ),
              SizedBox(width: 10),

              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
                child: IconButton(
                  icon: Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          StyledButton(
            onPressed: () {},
            text: "Enhance Profile",
            backgroundColor: Colors.white,
            textColor: Colors.blue[600]!,
          ),
        ],
      ),
    );
  }
}
